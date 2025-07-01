const admin = require("firebase-admin");

// تحميل بيانات اعتماد Firebase Admin من ملف JSON
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

exports.handler = async function(event, context) {
  // دعم CORS
  if (event.httpMethod === "OPTIONS") {
    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
      body: "ok",
    };
  }

  try {
    const authHeader = event.headers.authorization || event.headers.Authorization;
    if (!authHeader) {
      return {
        statusCode: 401,
        body: JSON.stringify({ error: "Missing Authorization header" }),
      };
    }

    // uid يجب أن يصلك من Supabase أو من بيانات التاجر
    // هنا سنستخدم uid من Supabase JWT (أو أرسله من فلاتر في body)
    const { uid } = JSON.parse(event.body);
    if (!uid) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "Missing uid" }),
      };
    }

    const firebaseToken = await admin.auth().createCustomToken(uid);

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ firebaseToken }),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
    };
  }
};
