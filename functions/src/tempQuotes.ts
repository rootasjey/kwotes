import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { checkUserIsSignedIn } from './utils';

const firestore = adminApp.firestore();

/**
 * Create a new temporary quote.
 * Check all parameters and deep nested properties.
 */
export const create = functions
  .region('europe-west3')
  .https
  .onCall(async (data: AddTempQuoteParams, context) => {
    const userAuth = context.auth;
    const { tempQuote } = data;

    if (!tempQuote) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [tempQuote] parameter 
        reprensing the temporary quote to create.`,
      );
    }

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    const userDoc = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .get();

    const userData = userDoc.data();

    if (!userDoc.exists || !userData) {
      throw new functions.https.HttpsError(
        'not-found',
        `You caught a ghost. This user doesn't exist.`,
      );
    }

    const userRights = userData.rights;
    const proposeQuoteRight = userRights['user:proposequote'];

    if (!proposeQuoteRight) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the right to perform this action.`,
      );
    }

    const topics: Record<string, boolean> = {};
    
    for (const topic of tempQuote.topics) {
      topics[topic] = true;
    }

    const name = typeof tempQuote.name === 'string' ? tempQuote.name : '';

    if (!name) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [name] property cannot be empty. 
        Please provide a valid quote string content.`
      );
    }

    const author = sanitizeAuthor(tempQuote.author);
    const reference = sanitizeReference(tempQuote.reference);
    const lang = sanitizeLang(tempQuote.lang);
    const comments = sanitizeComments(tempQuote.comments);

    const tempQuoteDoc = await firestore
      .collection('tempquotes')
      .add({
        author,
        comments,
        createdAt: adminApp.firestore.FieldValue.serverTimestamp(),
        lang,
        name,
        reference,
        topics,
        user: {
          id: userAuth.uid,
        },
        updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
        validation: {
          comment: {
            name: '',
            updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
          },
          status: '',
          updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
        },
      });

    return {
      success: true,
      tempQuote: {
        id: tempQuoteDoc.id,
      },
    };
  });

/**
 * Update an existing temporary quote.
 * Check all parameters and deep nested properties.
 */
export const update = functions
  .region('europe-west3')
  .https
  .onCall(async (data: AddTempQuoteParams, context) => {
    const userAuth = context.auth;
    const { tempQuote } = data;

    if (!tempQuote) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [tempQuote] parameter 
        reprensing the temporary quote to send.`,
      );
    }

    if (!tempQuote.id) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [tempQuote.id] parameter 
        reprensing the temporary quote's id to update.`,
      );
    }

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    const userDoc = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .get();

    const userData = userDoc.data();

    if (!userDoc.exists || !userData) {
      throw new functions.https.HttpsError(
        'not-found',
        `You caught a ghost. This user doesn't exist.`,
      );
    }

    const userRights = userData.rights;
    const proposeQuoteRight = userRights['user:proposequote'];

    if (!proposeQuoteRight) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the right to perform this action.`,
      );
    }

    const topics: Record<string, boolean> = {};
    
    for (const topic of tempQuote.topics) {
      topics[topic] = true;
    }

    const name = typeof tempQuote.name === 'string' ? tempQuote.name : '';

    if (!name) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The [name] property cannot be empty. 
        Please provide a valid quote string content.`
      );
    }

    const author = sanitizeAuthor(tempQuote.author);
    const reference = sanitizeReference(tempQuote.reference);
    const lang = sanitizeLang(tempQuote.lang);
    const comments = sanitizeComments(tempQuote.comments);

    try {
      await firestore
        .collection('tempquotes')
        .doc(tempQuote.id)
        .update({
          author,
          comments,
          createdAt: adminApp.firestore.FieldValue.serverTimestamp(),
          lang,
          name,
          reference,
          topics,
          user: {
            id: userAuth.uid,
          },
          updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
          validation: {
            comment: {
              name: '',
              updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
            },
            status: '',
            updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
          },
        });

      return {
        success: true,
        tempQuote: {
          id: tempQuote.id,
        },
      };

    } catch (error) {
      throw new functions.https.HttpsError(
        'internal',
        `Sorry, there was an error while proposing your quote. ${error}`,
      );
    }
  });

/**
 * Validate temporary quote
 * -> Add new quote doc & delete temp quote doc.
 * -> Format data (author, reference, comments).
 */
