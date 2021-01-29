import * as express from 'express';
import { adminApp } from '../../adminApp';
import { getRandomIntInclusive, isLangAvailable } from '../utils';

export const quotesRouter = express.Router()
  .get('/', async (req, res, next) => {
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
      res.status(400).send({
        error: {
          reason: `The language ${lang} is not available. 
            Please try the following values: 'en', 'fr'.`,
        }
      });
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

    let snapshot: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData>;

    try { snapshot = await query.get(); } 
    catch (error) { next(error); return; }

    if (snapshot.empty) {
      res.status(404).send({
        error: {
          reason: `There is no data for this query.`
        }
      });
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
  .get('/random', async (req, res, next) => {
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
      res.status(400).send({
        error: {
          reason: `The language ${lang} is not available. 
            Please try the following values: 'en', 'fr'.`,
        }
      });
      return;
    }

    const createdAt = new Date();
    createdAt.setDate(createdAt.getDate() - getRandomIntInclusive(0, 360));

    let snapshot: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData>;

    try {
      snapshot = await adminApp.firestore()
        .collection('quotes')
        .where('lang', '==', lang)
        .where('createdAt', '>=', createdAt)
        .limit(limit)
        .get();
    } catch (error) {
      next(error);
      return;
    }

    if (snapshot.empty) {
      res.status(404).send({
        error: {
          reason: `There is no data for this query.`,
        }
      });
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
