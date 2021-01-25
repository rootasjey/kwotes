import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

export const onTempQuoteAdded = functions
  .region('europe-west3')
  .firestore
  .document('tempquotes/{tempQuoteId}')
  .onCreate(async (snapshot) => {
    const quoteData = snapshot.data();
    if (!quoteData) { return; }

    const userId: string = quoteData.user.id;

    const user = await firestore
      .collection('users')
      .doc(userId)
      .get();

    const userData = user.data();
    if (!userData) { return; }

    const userTempQuotes: number = userData.stats.tempQuotes ?? 0;
    
    return await user.ref
      .update('stats.tempQuotes', userTempQuotes + 1);
  });

export const onTempQuoteDeleted = functions
  .region('europe-west3')
  .firestore
  .document('tempquotes/{tempQuoteId}')
  .onDelete(async (snapshot) => {
    const quoteData = snapshot.data();
    if (!quoteData) { return; }

    const userId: string = quoteData.user.id;

    const user = await firestore
      .collection('users')
      .doc(userId)
      .get();

    const userData = user.data();
    if (!userData) { return; }

    const userTempQuotes: number = userData.stats.tempQuotes ?? 0;
    
    return await user.ref
      .update('stats.tempQuotes', Math.max(0, userTempQuotes - 1));
  });
