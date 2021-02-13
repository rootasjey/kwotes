import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { checkUserIsSignedIn } from './utils';

const firebaseTools = require('firebase-tools');
const firestore = adminApp.firestore();

/**
 * Add quotes to a target list.
 */
export const addQuotes = functions
  .region('europe-west3')
  .https
  .onCall(async (params: UpdateListItemsParams, context) => {
    const userAuth = context.auth;
    const { idToken, quoteIds, listId } = params;

    handleAddQuoteExceptions({
      listParams: params, 
      context, 
      operationType: "add",
    });

    await checkUserIsSignedIn(context, idToken);
    if (!userAuth) { return; } // already checked in handleAddQuoteExceptions().

    const quotesListDoc = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .collection('lists')
      .doc(listId)
      .get();

    if (!quotesListDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        `The target list [${listId}] was not found. 
        It may have been deleted.`,
      );
    }

    for await (const quoteId of quoteIds) {
      const quoteDoc = await firestore
        .collection('quotes')
        .doc(quoteId)
        .get();

      const quoteData = quoteDoc.data();

      if (!quoteDoc.exists || !quoteData) {
        continue;
      }

      await quotesListDoc.ref
        .collection('quotes')
        .doc(quoteDoc.id)
        .set({
          author: quoteData.author,
          createdAt: adminApp.firestore.FieldValue.serverTimestamp(),
          name: quoteData.name,
          topics: quoteData.topics,
          reference: quoteData.reference,
        });
    }

    return {
      success: true,
      list: { id: quotesListDoc.id },
      quoteIds,
    };
  });

/**
 * Create a list.
 * Immediately add quotes (from argument) if specified.
 */
export const createList = functions
  .region('europe-west3')
  .https
  .onCall(async (data: CreateListParams, context) => {
    const userAuth = context.auth;
    const { 
      quoteIds, 
      idToken, 
      name, 
      isPublic,
      description, 
    } = sanitizeCreateListParams(data);

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    await checkUserIsSignedIn(context, idToken);

    const quotesListDoc = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .collection('lists')
      .add({
        createdAt: adminApp.firestore.FieldValue.serverTimestamp(),
        description: description,
        name: name,
        itemsCount: 0,
        icon: {
          localType: '',
          url: '',
        },
        isPublic: isPublic,
        updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
      });

    if (!quoteIds || quoteIds.length === 0) {
      return {
        success: true,
        list: {
          id: quotesListDoc.id,
        },
      };
    }

    for await (const quoteId of quoteIds) {
      const quoteDoc = await firestore
        .collection('quotes')
        .doc(quoteId)
        .get();

      const quoteData = quoteDoc.data();

      if (!quoteDoc.exists || !quoteData) {
        continue;
      }

      await quotesListDoc
        .collection('quotes')
        .doc(quoteDoc.id)
        .set({
          author: quoteData.author,
          createdAt: adminApp.firestore.FieldValue.serverTimestamp(),
          name: quoteData.name,
          topics: quoteData.topics,
          reference: quoteData.reference,
        });
    }

    return {
      success: true,
      list: {
        id: quotesListDoc.id,
      },
    };
  });

/**
 * Delete a user's quotes list.
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
        `The function must be called with [listId] argument
         which is the list to delete.`
      );
    }

    const listSnapshot = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .collection('lists')
      .doc(listId)
      .get();

    if (!listSnapshot.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        `This collection doesn't exist anymore. It may have been deleted.`,
      );
    }

    try {
      await firebaseTools.firestore
        .delete(listSnapshot.ref.path, {
          project: process.env.GCLOUD_PROJECT,
          recursive: true,
          yes: true,
        });

      return {
        success: true,
        user: {
          id: userAuth.uid,
        },
        target: {
          type: 'list',
          id: listId,
        }
      };
    } catch (error) {
      console.error(error);

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
          path: listSnapshot.ref.path,
          user: {
            id: userAuth.uid,
          },
        });

      throw new functions.https.HttpsError(
        'internal',
        `There was an unexpected issue while deleting the list.
        Please try again or contact the support for more information.`,
      );
    }
  });

/**
 * Delete multiple user's lists.
 */
