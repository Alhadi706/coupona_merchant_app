// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { initializeApp, cert } from "npm:firebase-admin/app";
import { getAuth } from "npm:firebase-admin/auth";
import { corsHeaders } from '../_shared/cors.ts';

console.log("Hello from Functions!")

// قم بتحميل بيانات اعتماد حساب خدمة Firebase من متغيرات البيئة
// تأكد من أنك قمت بإضافته كـ Secret في إعدادات Supabase Edge Function
const serviceAccount = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT_KEY")!);

// تهيئة Firebase Admin SDK
try {
  initializeApp({
    credential: cert(serviceAccount),
  });
} catch (e) {
  // تجاهل الخطأ إذا كان التطبيق مهيأ بالفعل
  if (e.code !== 'app/duplicate-app') {
    console.error("Firebase initialization error:", e);
  }
}

serve(async (req) => {
  // هذا ضروري للتعامل مع طلبات OPTIONS من المتصفح (preflight)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // استخراج 'uid' من جسم الطلب
    const { uid } = await req.json();
    if (!uid) {
      return new Response(JSON.stringify({ error: "UID is required" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      });
    }

    // إنشاء رمز مخصص باستخدام Firebase Admin SDK
    const firebaseToken = await getAuth().createCustomToken(uid);

    // إرسال الرمز المخصص كاستجابة
    return new Response(JSON.stringify({ firebaseToken }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    console.error("Error creating custom token:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/create-firebase-token' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
