import { NextFunction, Request, Response } from 'express';
import { adminApp } from '../adminApp';

export const extractQueryStringNumber = (value: string, defaultValue: number) => {
  const normalizedValue = typeof value !== 'undefined' ? value : `${defaultValue}`;

  if (typeof normalizedValue !== 'string') {
    return undefined;
  }

  return parseInt(normalizedValue);
}

export const getRandomAuthors = async (params?: GetRandomAuthorsParams) => {
  const limit = 6;

  /** Excluded id.
   *  Because it's already included in the proposal (as the right answer). */
  let exceptId = '';

  if (params && params.except) {
    exceptId = params.except;
  }

  const createdAt = new Date();
  createdAt.setDate(createdAt.getDate() - getRandomIntInclusive(0, 360));

  let snapshot = await adminApp.firestore()
    .collection('authors')
    .where('createdAt', '>=', createdAt)
    .limit(limit)
    .get();

  if (snapshot.empty) {
    snapshot = await adminApp.firestore()
      .collection('authors')
      .where('createdAt', '<=', createdAt)
      .limit(limit)
      .get();
  }


  const boxAuthors: FirebaseFirestore.DocumentData[] = [];

  for (const doc of snapshot.docs) {
    const docData = doc.data();
    docData.id = doc.id;

    if (docData.id !== exceptId) {
      boxAuthors.push(docData);
    }
  }

  shuffle(boxAuthors);

  const pickedAuthors = boxAuthors.slice(0, 2);

  return {
    type: 'author',
    values: pickedAuthors,
  };
}

/**
 * Return a random number between [min] and [max], both inclusive.
 * @param min - Minimum number to get (inclusive).
 * @param max - Maximum number to get (inclusive).
 */
export const getRandomIntInclusive = (min: number, max: number) => {
  const minimum = Math.ceil(min);
  const maximum = Math.floor(max);
  // The maximum is inclusive and the minimum is inclusive.
  return Math.floor(Math.random() * (maximum - minimum + 1) + minimum);
}

export const getRandomQuoteAuthored = async (params: RandomQuoteAuthoredParams) => {
  let { lang, guessType, previousQuestionsIds } = params;

  let lastAuthorReferenceId = '';

  if (previousQuestionsIds && previousQuestionsIds.length > 0) {
    lastAuthorReferenceId = previousQuestionsIds[previousQuestionsIds.length - 1];
  }

  if (!isLangAvailable(lang)) {
    lang = 'en';
  }

  if (!guessType) {
    const rand = getRandomIntInclusive(0, 1);
    guessType = rand === 0 ? 'author' : 'reference';
  }

  const limit = 8;
  const createdAt = new Date();
  createdAt.setDate(createdAt.getDate() - getRandomIntInclusive(0, 360));

  let snapshot = await adminApp.firestore()
    .collection('quotes')
    .where('lang', '==', lang)
    .where('createdAt', '>=', createdAt)
    .limit(limit)
    .get();

  if (snapshot.empty) {
    snapshot = await adminApp.firestore()
      .collection('quotes')
      .where('lang', '==', lang)
      .where('createdAt', '<=', createdAt)
      .limit(limit)
      .get();
  }

  const boxQuotes: FirebaseFirestore.DocumentData[] = [];

  for (const doc of snapshot.docs) {
    const docData = doc.data();
    docData.id = doc.id;
    boxQuotes.push(docData);
  }

  shuffle(boxQuotes);

  let selectedQuote: FirebaseFirestore.DocumentData | undefined;

  if (guessType === 'author') {
    selectedQuote = boxQuotes.find((item) => {
      return item.author.id 
        && item.author.id !== 'TySUhQPqndIkiVHWVYq1' // anonymous author
        && item.author.id !== lastAuthorReferenceId;
    });
  } else {
    selectedQuote = boxQuotes.find((item) => {
      return item.mainReference.id 
        && item.mainReference.id !== lastAuthorReferenceId;
    });
  }

  return {
    guessType,
    quote: selectedQuote,
  };
}

export const getRandomReferences = async (params?: GetRandomReferencesParams) => {
  const limit = 6;

  /** Excluded id.
   *  Because it's already included in the proposal (as the right answer). */
  let exceptId = '';

  if (params && params.except) {
    exceptId = params.except;
  }

  const createdAt = new Date();
  createdAt.setDate(createdAt.getDate() - getRandomIntInclusive(0, 360));

  let snapshot = await adminApp.firestore()
    .collection('references')
    .where('createdAt', '>=', createdAt)
    .limit(limit)
    .get();

  if (snapshot.empty) {
    snapshot = await adminApp.firestore()
      .collection('references')
      .where('createdAt', '<=', createdAt)
      .limit(limit)
      .get();
  }


  const boxReferences: FirebaseFirestore.DocumentData[] = [];

  for (const doc of snapshot.docs) {
    const docData = doc.data();
    docData.id = doc.id;

    if (docData.id !== exceptId) {
      boxReferences.push(docData);
    }
  }

  shuffle(boxReferences);

  const pickedReferences = boxReferences.slice(0, 2);

  return {
    type: 'reference',
    values: pickedReferences,
  };
}

/**
 * Return true if the specified lang is available.
 * @param lang - Language to test.
 */
export const isLangAvailable = (lang: string) => {
  return ['en', 'fr'].includes(lang);
};

