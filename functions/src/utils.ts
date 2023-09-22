import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';

const env = functions.config();

export async function checkUserIsSignedIn(
  context: functions.https.CallableContext, 
  idToken: string,
) {
  const userAuth = context.auth;

  if (!userAuth) {
    throw new functions.https.HttpsError(
      'unauthenticated', 
      `The function must be called from an authenticated user (2).`,
    );
  }

  let isTokenValid = false;

  try {
    await adminApp
      .auth()
      .verifyIdToken(idToken, true);

    isTokenValid = true;

  } catch (error) {
    console.error(error);
    isTokenValid = false;
  }

  if (!isTokenValid) {
    throw new functions.https.HttpsError(
      'unauthenticated', 
      `Your session has expired. Please (sign out and) sign in again.`,
    );
  }
}

/**
 * Create an empty author object.
 * @returns An empty author.
 * */
export function getEmptyAuthor(): IAuthor {
  return {
    born: {
      before_common_era    : false,
      city        : '',
      country     : '',
      date        : null,
    },
    death: {
      before_common_era: false,
      city        : '',
      country     : '',
      date        : null,
    },
    from_reference: {
      id          : '',
    },
    image: {
      credits: {
        before_common_era  : false,
        company   : '',
        location  : '',
        name      : '',
        artist    : '',
        url       : '',
        date      : null,
      },
    },
    is_fictional : false,
    id          : '',
    job         : '',
    job_localized: {},
    name        : '',
    summary     : '',
    summary_localized: {},
    urls: {
      amazon    : '',
      facebook  : '',
      image     : '',
      image_name: '',
      imdb      : '',
      instagram : '',
      netflix   : '',
      prime_video: '',
      twitch    : '',
      twitter   : '',
      website   : '',
      wikipedia : '',
      youtube   : '',
    },
  };
}

/**
 * Generate default data representing a PointInTime object.
 */
export function getEmptyPointInTime(): IPointInTime {
  return {
    before_common_era  : false,
    city      : '',
    country   : '',
  };
}

/**
 * Create an empty reference object.
 * @returns An empty reference.
 */
export function getEmptyReference(): IReference {
  return {
    id: '',
    image: {
      credits: {
        before_common_era  : false,
        company   : '',
        location  : '',
        name      : '',
        artist    : '',
        url       : '',
      },
    },
    language      : '',
    name          : '',
    release: {
      before_common_era    : false,
      original             : null,
    },
    summary       : '',
    type: {
      primary     : '',
      secondary   : '',
    },
    urls: {
      amazon      : '',
      facebook    : '',
      image       : '',
      image_name  : '',
      imdb        : '',
      instagram   : '',
      netflix     : '',
      prime_video  : '',
      twitch      : '',
      twitter     : '',
      website     : '',
      wikipedia   : '',
      youtube     : '',
    },
  };
}

/**
 * Return a sanitized [author] object (all fields are checked).
 * @param author - Author's data to check.
 */
export function sanitizeAuthor(author: IAuthor): IAuthor {
  if (!author) {
    return getEmptyAuthor();
  }

  const born            = sanitizePointInTime(author.born);
  const death           = sanitizePointInTime(author.death);
  const from_reference  = sanitizeFromReference(author.from_reference);
  const image           = sanitizeImageCredits(author.image);
  const urls            = sanitizeUrls(author.urls);

  const is_fictional    = typeof author.is_fictional === 'boolean' ? author.is_fictional  : false;
  const id              = typeof author.id          === 'string'  ? author.id           : '';
  const job             = typeof author.job         === 'string'  ? author.job          : '';
  const name            = typeof author.name        === 'string'  ? author.name         : '';
  const summary         = typeof author.summary     === 'string'  ? author.summary      : '';

  return {
    born,
    image,
    death,
    from_reference,
    is_fictional,
    id,
    job,
    job_localized: {},
    name,
    summary,
    summary_localized: {},
    urls,
  };
}

function sanitizeImageCredits(imageProp: ImageProp): ImageProp {
  const credits = imageProp?.credits;

  if (!imageProp || !credits) {
    return {
      credits: {
        before_common_era: false,
        company: '',
        location: '',
        name: '',
        artist: '',
        url: '',
      },
    };
  }

  const bce = credits.before_common_era;

  const before_common_era = typeof bce === 'boolean'             ? bce : false;
  const company           = typeof credits.company  === 'string' ? credits.company : '';
  const location          = typeof credits.location === 'string' ? credits.location : '';
  const name              = typeof credits.name     === 'string' ? credits.name : '';
  const artist            = typeof credits.artist   === 'string' ? credits.artist : '';
  const url               = typeof credits.url      === 'string' ? credits.url : '';

  const imageCredits: ImageProp = {
    credits: {
      before_common_era,
      company,
      location,
      name,
      artist,
      url,
    }
  };

  const date = sanitizeDate(credits.date);

  if (date) {
    imageCredits.credits.date = date;
  }

  return imageCredits;
}

/**
 * Return a sanitized [urls] object (all fields are checked).
 * @param urls - Data to check.
 */
