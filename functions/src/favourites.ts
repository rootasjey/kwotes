import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

export const onFavAdded = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/favourites/{quoteId}')
  .onCreate(async ({}, context) => {
    const quoteDoc = await firestore
      .collection('quotes')
      .doc(context.params.quoteId)
      .get();

    const quoteData = quoteDoc.data();
    if (!quoteData) {
      return;
    }

    const quoteLikes: number = quoteData.stats?.likes ?? 0;

    const user = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    const userData = user.data();

    if (userData) {
      const userFav: number = userData.stats.fav ?? 0;
      await user.ref.update('stats.fav', userFav + 1);
    }
      
    return await firestore
      .collection('quotes')
      .doc(context.params.quoteId)
      .update('stats.likes', quoteLikes + 1);
  });

export const onFavDeleted = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/favourites/{quoteId}')
  .onDelete(async (snapshot, context) => {
    const quoteData = snapshot.data();
    if (!quoteData) { return; }

    const quoteFav: number = quoteData.stats?.likes ?? 0;

    const user = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    const userData = user.data();

    if (userData) {
      const userFav: number = userData.stats.fav ?? 0;
      await user.ref.update('stats.fav', Math.max(0, userFav - 1));
    }

    return await firestore
      .collection('quotes')
      .doc(context.params.quoteId)
      .update('stats.likes', Math.max(0, quoteFav - 1));
  });
