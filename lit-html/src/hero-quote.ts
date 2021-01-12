import '@kor-ui/kor/components/card';
import '@kor-ui/kor/components/text';

import { LitElement, html, customElement, PropertyValues, property, css } from 'lit-element';

import firebase from 'firebase/app';

import { Quotidian } from './types/Quotidian';

@customElement('hero-quote')
export class HeroQuote extends LitElement {

  @property({ type: Boolean }) isLoading = false;
  @property({ type: Boolean }) hasErrors = false;
  @property({ type: Quotidian }) quotidian: Quotidian;

  static styles = css`
    :host {
      display: block;
      line-height: 1.2em;
      text-align: left;
    }
    
    :host kor-text {
      font-size: 1.7em;
      line-height: 1.2em;
      overflow: hidden;
    }
  `;


  constructor() {
    super();
    this.quotidian = Quotidian.empty();
  }

  firstUpdated(changedProperties: PropertyValues) {
    this.fetchQuotidian();
    super.firstUpdated(changedProperties);
  }

  async fetchQuotidian() {
    this.isLoading = true;
    const firestore = firebase.firestore();

    const now = new Date();

    const monthNumber = now.getMonth() + 1;
    const month = monthNumber > 9 ? monthNumber : `0${monthNumber}`;

    const dateNumber = now.getDate();
    const date = dateNumber > 9 ? dateNumber : `0${dateNumber}`;

    const lang = 'en';

    const dateId = `${now.getFullYear()}:${month}:${date}:${lang}`;

    try {
      const querySnapshot = await firestore
        .collection('quotidians')
        .doc(dateId)
        .get();

      const data = querySnapshot.data();

      if (!data) {
        return;
      }

      this.quotidian = Quotidian.fromJSON({ date: new Date(), quote: data.quote });
      this.isLoading = false;

    } catch (error) {
      this.isLoading = false;
      this.hasErrors = true;
      // console.error(error);
    }
  }


  render() {
    return html`
      <kor-card>
        <kor-text size="header-1">
          ${this.quotidian.quote.name}
        </kor-text>
      </kor-card>
    `;
  }
}