export const shuffle = (array: any[]) => {
  let m = array.length;
  let t;
  let i;

  // While there remain elements to shuffle…
  while (m) {

    // Pick a remaining element…
    i = Math.floor(Math.random() * m--);

    // And swap it with the current element.
    t = array[m];
    array[m] = array[i];
    array[i] = t;
  }

  return array;
}

export const checkAPIKey = async (req: Request, res: Response, next: NextFunction) =>  {
  const queryStringApiKey: string = req.query.apiKey as string;
  const headerApiKey = req.headers.authorization;

  const apiKey = queryStringApiKey || headerApiKey;

  if (!apiKey) {
    res
      .status(401)
      .send(`Please provide a valid API key. None was sent.`);
      
    return;
  }

  const segments = apiKey.split(',');
  const appId = segments[0];

  const appDoc = await adminApp.firestore()
    .collection('apps')
    .doc(appId)
    .get();

  const docData = appDoc.data();

  if (!appDoc.exists || !docData) {
    res
      .status(401)
      .send(`Missing API key. Please provide a valid API key.`);

    return;
  }

  // Check other API keys segments.
  const keyNumber = segments[segments.length - 1];

  if (keyNumber.indexOf('k=1') > -1) {
    const primaryKey: string = docData.keys.primary;

    if (primaryKey !== apiKey) {
      res
        .status(401)
        .send(`Wrong (primary) API key. Please provide a valid API key.`);

      return;
    }
  } else if (keyNumber.indexOf('k=2') > -1) {
    const secondaryKey: string = docData.keys.secondary;

    if (secondaryKey !== apiKey) {
      res
        .status(401)
        .send(`Wrong (secondary) API key. Please provide a valid API key.`);

      return;
    }
  } else {
    res
      .status(401)
      .send(`Wrong API key. Please provide a valid API key.`);

    return;
  }

  // Check rate limit and update stats.
  const allTimeCalls: number  = docData.stats.calls.allTime;
  const callsLimit: number  = docData.stats.calls.limit;

  await appDoc.ref.update('stats.calls.allTime', allTimeCalls + 1);

  const date = new Date();

  const monthNumber = date.getMonth() + 1;
  const month = monthNumber < 10 ? `0${monthNumber}` : monthNumber;
  const day = date.getDate() < 10 ? `0${date.getDate()}` : date.getDate();

  const dayDateId = `${date.getFullYear()}:${month}:${day}`;
  
  const updateDayOk = await updateDailyStats({ 
    appDoc, 
    callsLimit, 
    date, 
    dayDateId, 
  });

  if (!updateDayOk) {
    res
      .status(401)
      .send(`You've reached your API calls limit of ${callsLimit}. 
        Please wait until your quota resets or use the premium plan.`);

    return;
  }

  const updateMonthOk = await updateMonthlyStats({ 
    appDoc,
    date,
    dateId: `${date.getFullYear()}:${month}`, 
  });

  if (!updateMonthOk) {
    res
      .status(500)
      .send(`There was an error while performing your request. 
        Please try again later or contact us for more information.`);

    return;
  }

  const updateYearOk = await updateYearlyStats({
    appDoc,
    date,
    dateId: `${date.getFullYear()}`,
  });

  if (!updateYearOk) {
    res
      .status(500)
      .send(`There was an error while performing your request. 
        Please try again later or contact us for more information.`);

    return;
  }

  next();
}

async function updateDailyStats(params: UpdateDailyStatsParams) {
  const { appDoc, dayDateId, callsLimit, date } = params;

  const dailyCallsDoc = await appDoc
    .ref
    .collection('dailycalls')
    .doc(dayDateId)
    .get();

  if (!dailyCallsDoc.exists) {
    await dailyCallsDoc.ref.create({
      date: new Date(
        date.getFullYear(),
        date.getMonth(),
        date.getDate(),
      ),
      calls:1,
    });

    return true;
  }

  const dailyCallsData = dailyCallsDoc.data();

  if (!dailyCallsData) {
    return false;
  }

  const todayCalls: number = dailyCallsData.calls;
  
  if (todayCalls >= callsLimit) {
    return false;
  }

  await dailyCallsDoc.ref.update('calls', todayCalls + 1);
  return true;
}

async function updateMonthlyStats(params: UpdateStatsParams) {
  const { appDoc, dateId, date } = params;

  const monthlyCallsDoc = await appDoc
    .ref
    .collection('monthlycalls')
    .doc(dateId)
    .get();

  if (!monthlyCallsDoc.exists) {
    await monthlyCallsDoc.ref.create({
      date: new Date(date.getFullYear(), date.getMonth()),
      calls: 1,
    });

    return true;
  }

  const monthlyCallsData = monthlyCallsDoc.data();

  if (!monthlyCallsData) {
    return false;
  }

  const monthCalls: number = monthlyCallsData.calls;

  await monthlyCallsDoc.ref.update('calls', monthCalls + 1);
  return true;
}

async function updateYearlyStats(params: UpdateStatsParams) {
  const { appDoc, dateId, date } = params;

  const yearlyCallsDoc = await appDoc
    .ref
    .collection('yearlycalls')
    .doc(dateId)
    .get();

  if (!yearlyCallsDoc.exists) {
    await yearlyCallsDoc.ref.create({
      date: new Date(date.getFullYear(), 0),
      calls: 1,
    });

    return true;
  }

  const yearlyCallsData = yearlyCallsDoc.data();

  if (!yearlyCallsData) {
    return false;
  }

  const yearCalls: number = yearlyCallsData.calls;

  await yearlyCallsDoc.ref.update('calls', yearCalls + 1);
  return true;
}