export const deleteLists = functions
  .region('europe-west3')
  .https
  .onCall(async (data: DeleteListsParams, context) => {
    const userAuth = context.auth;
    const { listIds, idToken } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    await checkUserIsSignedIn(context, idToken);

    if (!listIds || listIds.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with one argument [listIds]
         which is the array of lists to delete.`
      );
    }

    for await (const listId of listIds) {
      const listSnapshot = await firestore
        .collection('users')
        .doc(userAuth.uid)
        .collection('lists')
        .doc(listId)
        .get();
  
      if (!listSnapshot.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          `This collection doesn't exist anymore. It may have been deleted.`,
        );
      }
      
      try {
        await firebaseTools.firestore
          .delete(listSnapshot.ref.path, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
          });

      } catch (error) {
        console.error(error);

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
            path: listSnapshot.ref.path,
            user: {
              id: userAuth.uid,
            },
          });
      }
    }

    return {
      success: true,
      user: {
        id: userAuth.uid,
      },
      listIds,
    };
  });


/**
 * Remove quotes from a target list.
 */
export const removeQuotes = functions
  .region('europe-west3')
  .https
  .onCall(async (params: UpdateListItemsParams, context) => {
    const userAuth = context.auth;
    const { idToken, quoteIds, listId } = params;

    handleAddQuoteExceptions({
      listParams: params,
      context,
      operationType: "remove",
    });

    await checkUserIsSignedIn(context, idToken);
    if (!userAuth) { return; } // already checked in handleAddQuoteExceptions().

    const quotesListDoc = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .collection('lists')
      .doc(listId)
      .get();

    if (!quotesListDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        `The target list [${listId}] was not found. 
        It may have been deleted.`,
      );
    }

    for await (const quoteId of quoteIds) {
      await quotesListDoc.ref
        .collection('quotes')
        .doc(quoteId)
        .delete();
    }

    return {
      success: true,
      list: { id: quotesListDoc.id },
      quoteIds,
    };
  });

/**
 * Update list's properties (name, description, isPublic, ...).
 */
export const updateList = functions
  .region('europe-west3')
  .https
  .onCall(async (params: UpdateListParams, context) => {
    const userAuth = context.auth;
    const { idToken, listId } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    await checkUserIsSignedIn(context, idToken);

    const quotesListDoc = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .collection('lists')
      .doc(listId)
      .get();

    if (!quotesListDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        `The target list [${listId}] was not found. 
        It may have been deleted.`,
      );
    }

    const payload: Record<string, any> = {};

    if (params.name && typeof params.name === 'string') {
      payload.name = params.name;
    }

    if (typeof params.description === 'string') {
      payload.description = params.description;
    }

    if (typeof params.isPublic === 'boolean') {
      payload.isPublic = params.isPublic;
    }

    if (Object.keys(payload).length > 0) {
      payload.updatedAt = adminApp.firestore.FieldValue.serverTimestamp();
      await quotesListDoc.ref.update(payload);
    }

    return {
      success: true,
      list: { id: quotesListDoc.id },
    };
  });

// --------
// Helpers
// --------
interface HandleAddQuoteExceptions {
  listParams: UpdateListItemsParams;
  context: functions.https.CallableContext;
  operationType: string;
}

/**
 * Check input parameters.
 * @param params - Cloud function parameters.
 */
function handleAddQuoteExceptions(params: HandleAddQuoteExceptions) {
  const userAuth = params.context.auth;
  const { quoteIds, listId } = params.listParams;
  const operationType = params.operationType ?? 'add';

  if (!userAuth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      `The function must be called from an authenticated user.`,
    );
  }

  if (!listId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Missing [listId] argument which is a string. 
        [listId] is the target list to ${operationType} quotes.`,
    );
  }

  if (!quoteIds) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Missing [quoteIds] which is an non-empty string array. 
        They are the quotes to ${operationType}.`,
    );
  }

  if (!Array.isArray(quoteIds)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The argument [quoteIds] is not an array. 
        Please provide a string array representing 
        the quotes to ${operationType}.`,
    );
  }

  if (quoteIds.length === 0) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The argument [quoteIds] is an empty array.
        The array must have at least one string 
        (representing a quote to ${operationType}).`,
    );
  }
}

/**
 * Ensure that specified paramters are correct.
 * @param createListParams - CreateList's parameters.
 */
function sanitizeCreateListParams(createListParams: CreateListParams) {
  const response = {
    quoteIds: Array<string>(),
    idToken: createListParams.idToken,
    iconType: '',
    name: `list-${Date.now()}`,
    isPublic: false,
    description: '',
  };

  response.quoteIds = [];

  if (createListParams.name && typeof createListParams.name === 'string') {
    response.name = createListParams.name;
  }

  if (createListParams.description && typeof createListParams.description === 'string') {
    response.description = createListParams.description;
  }

  if (createListParams.isPublic && typeof createListParams.isPublic === 'boolean') {
    response.isPublic = createListParams.isPublic;
  }

  if (createListParams.quoteIds && Array.isArray(createListParams.quoteIds)) {
    response.quoteIds = createListParams.quoteIds;
  }

  return response;
}
