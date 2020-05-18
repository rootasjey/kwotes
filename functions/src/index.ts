import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const firestore = admin.firestore();
const fcm = admin.messaging();

export const incrementQuoteQuota = functions
  .region('europe-west3')
  .firestore
  .document('tempquotes/{tempquoteId}')
  .onCreate(async (snapshot, context) => {
    const snapshotData = snapshot.data();
    if (!snapshotData) { return; }

    const userUid = snapshotData.user.id;
    if (!userUid) { return; }

    const userDoc = await firestore
      .collection('users')
      .doc(userUid)
      .get();

    if (!userDoc.exists) { return; }

    const data = userDoc.data();
    if (!data) { return; }

    const serverDate = new Date(context.timestamp);
    const quota = data.quota;

    let date = quota.date !== null && typeof quota.date !== 'undefined' ?
      quota.date.toDate() :
      new Date('January 1');

    let current: number = quota['current'];

    if (date.getDate() !== serverDate.getDate() ||
      date.getMonth() !== serverDate.getMonth() ||
      date.getFullYear() !== serverDate.getFullYear()) {

      current = 0;
      date = serverDate;
    }

    current += 1;

    return await userDoc.ref
      .update({
        'quota.date': admin.firestore.Timestamp.fromDate(date),
        'quota.current': current,
      });
  });

export const quotidiansMobileEN = functions
  .region('europe-west3')
  .pubsub
  .schedule('every day 08:00')
  .onRun(async (context) => {
    const date = new Date(context.timestamp);

    const monthNumber = date.getMonth() + 1;

    const month = monthNumber     < 10 ? `0${monthNumber}`    : monthNumber;
    const day   = date.getDate()  < 10 ? `0${date.getDate()}` : date.getDate();

    const dateId = `${date.getFullYear()}:${month}:${day}:en`;

    console.log(`quotidians EN - ${dateId}`);

    const quotidian = await firestore
      .collection('quotidians')
      .doc(dateId)
      .get();

    if (!quotidian.exists) { return; }

    const data = quotidian.data();
    if (!data) { return; }

    const quoteName = data['quote']['name'];

    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: 'Quotidian',
        body: quoteName,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      }
    };

    return await fcm.sendToTopic('quotidians-en', payload);
  });

export const quotidiansMobileFR = functions
  .region('europe-west3')
  .pubsub
  .schedule('every day 08:00')
  .onRun(async (context) => {
    const date = new Date(context.timestamp);

    const monthNumber = date.getMonth() + 1;

    const month = monthNumber     < 10 ? `0${monthNumber}`    : monthNumber;
    const day   = date.getDate()  < 10 ? `0${date.getDate()}` : date.getDate();

    const dateId = `${date.getFullYear()}:${month}:${day}:fr`;

    console.log(`quotidians FR - ${dateId}`);

    const quotidian = await firestore
      .collection('quotidians')
      .doc(dateId)
      .get();

    if (!quotidian.exists) { return; }

    const data = quotidian.data();
    if (!data) { return; }

    const quoteName = data['quote']['name'];

    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: 'Quotidian',
        body: quoteName,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      }
    };

    return await fcm.sendToTopic('quotidians-fr', payload);
  });
