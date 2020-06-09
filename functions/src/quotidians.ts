import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

import { adminApp } from './adminApp';

const firestore = adminApp.firestore();
const fcm = adminApp.messaging();

export const quotidiansMobileEN = functions
  .region('europe-west3')
  .pubsub
  .schedule('every day 08:00')
  .onRun(async (context) => {
    const date = new Date(context.timestamp);

    const monthNumber = date.getMonth() + 1;

    const month = monthNumber < 10 ? `0${monthNumber}` : monthNumber;
    const day = date.getDate() < 10 ? `0${date.getDate()}` : date.getDate();

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
      data: {
        path: `/quote/${data['quote']['id']}`,
      },
      notification: {
        title: 'Quotidian',
        body: quoteName,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      }
    };

    return await fcm.sendToTopic('quotidians-mobile-en', payload);
  });

export const quotidiansMobileFR = functions
  .region('europe-west3')
  .pubsub
  .schedule('every day 08:00')
  .onRun(async (context) => {
    const date = new Date(context.timestamp);

    const monthNumber = date.getMonth() + 1;

    const month = monthNumber < 10 ? `0${monthNumber}` : monthNumber;
    const day = date.getDate() < 10 ? `0${date.getDate()}` : date.getDate();

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
      data: {
        path: `/quote/${data['quote']['id']}`,
      },
      notification: {
        title: 'Quotidian',
        body: quoteName,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
    };

    return await fcm.sendToTopic('quotidians-mobile-fr', payload);
  });
