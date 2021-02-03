import * as express from 'express';
import { adminApp } from '../../adminApp';
import { isLangAvailable } from '../utils';
import { quotesRouter } from './quotes';
import { disRouter } from './dis';
import { searchRouter } from './search';

export const v1Router = express.Router()
  .use('/quotes', quotesRouter)
  .use('/dis', disRouter)
  .use('/search', searchRouter)
  .get('/', (req, res) => {
    res.send({
      lastUpdated: new Date(2021, 0, 27),
      dis: '/dis -> Did I say? game',
      quotidian: '/quotidian -> Get the quote of the day',
      quotes: {
        '/': '/quotes -> Get a list of quotes',
      },
      version: 'v1',
    });
  })
  .get('/quotidian', async (req, res, next) => {
    const lang = req.query.lang as string ?? 'en';

    if (!isLangAvailable(lang)) {
      res.status(400).send({
        error: {
          reason: `The language ${lang} is not available. 
            Please try the following values: 'en', 'fr'.`,
        }
      });
      return;
    }

    const date = new Date();

    const monthNumber = date.getMonth() + 1;
    const month = monthNumber < 10 ? `0${monthNumber}` : monthNumber;
    const day = date.getDate() < 10 ? `0${date.getDate()}` : date.getDate();

    const dateId = `${date.getFullYear()}:${month}:${day}:${lang}`;

    let quotidian: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>;

    try {
      quotidian = await adminApp.firestore()
        .collection('quotidians')
        .doc(dateId)
        .get();
    } catch (error) {
      next(error);
      return;
    }

    const quotidianData = quotidian.data();

    res.send({
      response: {
        date: dateId,
        quotidian: quotidianData,
        requestState: {
          success: typeof quotidianData !== 'undefined',
          error: {
            reason: '',
          },
          warning: '',
        },
      }
    });
  });