export function sanitizeUrls(urls: IUrls): IUrls {
  if (!urls) {
    return {
      amazon: '',
      facebook: '',
      image: '',
      image_name: '',
      imdb: '',
      instagram: '',
      netflix: '',
      prime_video: '',
      twitch: '',
      twitter: '',
      website: '',
      wikipedia: '',
      youtube: '',
    };
  }

  const amazon      = typeof urls.amazon      === 'string' ? urls.amazon      : '';
  const facebook    = typeof urls.facebook    === 'string' ? urls.facebook    : '';
  const image       = typeof urls.image       === 'string' ? urls.image       : '';
  const image_name  = typeof urls.image_name  === 'string' ? urls.image_name  : '';
  const imdb        = typeof urls.imdb        === 'string' ? urls.imdb        : '';
  const instagram   = typeof urls.instagram   === 'string' ? urls.instagram   : '';
  const netflix     = typeof urls.netflix     === 'string' ? urls.netflix     : '';
  const prime_video = typeof urls.prime_video === 'string' ? urls.prime_video : '';
  const twitch      = typeof urls.twitch      === 'string' ? urls.twitch      : '';
  const twitter     = typeof urls.twitter     === 'string' ? urls.twitter     : '';
  const website     = typeof urls.website     === 'string' ? urls.website     : '';
  const wikipedia   = typeof urls.wikipedia   === 'string' ? urls.wikipedia   : '';
  const youtube     = typeof urls.youtube     === 'string' ? urls.youtube     : '';

  return {
    amazon,
    facebook,
    image,
    image_name,
    imdb,
    instagram,
    netflix,
    prime_video,
    twitch,
    twitter,
    website,
    wikipedia,
    youtube,
  }
}

export function sanitizeTopics(topics: TopicMap): TopicMap {
  if (!topics) {
    return {};
  }

  const authorizedTopicKeys = [
    "art",
    "biology",
    "feelings",
    "fun",
    "gratitude",
    "introspection",
    "knowledge",
    "language",
    "mature",
    "metaphor",
    "motivation",
    "offensive",
    "philosophy",
    "poetry",
    "proverb",
    "psychology",
    "punchline",
    "retrospection",
    "sciences",
    "social",
    "spiritual",
    "travel",
    "work",
  ];

  const keys = Object.keys(topics);
  const values = Object.values(topics);

  for (let i = 0; i < keys.length; i++) {
    const key = keys[i];
    const value = values[i];

    if (!authorizedTopicKeys.includes(key)) {
      delete topics[key];
    }

    if (typeof value !== 'boolean') {
      delete topics[key];
    }
  }

  return topics;
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
    return getEmptyPointInTime();
  }

  const bce = point.before_common_era;

  const before_common_era   = typeof bce === 'boolean' ? bce  : false;
  const city                = typeof point.city     === 'string'  ? point.city      : '';
  const country             = typeof point.country  === 'string'  ? point.country   : '';
  const date                = sanitizeDate(point.date);

  const payload: IPointInTime = {
    before_common_era,
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
  if (!date) return null;

  if (typeof date === 'number') {
    return adminApp.firestore.Timestamp.fromMillis(date);
  }

  // if (typeof date === 'object'
  //   && Object.keys(date).length === 2
  //   && typeof date.seconds === 'number'
  //   && typeof date.nanoseconds === 'number') {

  //   return adminApp.firestore.Timestamp.fromMillis(date.seconds);
  // }

  return date;
}

export function sanitizeLang(language: string) {
  if (!language) {
    return 'en';
  }

  const available = ['en', 'fr'];

  if (typeof language !== 'string') {
    return 'en';
  }

  if (available.includes(language)) {
    return language;
  }

  return 'en';
}

/**
 * Return a sanitized [reference] object (all fields are checked).
 * @param reference - Data to check.
 */
export function sanitizeReference(reference: IReference): IReference {
  if (!reference) {
    return getEmptyReference();
  }

  const id        = typeof reference.id       === 'string' ? reference.id       : '';
  const name      = typeof reference.name     === 'string' ? reference.name     : '';
  const summary   = typeof reference.summary  === 'string' ? reference.summary  : '';

  const image     = sanitizeImageCredits(reference.image);
  const language  = sanitizeLang(reference.language);
  const release   = sanitizeRelease(reference.release);
  const type      = sanitizeReferenceType(reference.type);
  const urls      = sanitizeUrls(reference.urls);

  return {
    id,
    image,
    language,
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
export function sanitizeReferenceType(type: IReferenceType): IReferenceType {
  if (!type) {
    return {
      primary: '',
      secondary: '',
    };
  }

  const primary   = typeof type.primary   === 'string' ? type.primary   : '';
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
      before_common_era: false,
    };
  }

  const bce = release.before_common_era;

  const before_common_era = typeof bce === 'boolean' ? bce : false;
  const original = sanitizeDate(release.original);

  const payload: IRelease = {
    before_common_era,
  }

  if (original) {
    payload.original = original;
  }

  return payload;
}

export function sendNotification(notificationData: any) {
  const headers = {
    "Content-Type": "application/json; charset=utf-8",
    Authorization: `Basic ${env.onesignal.apikey}`,
  };

  const options = {
    host: "onesignal.com",
    port: 443,
    path: "/api/v1/notifications",
    method: "POST",
    headers: headers,
  };

  const https = require("https");
  const req = https.request(options, (res: any) => {
    // console.log("statusCode:", res.statusCode);
    // console.log("headers:", res.headers);
    res.on("data", (respData: any) => {
      // console.log("Response:");
      console.log(JSON.parse(respData));
    });
  });

  req.on("error", (e: Error) => {
    console.log("ERROR:");
    console.log(e);
  });

  req.write(JSON.stringify(notificationData));
  req.end();
}
