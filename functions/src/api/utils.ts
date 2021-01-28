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
