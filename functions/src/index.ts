import * as functions         from 'firebase-functions';

import { apiModule }          from './api/index';

import * as authorsFunc       from './authors';
import * as developersFunc    from './developers';
import * as draftsFunc        from './drafts';
import * as imagesFunc        from './images';
import * as listsFunc         from './lists';
import * as mentionsFunc      from './mentions';
import * as notificationsFunc from './notifications';
import * as quotesFunc        from './quotes';
import * as randomsFunc       from './randoms';
import * as referencesFunc    from './references';
import * as searchFunc        from './search';
import * as metricsFunc       from './metrics';
import * as usersFunc         from './users';

export const authors        = authorsFunc;
export const developers     = developersFunc;
export const drafts         = draftsFunc;
export const images         = imagesFunc;
export const lists          = listsFunc;
export const notifications  = notificationsFunc;
export const mentions       = mentionsFunc;
export const quotes         = quotesFunc;
export const randoms        = randomsFunc;
export const references     = referencesFunc;
export const search         = searchFunc;
export const metrics        = metricsFunc;
export const users          = usersFunc;

// API
export const api = functions
  .region('us-central1')
  .https
  .onRequest(apiModule);
