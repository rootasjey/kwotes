import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { checkUserIsSignedIn } from './utils';

const firestore = adminApp.firestore();

/**
 * Validate temporary quote
 * -> Add new quote doc & delete temp quote doc.
 * -> Format data (author, reference, comments).
 */
export const validate = functions
  .region('europe-west3')
  .https
  .onCall(async (data, context) => {
    const userAuth = context.auth;
    const { tempQuoteId, idToken } = data;

    // 0.Check authentication & rights.
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
        `You got a ghost. This user doesn't seem to exist.,`
      );
    }

    const userRights = userData.rights;
    const manageQuoteRight = userRights['user:managequote'];

    if (!manageQuoteRight) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the right to perform this action.,`
      );
    }

    // 1.Get temp quote.
    const tempQuoteDoc = await firestore
      .collection('tempquotes')
      .doc(tempQuoteId)
      .get();

    const tempQuoteData = tempQuoteDoc.data();

    if (!tempQuoteDoc.exists || !tempQuoteData) {
      throw new functions.https.HttpsError(
        'data-loss',
        `Sorry we didn't find your temporary quote. It may have been deleted.`,
      );
    }

    // 2.Create or get reference if any.
    const reference = await createOrGetReference(tempQuoteData);

    // 3.Create or get author if any.
    const author = await createOrGetAuthor(tempQuoteData, reference);

    // 4.Create topics map.
    const topics = tempQuoteData.topics;

    // 5.Format data and add new quote.
    const newQuote = await firestore
      .collection('quotes')
      .add({
        author: {
          id: author.id,
          name: author.name,
        },
        createdAt: adminApp.firestore.Timestamp.now(),
        lang: tempQuoteData.lang,
        links: [],
        reference: {
          id: reference.id,
          name: reference.name,
        },
        name: tempQuoteData.name,
        region: tempQuoteData.region,
        stats: {
          likes: 0,
          shares: 0,
        },
        topics,
        updatedAt: adminApp.firestore.Timestamp.now(),
        user: {
          id: userAuth.uid,
        },
      });

    // 6.Create comment if any.
    await createComments(
      tempQuoteData, 
      newQuote.id, 
      userAuth.uid,
    );

    // 7.Delete temp quote.
    await tempQuoteDoc.ref.delete();

    return {
      success: true,
      quote: {
        id: newQuote.id,
      },
    };
  });

async function createComments(
  tempQuoteData: any, 
  quoteId: string, 
  userId: string,
) {
  const comments = tempQuoteData.comments;

  for await (const comment of comments) {
    await firestore
      .collection('comments')
      .add({
        commentId: '',
        createdAt: adminApp.firestore.Timestamp.now(),
        level: 0,
        name: comment,
        quoteId,
        updatedAt: adminApp.firestore.Timestamp.now(),
        user: {
          id: userId,
        },
      });
  }
}

async function createOrGetAuthor(tempQuoteData: any, refDoc: any) {
  const author = tempQuoteData.author;

  if (author.name.length === 0 && author.id.length === 0) {
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

    return { ...author, ...{
      id: anonymousAuthorDoc.id,
      name: anonymousAuthorData.name,
    }};
  }

  if (author.id.length > 0) {
    return author;
  }

  const newAuthorDoc = await firestore
    .collection('authors')
    .add({
      ...author,
      ...{
        createdAt: adminApp.firestore.Timestamp.now(),
        updatedAt: adminApp.firestore.Timestamp.now(),
        fromReference: {
          id: author.isFictional ? refDoc.id : '',
        },
      },
    });

  return {
    ...author,
    ...{
      id: newAuthorDoc.id,
    }
  }
}

async function createOrGetReference(data: any) {
  const reference = {
    id: '',
    lang: 'en',
    links: [],
    name: '',
    release: {
      original: null,
      beforeJC: false,
    },
    summary: '',
    type: {
      primary: '',
      secondary: '',
    },
    urls: {
      amazon: '',
      facebook: '',
      image: '',
      instagram: '',
      netflix: '',
      primeVideo: '',
      twitch: '',
      twitter: '',
      website: '',
      wikipedia: '',
      youtube: '',
    },
  };

  if (data.references.length === 0) {
    return reference;
  }

  const first = data.references[0];

  if (first.id.length > 0) {
    return { ...reference, ...{
      id: first.id,
      name: first.name,
    }};
  }

  const newReferenceDoc = await firestore
    .collection('references')
    .add({ ...reference, ...{
      createdAt: adminApp.firestore.Timestamp.now(),
      lang: first.lang ?? 'en',
      name: first.name,
      release: {
        original: first.release.original,
        beforeJS: first.release.beforeJC,
      },
      summary: first.summary,
      type: {
        primary: first.type.primary,
        secondary: first.type.secondary,
      },
      updatedAt: adminApp.firestore.Timestamp.now(),
      urls: {
        amazon    : first.urls.amazon,
        facebook  : first.urls.facebook,
        image     : first.urls.image,
        instagram : first.urls.instagram,
        netflix   : first.urls.netflix,
        primeVideo: first.urls.primeVideo,
        twitch    : first.urls.twitch,
        twitter   : first.urls.twitter,
        website   : first.urls.website,
        wikipedia : first.urls.wikipedia,
        youtube   : first.urls.youtube,
      },
    }});

  reference.id = newReferenceDoc.id;
  reference.name = first.name;
  return reference;
}
