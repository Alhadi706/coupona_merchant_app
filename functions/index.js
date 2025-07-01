/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true }); // يسمح لكل الدومينات
admin.initializeApp();

const db = admin.firestore();

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// ============================================================================
// 1. Execute Reward Conditions (Conditional Rewards)
// ============================================================================
/**
 * Triggered when a user's points are updated.
 * Checks if the user qualifies for any conditional rewards.
 */
exports.executeRewardConditions = functions.firestore
    .document("userPoints/{userId}")
    .onUpdate(async (change, context) => {
        const userId = context.params.userId;
        const newPointsData = change.after.data();
        const userTotalPoints = newPointsData.totalPoints || 0;

        const rewardsRef = db.collection("rewards");
        const snapshot = await rewardsRef
            .where("type", "==", "conditional")
            .where("isActive", "==", true)
            .get();

        if (snapshot.empty) {
            console.log("No active conditional rewards found.");
            return null;
        }

        const userRewardsRef = db.collection("users")
            .doc(userId).collection("grantedRewards");

        const promises = [];

        snapshot.forEach((doc) => {
            const reward = doc.data();
            const rewardId = doc.id;

            const condition = reward.condition || {};
            const hasPointsCondition = condition.type === "points";
            const requiredPoints = condition.value || 0;

            // Check if user already has this reward
            const checkExistingRewardPromise = userRewardsRef.doc(rewardId).get()
                .then((userRewardDoc) => {
                    if (userRewardDoc.exists) {
                        console.log(`User ${userId} already has reward ${rewardId}.`);
                        return null;
                    }

                    // Check points condition
                    if (hasPointsCondition && userTotalPoints >= requiredPoints) {
                        console.log(`Granting reward ${rewardId} to user ${userId}.`);
                        return userRewardsRef.doc(rewardId).set({
                            rewardId: rewardId,
                            grantedAt: admin.firestore.FieldValue.serverTimestamp(),
                            isRedeemed: false,
                            title: reward.title,
                            description: reward.description,
                        });
                    }
                    return null;
                });
            promises.push(checkExistingRewardPromise);
        });

        return Promise.all(promises);
    });


// ============================================================================
// 2. Execute Draw (Draw Rewards)
// ============================================================================
/**
 * A scheduled function that runs every minute to check for draws to execute.
 */
exports.executeDraw = functions.pubsub.schedule("* * * * *")
    .onRun(async (context) => {
        console.log("Checking for draws to execute...");
        const now = admin.firestore.Timestamp.now();
        const rewardsRef = db.collection("rewards");

        const snapshot = await rewardsRef
            .where("type", "==", "draw")
            .where("isActive", "==", true)
            .where("drawTime", "<=", now)
            .where("winners", "==", null) // Process only if winners not chosen
            .get();

        if (snapshot.empty) {
            console.log("No draws to execute at this time.");
            return null;
        }

        const promises = [];
        snapshot.forEach((doc) => {
            const reward = doc.data();
            const rewardId = doc.id;
            const participants = reward.participants ?
                Object.keys(reward.participants) : [];
            const numberOfWinners = reward.numberOfWinners || 1;

            console.log(`Executing draw for reward: ${rewardId}`);

            if (participants.length === 0) {
                console.log(`No participants in draw ${rewardId}. Closing draw.`);
                const updatePromise = doc.ref.update({
                    winners: [], // Mark as processed with no winners
                });
                promises.push(updatePromise);
                return; // continue to next loop item
            }

            const winners = [];
            const participantsCopy = [...participants];

            for (let i = 0; i < numberOfWinners && participantsCopy.length > 0; i++) {
                const winnerIndex = Math.floor(Math.random() *
                    participantsCopy.length);
                const winnerId = participantsCopy.splice(winnerIndex, 1)[0];
                winners.push({
                    userId: winnerId,
                    username: reward.participants[winnerId].username,
                });
            }

            console.log(`Winners for ${rewardId}:`, winners);

            const updatePromise = doc.ref.update({
                winners: winners,
                isActive: false, // Deactivate the draw after execution
            });
            promises.push(updatePromise);
        });

        return Promise.all(promises);
    });


// ============================================================================
// 3. Send Draw Result Notifications
// ============================================================================
/**
 * Triggered when a reward document is updated, specifically after winners
 * are chosen for a draw. Sends notifications to all participants.
 */
exports.sendDrawResultNotifications = functions.firestore
    .document("rewards/{rewardId}")
    .onUpdate(async (change, context) => {
        const rewardId = context.params.rewardId;
        const newData = change.after.data();
        const oldData = change.before.data();

        // Proceed only if it's a draw, winners were just added,
        // and notifications haven't been sent.
        if (
            newData.type !== "draw" ||
            !newData.winners ||
            newData.winners.length === 0 ||
            newData.notificationsSent ||
            (oldData.winners && oldData.winners.length > 0)
        ) {
            return null;
        }

        const participants = newData.participants || {};
        const winnerIds = newData.winners.map((winner) => winner.userId);
        const allParticipantIds = Object.keys(participants);

        const notificationPromises = allParticipantIds.map(async (userId) => {
            const userDoc = await db.collection("users").doc(userId).get();
            if (!userDoc.exists) {
                console.log(`User doc not found for ID: ${userId}`);
                return;
            }

            const fcmToken = userDoc.data().fcmToken;
            if (!fcmToken) {
                console.log(`FCM token not found for user ID: ${userId}`);
                return;
            }

            const isWinner = winnerIds.includes(userId);
            const title = isWinner ?
                "🎉 تهانينا، لقد فزت!" :
                "حظاً أوفر في المرة القادمة";
            const body = isWinner ?
                `لقد فزت في سحب جائزة "${newData.title}".` :
                `نشكرك على المشاركة في سحب جائزة "${newData.title}".`;

            const message = {
                notification: {title, body},
                token: fcmToken,
                data: {rewardId, type: "draw_result"},
            };

            try {
                await admin.messaging().send(message);
            } catch (error) {
                console.error(`Failed to send notification to ${userId}`, error);
            }
        });

        await Promise.all(notificationPromises);
        console.log("All draw result notifications sent.");

        // Mark notifications as sent to prevent duplicates.
        return db.collection("rewards").doc(rewardId).update({
            notificationsSent: true,
        });
    });

exports.createFirebaseToken = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    // من هنا ضع منطقك (مثلاً جلب بيانات من Supabase أو أي API)
    // مثال: ترجع توكن وهمي
    res.json({ firebaseToken: "FAKE_TOKEN_FOR_TEST" });
  });
});

// NOTE: Remember to add the previously created functions 
// executeRewardConditions and executeDraw here as well.
