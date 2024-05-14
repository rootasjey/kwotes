import * as express from 'express';
import { adminApp } from '../../adminApp';
import { checkAPIKey, getRandomIntInclusive, isLangAvailable } from '../utils';

export const quotesRouter = express.Router()
  .use(checkAPIKey)
  .get('/', async (req, res, next) => {
    const startAfter = req.query.startAfter as string;
    const strOffset = req.query.offset as string;
    const order: 'asc' | 'desc' = req.query.order as 'asc' | 'desc' ?? 'desc';
    const orderBy = req.query.orderBy as string;
    const offset = strOffset ? parseInt(strOffset) : null;
    
    const userStrLimit = req.query.limit as string ?? '12';
    const userIntLimit = parseInt(userStrLimit);
    
    const isLimitInRange = userIntLimit > 0 && userIntLimit < 21;
    const limit = isLimitInRange ? userIntLimit : 12;

    const language = req.query.language as string ?? 'en';

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

    if (!isLangAvailable(language)) {
      res.status(400).send({
        error: {
          reason: `The language ${language} is not available. 
            Please try the following values: 'en', 'fr'.`,
        }
      });
      return;
    }

    let query = adminApp.firestore()
      .collection('quotes')
      .where('language', '==', language)
      .limit(limit);

    if (typeof offset === 'number') {
      query = query.offset(offset);
    }
    if (order && orderBy) {
      query = query.orderBy(orderBy, order);
    }

    if (startAfter) {
      const startAfterDoc = await adminApp.firestore()
        .collection('quotes')
        .doc(startAfter)
        .get();

      query = query.startAfter(startAfterDoc);
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

    responsePayload.success = true;
    responsePayload.quotes = quotes;
    res.send({ response: responsePayload });
  })
  .get('/:id', async (req, res) => {
    const quoteId: string = req.params.id;

    if (!quoteId) {
      res
        .status(400)
        .send(`No id was provided. Please send a valid quote's id.`);
      
      return;
    }

    const quoteDoc = await adminApp.firestore()
      .collection('quotes')
      .doc(quoteId)
      .get();

    const quoteData = quoteDoc.data();

    if (!quoteData || !quoteDoc.exists) {
      res
        .status(404)
        .send(`No quote was found for the specified id: ${quoteId}.
          Maybe the data has been deleted.`);

      return;
    }

    res.send({response: quoteData });
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

    const language = req.query.language as string ?? 'en';

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

    if (!isLangAvailable(language)) {
      res.status(400).send({
        error: {
          reason: `The language ${language} is not available. 
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
        .where('language', '==', language)
        .where('created_at', '>=', createdAt)
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
