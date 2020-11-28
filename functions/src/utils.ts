import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const env = functions.config();

export async function checkUserIsSignedIn(context: functions.https.CallableContext) {
  const userAuth = context.auth;
  const instanceIdToken = context.instanceIdToken;

  if (!userAuth || !instanceIdToken) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called from ' +
      'an authenticated user.');
  }

  let isTokenValid = false;

  try {
    await adminApp
      .auth()
      .verifyIdToken(instanceIdToken, true);

    isTokenValid = true;

  } catch (error) {
    isTokenValid = false;
  }

  if (!isTokenValid) {
    throw new functions.https.HttpsError('unauthenticated', 'Your session has expired. ' +
      'Please (sign out and) sign in again.');
  }
}

export function sendNotification(notificationData: any) {
  const headers = {
    "Content-Type": "application/json; charset=utf-8",
    Authorization: `Basic ${env.onesignal.apikey}`,
  };

  const options = {
    host: "onesignal.com",
    port: 443,
    path: "/api/v1/notifications",
    method: "POST",
    headers: headers,
  };

  const https = require("https");
  const req = https.request(options, (res: any) => {
    // console.log("statusCode:", res.statusCode);
    // console.log("headers:", res.headers);
    res.on("data", (respData: any) => {
      // console.log("Response:");
      console.log(JSON.parse(respData));
    });
  });

  req.on("error", (e: Error) => {
    console.log("ERROR:");
    console.log(e);
  });

  req.write(JSON.stringify(notificationData));
  req.end();
}
