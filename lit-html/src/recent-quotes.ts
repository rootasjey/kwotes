import '@kor-ui/kor/components/card';
import '@kor-ui/kor/components/text';

import { LitElement, html, customElement, property, css } from 'lit-element';

import firebase from 'firebase/app';

import { Quote } from './types/Quote';

@customElement('recent-quotes')
export class RecentQuotes extends LitElement {

  @property({ type: Boolean }) isLoading = false;
  @property({ type: Boolean }) hasErrors = false;
  @property({ type: [Quote] }) quotes: Array<Quote> = [];

  static styles = css`
  :host {
    display: block;
    margin-top: 50px;
  }

  kor-card {
    margin-bottom: 20px;
    text-align: left;
  }
  `;

  firstUpdated() {
    this.fetchRecent();
  }

  async fetchRecent() {
    this.isLoading = true;
    const firestore = firebase.firestore();

    firestore
      .collection('quotes')
      .orderBy('createdAt', 'desc')
      .where('lang', '==', 'en')
      .limit(10)
      .get()
      .then((querySnapshot) => {
        querySnapshot.forEach((doc) => {
          const data = doc.data();

          if (data) {
            const quote = Quote.fromJSON({...data, ...{id: doc.id}});
            this.quotes.push(quote);
          }
        });

        this.isLoading = false;
      });
  }

  render() {
    return html`
      ${this.quotes.map((quote) => {
        return html`
          <kor-card>
            <kor-text size="header-2">
              ${quote.name}
            </kor-text>
            <kor-text size="body-2">
              ― ${quote.author.name}
            </kor-text>
          </kor-card>
        `;
      })}
    `;
  }
}
