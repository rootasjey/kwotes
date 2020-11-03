import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

export const onListAdded = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/lists/{listId}')
  .onCreate(async ({}, context) => {
    const user = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    if (!user.exists) { return; }
    
    const userData = user.data();
    if (!userData) { return; }

    const userLists: number = userData.stats.lists ?? 0;
    
    return await user.ref
      .update('stats.lists', userLists + 1);
  });

export const onListDeleted = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/lists/{listId}')
  .onDelete(async ({}, context) => {
    const user = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    if (!user.exists) { return; }

    const userData = user.data();
    if (!userData) { return; }

    const userLists: number = userData.stats.lists ?? 0;

    return await user.ref
      .update('stats.lists', Math.max(0, userLists - 1));
  });
