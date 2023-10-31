import * as functions from 'firebase-functions';
import { deepEqual } from 'fast-equals';
import { adminApp } from './adminApp';
import { 
  checkUserIsSignedIn,
  sanitizeTopics,
} from './utils';

const firestore = adminApp.firestore();

/**
 * Trigger when a new quote is created.
 * Check all parameters and deep nested properties.
 * Process author and reference.
 */
export const onCreate = functions
  .region("europe-west3")
  .firestore
  .document("quotes/{quoteId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    const objectId: string = snapshot.id;

    // 1. Check user existence and rights.
    const userId: string = data.user.id;
    const userSnapshot = await firestore
      .collection("users")
      .doc(userId)
      .get();

    const userData = userSnapshot.data();
    if (!userSnapshot.exists || !userData) {
      await snapshot.ref.delete();
      throw new functions.https.HttpsError(
        "not-found",
        `User ${userId} not found. Deleted quote ${objectId}.`,
      );
    }

    const userRights = userData.rights;
    const proposeQuoteRight = userRights["user:propose_quotes"];

    if (!proposeQuoteRight) {
      await snapshot.ref.delete();
      throw new functions.https.HttpsError(
        'permission-denied',
        `User ${userId} doesn't have the right to perform this action.,`
      );
    }
    
    // 2. Check reference.
    // Check if the reference exists or create a new one if not.
    // We need to do this before author creation in case the author is fictional
    // we'll be able to link them to the reference.
    const reference = await createOrGetReference(data.reference);
    
    // 3. Check author
    // Check if the author exists or create a new one if not.
    const author = await createOrGetAuthor(data.author, reference.id);

    return snapshot.ref.update({
      author,
      created_at: adminApp.firestore.Timestamp.now(),
      metrics: {
        likes: 0,
        shares: 0,
      },
      reference,
      topics: sanitizeTopics(data.topics),
      updated_at: adminApp.firestore.Timestamp.now(),
    });
  })

export const onUpdate = functions
  .region("europe-west3")
  .firestore
  .document("quotes/{quoteId}")
  .onUpdate(async (snapshot, context) => {
    if (!snapshot.after.exists) { return; }
    if (snapshot.after.isEqual(snapshot.before)) {
      functions.logger.info('(1) Quote unchanged. Exited at snapshot.after.isEqual.');
      return;
    }

    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();

    if (areQuotesEqual(beforeData, afterData)) {
      functions.logger.info('(2) Quote unchanged. Exited at areQuotesEqual.');
      return;
    }

    const author = afterData.author.id
      ? afterData.author 
      : { id: 'TySUhQPqndIkiVHWVYq1', name: 'Anonymous' };

    return snapshot.after.ref.update({
      author,
      topics: sanitizeTopics(afterData.topics),
      updated_at: adminApp.firestore.Timestamp.now(),
    });
  });

/**
 * Delete a published quote 
 * with its associated author & reference if specified.
 * Update stats too.
 */
