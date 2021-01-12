// @ts-ignore
import { html, fixture, expect } from '@open-wc/testing';

import { App } from '../src/app.js';
import '../src/fig-style.js';

describe('FigStyle', () => {
  let element: App;
  beforeEach(async () => {
    element = await fixture(html`<fig-style></fig-style>`);
  });

  it('renders a h1', () => {
    const h1 = element.shadowRoot!.querySelector('h1')!;
    expect(h1).to.exist;
    expect(h1.textContent).to.equal('My app');
  });

  it('passes the a11y audit', async () => {
    await expect(element).shadowDom.to.be.accessible();
  });
});