export const validate = functions
  .region('europe-west3')
  .https
  .onCall(async (data: ValidateTempQuoteParams, context) => {
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
        `You caught a ghost. This user doesn't exist.`,
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
        reference: {
          id: reference.id,
          name: reference.name,
        },
        name: tempQuoteData.name,
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

/**
 * Create comments documents in the database related to a published quote.
 * @param tempQuoteData - Firestore TempQuote's data.
 * @param quoteId -  Id of the created quote.
 * @param userId - Id of the authenticated user.
 */
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

/**
 * Return the author with the associated [id] if not empty.
 * Otherwise, create a new author with the specified fields.
 * @param tempQuoteData - Firestore TempQuote's data.
 * @param refDoc - Firestore TempQuote document.
 */
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

/**
 * Return the reference with the associated [id] if not empty.
 * Otherwise, create a new reference with the specified fields.
 * @param data - Firestore's reference data.
 */
async function createOrGetReference(data: any) {
  const payload = {
    id: '',
    lang: 'en',
    name: '',
    release: {
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

  const { reference } = data;

  if (!reference || (!reference.name && !reference.id)) {
    return payload;
  }

  if (reference.id.length > 0) {
    return { ...payload, ...{
      id: reference.id,
      name: reference.name,
    }};
  }

  const newReferenceDoc = await firestore
    .collection('references')
    .add({ ...payload, ...{
      createdAt: adminApp.firestore.Timestamp.now(),
      lang: reference.lang ?? 'en',
      name: reference.name,
      release: {
        original: reference.release.original,
        beforeJC: reference.release.beforeJC,
      },
      summary: reference.summary,
      type: {
        primary: reference.type.primary,
        secondary: reference.type.secondary,
      },
      updatedAt: adminApp.firestore.Timestamp.now(),
      urls: {
        amazon    : reference.urls.amazon,
        facebook  : reference.urls.facebook,
        image     : reference.urls.image,
        instagram : reference.urls.instagram,
        netflix   : reference.urls.netflix,
        primeVideo: reference.urls.primeVideo,
        twitch    : reference.urls.twitch,
        twitter   : reference.urls.twitter,
        website   : reference.urls.website,
        wikipedia : reference.urls.wikipedia,
        youtube   : reference.urls.youtube,
      },
    }});

  payload.id = newReferenceDoc.id;
  payload.name = reference.name;
  return payload;
}

/**
 * Return a sanitized [author] object (all fields are checked).
 * @param author - Author's data to check.
 */
function sanitizeAuthor(author: IAuthor): IAuthor {
  if (!author) { 
    return genEmptyAuthor();
  }

  const born          = sanitizePointInTime(author.born);
  const death         = sanitizePointInTime(author.death);
  const fromReference = sanitizeFromReference(author.fromReference);
  const urls          = sanitizeUrls(author.urls);

  const isFictional = typeof author.isFictional === 'boolean' ? author.isFictional  : false;
  const id          = typeof author.id          === 'string'  ? author.id           : '';
  const job         = typeof author.job         === 'string'  ? author.job          : '';
  const name        = typeof author.name        === 'string'  ? author.name         : '';
  const summary     = typeof author.summary     === 'string'  ? author.summary      : '';

  return {
    born,
    death,
    fromReference,
    isFictional, 
    id,
    job,
    name, 
    summary,
    urls,
  };
}

/**
 * Check comments type. Return a default value if the type is wrong.
 * @param comments - Array of comments to check.
 */
function sanitizeComments(comments: Array<string>) {
  if (!comments || !Array.isArray(comments) || comments.length === 0) {
    return [];
  }

  const isKO = comments.some((value) => typeof value !== 'string');

  if (isKO) {
    return [];
  }

  return comments;
}

/**
 * Return a sanitized [urls] object (all fields are checked).
 * @param urls - Data to check.
 */
function sanitizeUrls(urls: IUrls): IUrls {
  if (!urls) {
    return {
      amazon      : '',
      facebook    : '',
      image       : '',
      instagram   : '',
      netflix     : '',
      primeVideo  : '',
      twitch      : '',
      twitter     : '',
      website     : '',
      wikipedia   : '',
      youtube     : '',
    };
  }

  const amazon      = typeof urls.amazon      === 'string'  ? urls.amazon     : '';
  const facebook    = typeof urls.facebook    === 'string'  ? urls.facebook   : '';
  const image       = typeof urls.image       === 'string'  ? urls.image      : '';
  const instagram   = typeof urls.instagram   === 'string'  ? urls.instagram  : '';
  const netflix     = typeof urls.netflix     === 'string'  ? urls.netflix    : '';
  const primeVideo  = typeof urls.primeVideo  === 'string'  ? urls.primeVideo : '';
  const twitch      = typeof urls.twitch      === 'string'  ? urls.twitch     : '';
  const twitter     = typeof urls.twitter     === 'string'  ? urls.twitter    : '';
  const website     = typeof urls.website     === 'string'  ? urls.website    : '';
  const wikipedia   = typeof urls.wikipedia   === 'string'  ? urls.wikipedia  : '';
  const youtube     = typeof urls.youtube     === 'string'  ? urls.youtube    : '';

  return {
    amazon,
    facebook,
    image,
    instagram,
    netflix,
    primeVideo,
    twitch,
    twitter,
    website,
    wikipedia,
    youtube,
  }
}

/**
 * Return a sanitized [fromReference] object (all fields are checked).
 * @param fromReference - Data to check
 */
function sanitizeFromReference(fromReference: IFromReference) {
  if (!fromReference) {
    return {
      id: '',
    };
  }

  const id = typeof fromReference.id === 'string' ? fromReference.id : '';
  return { id };
}

/**
 * Return a sanitized [PointInTime] object (all fields are checked).
 * @param point - Data to check.
 */
function sanitizePointInTime(point: IPointInTime) {
  if (!point) {
    return genEmptyPointInTime();
  }

  const beforeJC  = typeof point.beforeJC === 'boolean' ? point.beforeJC  : false;
  const city      = typeof point.city     === 'string'  ? point.city      : '';
  const country   = typeof point.country  === 'string'  ? point.country   : '';
  const date      = sanitizeDate(point.date);

  const payload: IPointInTime = {
    beforeJC,
    city,
    country,
  };

  if (date) {
    payload.date = date;
  }

  return payload;
}

/**
 * Check if the argument is a valid date.
 * (Valid formats: A number or an object with [seconds] and [nanoseconds]).
 * Return [undefined] otherwise.
 * @param date - Data to check.
 */
function sanitizeDate(date: any) {
  if (!date) return undefined;

  if (typeof date === 'number') {
    return adminApp.firestore.Timestamp.fromMillis(date);
  }

  if (typeof date === 'object' 
    && Object.keys(date).length === 2 
    && typeof date.seconds === 'number'
    && typeof date.nanoseconds === 'number') {

    return adminApp.firestore.Timestamp.fromMillis(date.seconds);
    }

    return undefined;
}

/**
 * Generate default data representing a PointInTime object.
 */
function genEmptyPointInTime():IPointInTime {
  return {
    beforeJC: false,
    city: '',
    country: '',
  };
}

function sanitizeLang(lang: string) {
  const available = ['en', 'fr'];

  if (available.includes(lang)) {
    return lang;
  }

  return 'en';
}

/**
 * Return a sanitized [reference] object (all fields are checked).
 * @param reference - Data to check.
 */
function sanitizeReference(reference: IReference): IReference {
  if (!reference) {
    return genEmptyReference();
  }
  
  const id      = typeof reference.id       === 'string' ? reference.id       : '';
  const name    = typeof reference.name     === 'string' ? reference.name     : '';
  const summary = typeof reference.summary  === 'string' ? reference.summary  : '';
  
  const lang    = sanitizeLang(reference.lang);
  const release = sanitizeRelease(reference.release);
  const type    = sanitizeReferenceType(reference.type);
  const urls    = sanitizeUrls(reference.urls);

  return {
    id,
    lang,
    name,
    release,
    summary,
    type,
    urls,
  };
}

/**
 * Return a sanitized [reference.type] object (all fields are checked).
 * @param type - Data to check.
 */
function sanitizeReferenceType(type: IReferenceType): IReferenceType {
  if (!type) {
    return {
      primary: '',
      secondary: '',
    };
  }

  const primary = typeof type.primary === 'string' ? type.primary : '';
  const secondary = typeof type.secondary === 'string' ? type.secondary : '';

  return {
    primary,
    secondary,
  }
}

/**
 * Return a sanitized [release] object (all fields are checked).
 * @param release - Data to check.
 */
function sanitizeRelease(release: IRelease): IRelease {
  if (!release) {
    return {
      beforeJC: false,
    };
  }

  const beforeJC = typeof release.beforeJC === 'boolean' ? release.beforeJC : false;
  const original = sanitizeDate(release.original);

  const payload: IRelease = {
    beforeJC,
  }

  if (original) {
    payload.original = original;
  }

  return payload;
}

/**
 * Generate default data representing a [Author] object.
 */
function genEmptyAuthor(): IAuthor {
  return {
    born: {
      beforeJC: false,
      city: '',
      country: '',
    },
    death: {
      beforeJC: false,
      city: '',
      country: '',
    },
    fromReference: {
      id: '',
    },
    isFictional: false,
    id: '',
    job: '',
    name: '',
    summary: '',
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
}

/**
 * Generate default data representing a [Reference] object.
 */
function genEmptyReference(): IReference  {
  return {
    id: '',
    lang: '',
    name: '',
    release: {
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
}