export const deleteQuotes = functions
  .region('europe-west3')
  .https
  .onCall(async (params, context) => {
    const userAuth = context.auth;
    const { quoteIds, idToken } = params;
    const deleteAuthor = params.deleteAuthor ?? false;
    const deleteReference = params.deleteReference ?? false;

    if (!quoteIds) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Missing [quoteIds] (array of strings) argument. 
        The function must be called with [quoteIds]
        representing the quotes to delete.`,
      );
    }

    if (!Array.isArray(quoteIds)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [quoteIds] argument is not an array, but a ${typeof quoteIds}. 
        Please provid a valid array of strings.`,
      );
    }

    if (quoteIds.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [quoteIds] argument is an empty array. 
        Please provid an array containing valid strings.`,
      );
    }

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    await checkUserIsSignedIn(context, idToken);

    const userDoc = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .get();

    const userData = userDoc.data();

    if (!userDoc.exists || !userData) {
      throw new functions.https.HttpsError(
        'not-found',
        `You caught a ghost. This user doesn't seem to exist.,`
      );
    }

    const userRights = userData.rights;
    const manageQuoteRight = userRights['user:manage_quotes'];

    if (!manageQuoteRight) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the right to perform this action.,`
      );
    }

    const payloadArray = Array<any>();

    for await (const quoteId of quoteIds) {
      const quoteDoc = await firestore
        .collection('quotes')
        .doc(quoteId)
        .get();

      const quoteData = quoteDoc.data();

      if (!quoteDoc.exists || !quoteData) {
        throw new functions.https.HttpsError(
          'data-loss',
          `The document (quote) [${quoteId}] doesn't exist. 
          It may have been deleted.`,
        );
      }

      const authorId: string = quoteData.author.id;
      const referenceId: string = quoteData.reference.id;
      await quoteDoc.ref.delete();

      const payload: Record<string, any> = {
        success: true,
        quote: {
          id: quoteId,
        },
      };

      if (deleteAuthor) {
        await deleteQuoteAuthor(authorId);
        payload.author = {
          id: authorId,
          deleted: deleteAuthor,
        };
      }

      if (deleteReference) {
        await deleteQuoteReference(referenceId);
        payload.reference = {
          id: referenceId,
          deleted: deleteReference,
        };
      }

      payloadArray.push(payload);      
    }

    return {
      success: true,
      entries: payloadArray,
    };
  });

/**
 * Delete the author and update stats.
 * @param authorId - Author's id to delete.
 */
async function deleteQuoteAuthor(authorId: string) {
  const authorDoc = await firestore
    .collection('authors')
    .doc(authorId)
    .get();

  if (!authorDoc.exists) {
    return;
  }

  await authorDoc.ref.delete();
}

/**
 * Delete the specified reference and update stats.
 * @param referenceId - Reference's id to delete.
 */
async function deleteQuoteReference(referenceId: string) {
  const referenceDoc = await firestore
    .collection('references')
    .doc(referenceId)
    .get();
    
  const referenceData = referenceDoc.data();

  if (!referenceDoc.exists || !referenceData) {
    return;
  }

  await referenceDoc.ref.delete();
}

/**
 * Return the author with the associated [id] if not empty.
 * Otherwise, create a new author with the specified fields.
 * @param tempQuoteData - Firestore TempQuote's data.
 * @param refDoc - Firestore TempQuote document.
 */
async function createOrGetAuthor(author: IAuthor, referenceId: string = ''): Promise<{ id: string, name: string }> {
  if (!author.name && !author.id) {
    const anonymousAuthorDoc = await firestore
      .collection('authors')
      .doc('TySUhQPqndIkiVHWVYq1')
      .get();

    const anonymousAuthorData = anonymousAuthorDoc.data();
    if (!anonymousAuthorDoc.exists || !anonymousAuthorData) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Couldn't retrieve anonymous author. Please try again later or contact us.`,
      );
    }

    return {
      id: anonymousAuthorDoc.id,
      name: anonymousAuthorData.name,
    };
  }

  if (author.id) {
    const existingAuthorSnapshot = await firestore
      .collection("authors")
      .doc(author.id)
      .get();

    const existingAuthorData = existingAuthorSnapshot.data();
    if (!existingAuthorSnapshot.exists || !existingAuthorData) {
      return {
        id: '',
        name: '',
      };
    }

    return {
      id: existingAuthorSnapshot.id,
      name: existingAuthorData.name,
    }
  }

  const newAuthorSnapshot = await firestore
    .collection('authors')
    .add({
      ...author,
      ...{
        created_at: adminApp.firestore.Timestamp.now(),
        updated_at: adminApp.firestore.Timestamp.now(),
        from_reference: {
          id: author.is_fictional ? referenceId : '',
        },
      },
    });

  const newAuthorDocument = await newAuthorSnapshot.get();
  const newAuthorData = newAuthorDocument.data();

  return {
    id: newAuthorSnapshot.id,
    name: newAuthorData?.name ?? '',
  }
}

/**
 * Return the reference with the associated [id] if not empty.
 * Otherwise, create a new reference with the specified fields.
 * @param data - Firestore's reference data.
 */
async function createOrGetReference(reference: IReference): Promise<{ id: string, name: string }> {
  if (!reference || (!reference.name && !reference.id)) {
    return {
      id: '',
      name: '',
    };
  }

  if (reference.id) {
    const existingReferenceSnapshot = await firestore
      .collection("references")
      .doc(reference.id)
      .get();

    const existingReferenceData = existingReferenceSnapshot.data();
    if (!existingReferenceSnapshot.exists || !existingReferenceData) {
      return {
        id: '',
        name: '',
      };
    }
    
    return {
      id: existingReferenceSnapshot.id,
      name: existingReferenceData.name as string,
    }
  }

  const newReferenceSnapshot = await firestore
    .collection("references")
    .add({
      ...reference,
      ...{
        created_at: adminApp.firestore.Timestamp.now(),
        updated_at: adminApp.firestore.Timestamp.now(),
      },
    });

  const newReferenceDocument = await newReferenceSnapshot.get();
  const newReferenceData = newReferenceDocument.data();
  
  return {
    id: newReferenceSnapshot.id,
    name: newReferenceData?.name ?? '',
  }
}


/**
 * Compare two quotes data on update and return true if they are equal.
 * @param before Data before update
 * @param after Data after update
 * @returns Returns true if the data are equal
 */
function areQuotesEqual(before: FirebaseFirestore.DocumentData, after: FirebaseFirestore.DocumentData) {
  functions.logger.info(`
  deepEqual(before.author, after.author): ${deepEqual(before.author, after.author)} | 
  before.language === after.language: ${before.language === after.language} | 
  deepEqual(before.metrics, after.metrics): ${deepEqual(before.metrics, after.metrics)} | 
  deepEqual(before.reference, after.reference): ${deepEqual(before.reference, after.reference)} | 
  deepEqual(before.topics, after.topics): ${deepEqual(before.topics, after.topics)}`
  );
  return (
    deepEqual(before.author, after.author)
    && before.language === after.language
    && deepEqual(before.metrics, after.metrics)
    && deepEqual(before.reference, after.reference)
    && deepEqual(before.topics, after.topics)
  );
}
