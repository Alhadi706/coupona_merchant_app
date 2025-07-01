// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { corsHeaders } from '../_shared/cors.ts';

// Initialize Supabase Admin Client
const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
);

console.log("Hello from Functions!")

Deno.serve(async (req) => {
  // This is needed if you're planning to invoke your function from a browser.
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // 1. Fetch all active conditional rewards
    const { data: rewards, error: rewardsError } = await supabaseAdmin
      .from('rewards')
      .select('*')
      .eq('type', 'conditional')
      .eq('isActive', true); // Assuming you have a flag for active rewards

    if (rewardsError) throw rewardsError;

    // 2. Fetch all users with their points
    const { data: users, error: usersError } = await supabaseAdmin
      .from('users') // Assuming your table is named 'users'
      .select('id, points'); // Assuming 'id' and 'points' columns

    if (usersError) throw usersError;

    const rewardsToGrant: { user_id: any; reward_id: any; granted_at: string; is_claimed: boolean; }[] = [];

    // 3. Logic to check conditions and grant rewards
    for (const user of users) {
      for (const reward of rewards) {
        if (user.points >= reward.required_points) {
          // Check if the user has already been granted this specific reward
          const { data: existingGrant, error: checkError } = await supabaseAdmin
            .from('user_rewards')
            .select('id')
            .eq('user_id', user.id)
            .eq('reward_id', reward.id)
            .limit(1);

          if (checkError) {
            console.error('Error checking existing reward grant:', checkError);
            continue; // Skip to next iteration
          }

          // If no existing grant is found, grant the new reward
          if (!existingGrant || existingGrant.length === 0) {
            rewardsToGrant.push({
              user_id: user.id,
              reward_id: reward.id,
              granted_at: new Date().toISOString(),
              is_claimed: false, // Mark as granted but not yet claimed by the user
            });
          }
        }
      }
    }

    // 4. Batch insert all new grants
    if (rewardsToGrant.length > 0) {
      const { error: insertError } = await supabaseAdmin
        .from('user_rewards')
        .insert(rewardsToGrant);

      if (insertError) throw insertError;
    }

    return new Response(JSON.stringify({
      message: `Successfully processed and granted ${rewardsToGrant.length} new rewards.`,
    }), {
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

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/executeRewardConditions' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
