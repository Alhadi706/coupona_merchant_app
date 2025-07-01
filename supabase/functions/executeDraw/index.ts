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
  const { name } = await req.json()
  const data = {
    message: `Hello ${name}!`,
  }

  return new Response(
    JSON.stringify(data),
    { headers: { "Content-Type": "application/json" } },
  )
})

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // 1. Fetch all draw rewards where the draw date is in the past and that haven't been executed
    const { data: rewards, error: rewardsError } = await supabaseAdmin
      .from('rewards')
      .select('*')
      .eq('type', 'draw')
      .eq('is_draw_executed', false)
      .lte('draw_date', new Date().toISOString());

    if (rewardsError) throw rewardsError;

    for (const reward of rewards) {
      // 2. Fetch all users who entered the draw for this reward
      const { data: participants, error: participantsError } = await supabaseAdmin
        .from('user_rewards')
        .select('user_id')
        .eq('reward_id', reward.id);

      if (participantsError) throw participantsError;

      if (participants.length === 0) {
        // No participants, mark draw as executed and continue
        await supabaseAdmin.from('rewards').update({ is_draw_executed: true }).eq('id', reward.id);
        continue;
      }

      // 3. Select winners randomly
      const winners: any[] = [];
      const participantIds = participants.map(p => p.user_id);
      const numberOfWinners = Math.min(reward.number_of_winners, participantIds.length);

      for (let i = 0; i < numberOfWinners; i++) {
        const randomIndex = Math.floor(Math.random() * participantIds.length);
        winners.push(participantIds[randomIndex]);
        // Remove the winner from the list to avoid duplicate wins
        participantIds.splice(randomIndex, 1);
      }

      // 4. Update the user_rewards table to mark the winners
      if (winners.length > 0) {
        await supabaseAdmin
          .from('user_rewards')
          .update({ is_winner: true })
          .in('user_id', winners)
          .eq('reward_id', reward.id);
      }

      // 5. Mark the draw as executed in the rewards table
      await supabaseAdmin.from('rewards').update({ is_draw_executed: true }).eq('id', reward.id);

      // (Optional) Trigger the notification function
      // You might need to call the sendDrawResultNotifications function here
      // This can be done via an HTTP request to the other function if they are separate,
      // or by directly calling its logic if combined.
    }

    return new Response(JSON.stringify({ message: `Successfully executed draws for ${rewards.length} rewards.` }), {
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

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/executeDraw' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
