import * as express from 'express';
import { adminApp } from '../../adminApp';
import { getRandomIntInclusive, isLangAvailable } from '../utils';

export const quotesRouter = express.Router()
  .get('/', async (req, res) => {
    const startAfter = req.query.startAfter as string ?? '';

    const strOffset = req.query.offset as string ?? '0';
    const offset = parseInt(strOffset);
    
    const userStrLimit = req.query.limit as string ?? '12';
    const userIntLimit = parseInt(userStrLimit);
    
    const isLimitInRange = userIntLimit > 0 && userIntLimit < 21;
    const limit = isLimitInRange ? userIntLimit : 12;

    const lang = req.query.lang as string ?? 'en';

    const warningStr = isLimitInRange 
      ? '' 
      : `The value '${userStrLimit}' for the query string 'limit' is not valid. 
          Please use a value between '1' and '20' included.`;

    const responsePayload = {
      success: false,
      quotes: <FirebaseFirestore.DocumentData>[],
      error: {
        reason: '',
      },
      warning: warningStr,
    };

    if (!isLangAvailable(lang)) {
      responsePayload.error.reason = `The language ${lang} is not available. Please try 'en', 'fr'.`;
      res.send({ response: responsePayload });
      return;
    }

    const query = adminApp.firestore()
      .collection('quotes')
      .where('lang', '==', lang)
      .offset(offset)
      .limit(limit);

    if (startAfter) {
      const startAfterDoc = await adminApp.firestore()
        .collection('quotes')
        .doc(startAfter)
        .get();

      query.startAfter(startAfterDoc);
    }

    const snapshot = await query.get();

    if (snapshot.empty) {
      responsePayload.error.reason = 'The snapshot is empty for this query.';
      res.send({ response: responsePayload });
      return;
    }

    const quotes = [];

    for (const doc of snapshot.docs) {
      const docData = doc.data();
      docData.id = doc.id;
      quotes.push(docData);
    }

    responsePayload.quotes = quotes;
    res.send({ response: responsePayload });
  })
  .get('/random', async (req, res) => {
    const userStrLimit = req.query.limit as string ?? '12';
    const userIntLimit = parseInt(userStrLimit);

    const isLimitInRange = userIntLimit > 0 && userIntLimit < 4;
    const limit = isLimitInRange ? userIntLimit : 3;

    const warningStr = isLimitInRange
      ? ''
      : `The value '${userStrLimit}' for the query string 'limit' is not valid. 
          Please use a value between '1' and '3' included.`;

    const lang = req.query.lang as string ?? 'en';

    const responsePayload = {
      quotes: <FirebaseFirestore.DocumentData>[],
      requestState: {
        success: false,
        error: {
          reason: '',
        },
        warning: warningStr,
      },
    };

    if (!isLangAvailable(lang)) {
      responsePayload.requestState
        .error.reason = `The language ${lang} is not available. Please try 'en', 'fr'.`;
      res.send({ response: responsePayload });
      return;
    }

    const createdAt = new Date();
    createdAt.setDate(createdAt.getDate() - getRandomIntInclusive(0, 360));

    const snapshot = await adminApp.firestore()
      .collection('quotes')
      .where('lang', '==', lang)
      .where('createdAt', '>=', createdAt)
      .limit(limit)
      .get();

    if (snapshot.empty) {
      responsePayload.requestState
        .error.reason = 'The snapshot is empty for this query.';
      res.send({ response: responsePayload });
      return;
    }

    const quotes = [];

    for (const doc of snapshot.docs) {
      const docData = doc.data();
      docData.id = doc.id;
      quotes.push(docData);
    }

    responsePayload.quotes = quotes;
    res.send({ response: responsePayload });
  });
