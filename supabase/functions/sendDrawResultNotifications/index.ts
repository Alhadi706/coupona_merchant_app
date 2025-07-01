// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { corsHeaders } from '../_shared/cors.ts';

const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
);

console.log("Hello from Functions!")

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { reward_id } = await req.json();
    if (!reward_id) {
      throw new Error("Missing required field: reward_id");
    }

    // 1. Get the reward details
    const { data: reward, error: rewardError } = await supabaseAdmin
      .from('rewards')
      .select('name')
      .eq('id', reward_id)
      .single();

    if (rewardError) throw rewardError;

    // 2. Get all participants (winners and losers)
    const { data: participants, error: participantsError } = await supabaseAdmin
      .from('user_rewards')
      .select('user_id, is_winner')
      .eq('reward_id', reward_id);

    if (participantsError) throw participantsError;

    const notifications = participants.map(p => {
      const title = `Result for draw: ${reward.name}`;
      const message = p.is_winner
        ? `Congratulations! You won the draw for ${reward.name}!`
        : `Better luck next time in the draw for ${reward.name}.`;

      return {
        user_id: p.user_id,
        title: title,
        body: message,
        created_at: new Date().toISOString(),
        is_read: false
      };
    });

    // 3. Batch insert notifications
    if (notifications.length > 0) {
      const { error: insertError } = await supabaseAdmin
        .from('notifications') // Assuming you have a 'notifications' table
        .insert(notifications);

      if (insertError) throw insertError;
    }

    return new Response(JSON.stringify({ message: `Successfully created ${notifications.length} notifications.` }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/sendDrawResultNotifications' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
