import { 
  LitElement, 
  html, 
  css, 
  property, 
  customElement,
 } from 'lit-element';

import '@kor-ui/kor/components/app-bar';
import '@kor-ui/kor/components/page';
import '@kor-ui/kor/components/card';
import '@kor-ui/kor/components/text';
import '@kor-ui/kor/components/button';
import '@kor-ui/kor/components/spinner';

import './hero-quote';
import './recent-quotes';

@customElement('lit-app')
export class App extends LitElement {
  @property({ type: String }) title = 'My app';

  static styles = css`
    :host {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: flex-start;
      font-size: calc(10px + 2vmin);
      color: #1a2b42;
      max-width: 960px;
      margin: 0 auto;
      text-align: center;
      background-color: var(--fig-style-background-color);
    }
  `;

  render() {
    return html`
      <kor-page>
        <kor-app-bar label="fig.style" slot="top" logo="../resources/images/app-icon-90.png"></kor-app-bar>
        <div>
          <hero-quote></hero-quote>
          <recent-quotes></recent-quotes>
        </div>
      </kor-page>
    `;
  }
}
