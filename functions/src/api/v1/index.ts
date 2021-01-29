import * as express from 'express';
import { adminApp } from '../../adminApp';
import { isLangAvailable } from '../utils';
import { quotesRouter } from './quotes';
import { disRouter } from './dis';

export const v1Router = express.Router()
  .use('/quotes', quotesRouter)
  .use('/dis', disRouter)
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
  .get('/quotidian', async (req, res) => {
    const lang = req.query.lang as string ?? 'en';

    if (!isLangAvailable(lang)) {
      res.send({
        response: {
          date: undefined,
          quotidian: undefined,
          requestState: {
            success: false,
            error: {
              reason: `The language ${lang} is not available. Please try 'en', 'fr'.`,
            },
            warning: '',
          },
        }
      });
      return;
    }

    const date = new Date();

    const monthNumber = date.getMonth() + 1;
    const month = monthNumber < 10 ? `0${monthNumber}` : monthNumber;
    const day = date.getDate() < 10 ? `0${date.getDate()}` : date.getDate();

    const dateId = `${date.getFullYear()}:${month}:${day}:${lang}`;

    const quotidian = await adminApp.firestore()
      .collection('quotidians')
      .doc(dateId)
      .get();

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
