import * as functions from 'firebase-functions';

import { adminApp } from './adminApp';
import { sendNotification } from './utils';

const env = functions.config();
const firestore = adminApp.firestore();

export const notifyQuoteInValidation = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/notifications/{notificationId}')
  .onCreate(async (notifSnapshot, context) => {
    const userId: string = context.params.userId;

    const userSnapshot = await firestore
      .collection('users')
      .doc(userId)
      .get();

    if (!userSnapshot.exists) {
      return false;
    }

    const userData = userSnapshot.data();
    if (!userData) {
      return false;
    }

    const notifData = notifSnapshot.data();
    const subject: string = notifData.subject;

    if (subject == 'tempquotes') {
      return handleTempQuoteValidation({ userData, notifSnapshot });
    }

    return true;
  });

function handleTempQuoteValidation(params: NotifFuncParams) {
  const { userData, notifSnapshot } = params;
  const notifData = notifSnapshot.data();

  const sendPushNotification: boolean = userData
    .settings?.notifications?.push?.tempquotes;

  if (!sendPushNotification) {
    return false;
  }


  sendNotification({
    adm_group: 'tempquotes', // Amazon notification grouping
    android_group: 'tempquotes', // Android notification grouping
    app_id: env.onesignal.appid,
    contents: { en: notifData.body },
    data: {
      notificationid: notifSnapshot.id,
      type: 'tempquotes',
    },
    filters: [{ field: "tag", key: "quotidian", relation: "=", value: "en" }],
    ios_attachments: { id1: '' },
    big_picture: '',
    ios_badgeType: "Increase",
    ios_badgeCount: 1,
    thread_id: 'tempquotes', // iOS 12+ notification grouping
  });

  return true;
}
