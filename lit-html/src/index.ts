import { Router } from '@vaadin/router';
import './app';

const routes = [
  {
    path: '/',
    component: 'lit-app',
    children: []
  },
];

const outlet = document.getElementById('outlet');
export const router = new Router(outlet);
router.setRoutes(routes);
