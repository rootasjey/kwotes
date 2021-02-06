import { NextFunction, Request, Response } from 'express';
import { adminApp } from '../adminApp';

export const extractQueryStringNumber = (value: string, defaultValue: number) => {
  const normalizedValue = typeof value !== 'undefined' ? value : `${defaultValue}`;

  if (typeof normalizedValue !== 'string') {
    return undefined;
  }

  return parseInt(normalizedValue);
}

export const getRandomAuthors = async () => {
  const limit = 6;

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
    boxAuthors.push(docData);
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

export const getRandomQuoteAuthored = async () => {
  const lang = 'en';
  const limit = 6;

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

  let guessType = 'author';

  let selectedQuote = boxQuotes.find((item) => {
    return item.author.id !== 'TySUhQPqndIkiVHWVYq1';
  });

  if (!selectedQuote) {
    guessType = 'reference';
    selectedQuote = boxQuotes.find((item) => {
      return typeof item.mainReference.id !== 'undefined';
    });
  }

  return {
    guessType,
    quote: selectedQuote,
  };
}

export const getRandomReferences = async () => {
  const limit = 6;

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
    boxReferences.push(docData);
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
  
  const updateDayOk = await updateDailyStats({ appDoc, dayDateId, callsLimit });

  if (!updateDayOk) {
    res
      .status(401)
      .send(`You've reached your API calls limit of ${callsLimit}. 
        Please wait until your quota resets or use the premium plan.`);

    return;
  }

  const updateMonthOk = await updateMonthlyStats({ 
    appDoc, 
    dateId: `${date.getFullYear()}${month}`, 
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
  const { appDoc, dayDateId, callsLimit } = params;

  const dailyCallsDoc = await appDoc
    .ref
    .collection('dailycalls')
    .doc(dayDateId)
    .get();

  if (!dailyCallsDoc.exists) {
    await dailyCallsDoc.ref.create({
      date: dayDateId,
      calls: 0,
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
  const { appDoc, dateId } = params;

  const monthlyCallsDoc = await appDoc
    .ref
    .collection('monthlycalls')
    .doc(dateId)
    .get();

  if (!monthlyCallsDoc.exists) {
    await monthlyCallsDoc.ref.create({
      date: dateId,
      calls: 0,
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
  const { appDoc, dateId } = params;

  const yearlyCallsDoc = await appDoc
    .ref
    .collection('yearlycalls')
    .doc(dateId)
    .get();

  if (!yearlyCallsDoc.exists) {
    await yearlyCallsDoc.ref.create({
      date: dateId,
      calls: 0,
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
