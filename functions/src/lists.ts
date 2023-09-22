import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
const firestore = adminApp.firestore();

/**
 * Triggers when a quote is created in a list.
 * Update the list's properties (last updated).
 */
export const onAddQuote = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/lists/{listId}/quotes/{quoteId}')
  .onCreate(async (snapshot, context) => {
    const { userId, listId } = context.params;

    await snapshot.ref.update({ // add created_at field to newly created quote
      created_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });

    return firestore
      .collection('users')
      .doc(userId)
      .collection('lists')
      .doc(listId)
      .update({
        item_count: adminApp.firestore.FieldValue.increment(1),
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      });
  });

/**
 * Triggers when a list is created.
 * Add additional properties (e.g. last updated).
 */
export const onCreate = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/lists/{listId}')
  .onCreate(async (snapshot, context) => {
    return snapshot
      .ref
      .update({
        item_count: 0,
        created_at: adminApp.firestore.FieldValue.serverTimestamp(),
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      });
  })

/**
 * Triggers when a list is deleted.
 */
export const onDelete = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/lists/{listId}')
  .onDelete(async (listSnapshot, context) => {
    return firestore.recursiveDelete(listSnapshot.ref);
    // await firebaseTools.firestore
    //   .delete(listSnapshot.ref.path, {
    //     project: process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT,
    //     recursive: true,
    //     yes: true,
    //   });
  });

/**
 * Triggers when a quote is removed from a list.
 * Update the list's properties (last updated).
 */
export const onRemoveQuote = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/lists/{listId}/quotes/{quoteId}')
  .onDelete(async ({ }, context) => {
    const { userId, listId } = context.params;

    return firestore
      .collection('users')
      .doc(userId)
      .collection('lists')
      .doc(listId)
      .update({
        item_count: adminApp.firestore.FieldValue.increment(-1),
        updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
      });
  });

/**
 * Triggers when a list is deleted.
 * Recursively delete the list's quotes (the subcollection).
 **/
export const onUpdate = functions
  .region('europe-west3')
  .firestore
  .document('users/{userId}/lists/{listId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    if (!beforeData || !afterData) {
      return;
    }

    if (change.before.isEqual(change.after)) {
      return;
    }

    if (beforeData.name === afterData.name && beforeData.description === afterData.description
      && beforeData.is_public === afterData.is_public) {
      return;
    }

    return change.after.ref.update({
      updated_at: adminApp.firestore.FieldValue.serverTimestamp(),
    });
  });
