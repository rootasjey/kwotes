import * as express from 'express';
import * as functions from 'firebase-functions';
import algolia from 'algoliasearch';
import { checkAPIKey } from '../utils';

const env = functions.config();

const client = algolia(env.algolia.appid, env.algolia.apikey);
const authorsIndex = client.initIndex('authors');
const quotesIndex = client.initIndex('quotes');
const referencesIndex = client.initIndex('references');

export const searchRouter = express.Router()
  .use(checkAPIKey)
  .get('/', async (req, res) => {
    const query = req.query.q as string ?? '';

    if (!query) {
      res.status(400).send({
        error: {
          reason: `You must specify a search query with [?q=yourquery]. 
            The search query was empty.`,
        }
      });

      return;
    }

    const strPage = req.query.page as string ?? '0';
    const page = parseInt(strPage);

    const userStrLimit = req.query.limit as string ?? '12';
    const userIntLimit = parseInt(userStrLimit);

    const isLimitInRange = userIntLimit > 0 && userIntLimit < 101;
    const limit = isLimitInRange ? userIntLimit : 10;

    const qPromise = quotesIndex.search(query, {
      hitsPerPage: limit,
      page: page,
    });

    const aPromise = authorsIndex.search(query, {
      hitsPerPage: limit,
      page: page,
    });

    const rPromise = referencesIndex.search(query, {
      hitsPerPage: limit,
      page: page,
    });

    Promise.all([qPromise, aPromise, rPromise])
      .then((searchResponses) => {
        res.send({ response: searchResponses });
      })
      .catch((reason: any) => {
        console.error(`There was an error while searching for ${query}`);
        return res.status(400).send({ response: reason });
      });
  })
  .get('/quotes', async (req, res) => { 
    const query = req.query.q as string ?? '';

    if (!query) {
      res.status(400).send({
        error: {
          reason: `You must specify a search query with [?q=yourquery]. 
            The search query was empty.`,
        }
      });
      return;
    }

    const strPage = req.query.page as string ?? '0';
    const page = parseInt(strPage);

    const userStrLimit = req.query.limit as string ?? '12';
    const userIntLimit = parseInt(userStrLimit);

    const isLimitInRange = userIntLimit > 0 && userIntLimit < 101;
    const limit = isLimitInRange ? userIntLimit : 10;

    const quotesResults = await quotesIndex.search(query, {
      hitsPerPage: limit,
      page: page,
    });

    res.send({ response: quotesResults });
  })
  .get('/authors', async (req, res) => { 
    const query = req.query.q as string ?? '';

    if (!query) {
      res.status(400).send({
        error: {
          reason: `You must specify a search query with [?q=yourquery]. 
            The search query was empty.`,
        }
      });

      return;
    }

    const strPage = req.query.page as string ?? '0';
    const page = parseInt(strPage);

    const userStrLimit = req.query.limit as string ?? '12';
    const userIntLimit = parseInt(userStrLimit);

    const isLimitInRange = userIntLimit > 0 && userIntLimit < 101;
    const limit = isLimitInRange ? userIntLimit : 10;

    const authorsResults = await authorsIndex.search(query, {
      hitsPerPage: limit,
      page: page,
    });

    res.send({ response: authorsResults });
  })
  .get('/references', async (req, res) => { 
    const query = req.query.q as string ?? '';

    if (!query) {
      res.status(400).send({
        error: {
          reason: `You must specify a search query with [?q=yourquery]. 
            The search query was empty.`,
        }
      });

      return;
    }

    const strPage = req.query.page as string ?? '0';
    const page = parseInt(strPage);

    const userStrLimit = req.query.limit as string ?? '12';
    const userIntLimit = parseInt(userStrLimit);

    const isLimitInRange = userIntLimit > 0 && userIntLimit < 101;
    const limit = isLimitInRange ? userIntLimit : 10;

    const referencesResults = await referencesIndex.search(query, {
      hitsPerPage: limit,
      page: page,
    });

    res.send({ response: referencesResults});
  });
