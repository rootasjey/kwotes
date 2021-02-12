import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { checkUserIsSignedIn } from './utils';

const firestore = adminApp.firestore();

/**
 * Delete an user's quotes list.
 * Add a new document to `todelete` collection 
 * as the quote sub-collection `list/quotes/{quoteId}` will be delete later.
 */
export const deleteList = functions
  .region('europe-west3')
  .https
  .onCall(async (data: DeleteListParams, context) => {
    const userAuth = context.auth;
    const { listId, idToken } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    await checkUserIsSignedIn(context, idToken);

    if (!listId) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with one argument "listId" which is the list to delete.`
      );
    }

    const listSnapshot = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .collection('lists')
      .doc(listId)
      .get();


    const listData = listSnapshot.data();

    if (!listSnapshot.exists || !listData) {
      return {
        success: false,
        error: {
          message: "This list doesn't exist anymore.",
        },
        uid: userAuth.uid,
        target: {
          type: 'list',
          id: listId,
          date: Date.now(),
        }
      }
    }

    await firestore
      .collection('todelete')
      .doc(listId)
      .set({
        doc: {
          id: listId,
          conceptualType: 'list',
          dataType: 'subcollection',
          hasChildren: true,
        },
        path: `users/${userAuth.uid}/lists/${listId}/quotes`,
        task: {
          createdAt: Date.now(),
          done: false,
          items: {
            deleted: 0,
            total: listData.itemsCount ?? 0,
          },
          updatedAt: Date.now(),
        },
        user: {
          id: userAuth.uid,
        },
      });

    await firestore
      .collection('users')
      .doc(userAuth.uid)
      .collection('lists')
      .doc(listId)
      .delete();

    return {
      user: {
        id: userAuth.uid,
      },
      target: {
        type: 'list',
        id: listId,
        date: Date.now(),
      }
    }
  });
