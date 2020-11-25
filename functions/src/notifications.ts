import * as functions from 'firebase-functions';

import { adminApp } from './adminApp';
import { sendNotification } from './utils';

const env = functions.config();
const firestore = adminApp.firestore();

export const incrementStatsAndSendPush = functions
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

    const notifications = userData.stats.notifications;
    const total: number = notifications.total + 1;
    const unread: number = notifications.unread + 1;

    await firestore
      .collection('users')
      .doc(userId)
      .update({
        'stats.notifications': {
          total: total,
          unread: unread,
        }
      });

    const notifData = notifSnapshot.data();
    const subject: string = notifData.subject;

    if (subject == 'tempquotes') {
      return handleTempQuoteValidation({ userId, userData, notifSnapshot });
    }

    return true;
  });

export const decrementStats = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/notifications/{notificationId}')
  .onDelete(async (notifSnapshot, context) => {
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

    let total: number = userData.stats.notifications.total - 1;
    let unread: number = userData.stats.notifications.unread - 1;

    total = Math.max(total, 0);
    unread = Math.max(unread, 0);

    await firestore
      .collection('users')
      .doc(userId)
      .update({
        'stats.notifications': {
          total: total,
          unread: unread,
        }
      });

    return true;
  });

function handleTempQuoteValidation(params: NotifFuncParams) {
  const { userId, userData, notifSnapshot } = params;
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
    include_external_user_ids: [userId],
    ios_attachments: { id1: '' },
    big_picture: '',
    ios_badgeType: "Increase",
    ios_badgeCount: 1,
    thread_id: 'tempquotes', // iOS 12+ notification grouping
  });

  return true;
}
