import * as express from 'express';
const cors = require('cors');

import { v1Router } from './v1/index';

const main = express();

main.use(cors());
main.use(express.json());
main.use('/v1', v1Router);

export const apiModule = main;
