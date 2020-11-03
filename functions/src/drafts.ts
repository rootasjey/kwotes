import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const firestore = adminApp.firestore();

export const onDraftAdded = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/drafts/{draftId}')
  .onCreate(async ({}, context) => {
    const user = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    if (!user.exists) { return; }
    
    const userData = user.data();
    if (!userData) { return; }

    const userDrafts: number = userData.stats.drafts ?? 0;
    
    return await user.ref
      .update('stats.drafts', userDrafts + 1);
  });

export const onDraftDeleted = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/drafts/{draftId}')
  .onDelete(async ({}, context) => {
    const user = await firestore
      .collection('users')
      .doc(context.params.userId)
      .get();

    if (!user.exists) { return; }

    const userData = user.data();
    if (!userData) { return; }

    const userDrafts: number = userData.stats.drafts ?? 0;

    return await user.ref
      .update('stats.drafts', Math.max(0, userDrafts - 1));
  });
