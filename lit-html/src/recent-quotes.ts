import { 
  LitElement, 
  html, 
  customElement, 
  property, 
  css,
 } from 'lit-element';

import { classMap } from 'lit-html/directives/class-map';
import { styleMap } from 'lit-html/directives/style-map';

import firebase from 'firebase/app';

import { Quote } from './types/Quote';

interface QuoteDocument 
  extends firebase.firestore.QueryDocumentSnapshot<firebase.firestore.DocumentData> {
}
@customElement('recent-quotes')
export class RecentQuotes extends LitElement {

  @property({ type: Boolean }) isLoading = false;
  @property({ type: Boolean }) isLoadingMore = false;
  @property({ type: Boolean }) hasErrors = false;
  @property({ type: Boolean }) hasNext = true;
  @property({ type: [Quote] }) quotes: Array<Quote> = [];
  @property({ type: Object }) lastFetchedDoc: QuoteDocument | undefined;
  @property({ type: Function }) bindedOnReachBottomPage: () => void | undefined;
  @property({ type: Number }) limit = 10;
  @property({ type: Boolean }) isPageScrolled = false;
  @property({ type: Object }) fabClasses = { fab: true, visible: false };
  @property({ type: Object }) fabStyles = { position: 'fixed' };

  static styles = css`
  :host {
    display: block;
    margin-top: 50px;
  }

  kor-card {
    margin-bottom: 20px;
    text-align: left;
  }

  .fab {
    position: fixed;
    bottom: 20px;
    right: 20px;
    visibility: hidden;
  }
  .fab.visible {
    visibility: visible;
  }
  `;

  constructor() {
    super();
    this.bindedOnReachBottomPage = this.onReachBottomPage.bind(this);
  }

  connectedCallback() {
    super.connectedCallback();
    if (!this.bindedOnReachBottomPage) { return; }
    document.body.addEventListener('scroll', this.bindedOnReachBottomPage);
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    document.body.removeEventListener('scroll', this.bindedOnReachBottomPage);
  }

  onReachBottomPage() {
    const viewportH = document.body.scrollHeight - document.body.clientHeight;

    // console.log(document.body.scrollTop);
    // if (document.body.scrollTop > 100 && !this.isPageScrolled) {
    //   this.isPageScrolled = true;
    // } else if (document.body.scrollTop <= 100 && this.isPageScrolled) {
    //   this.isPageScrolled = false;
    // }
    
    if (document.body.scrollTop >= viewportH) {
      this.fetchMoreRecent();
    }
  }

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
      .limit(this.limit)
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
        this.hasNext = querySnapshot.size >= this.limit;
        this.lastFetchedDoc = querySnapshot.docs[querySnapshot.size - 1];
      });
  }

  async fetchMoreRecent() {
    if (!this.hasNext || !this.lastFetchedDoc || this.isLoadingMore) {
      return;
    }
    
    this.isLoadingMore = true;
    const firestore = firebase.firestore();

    firestore
      .collection('quotes')
      .orderBy('createdAt', 'desc')
      .where('lang', '==', 'en')
      .limit(this.limit)
      .startAfter(this.lastFetchedDoc)
      .get()
      .then((querySnapshot) => {
        if (querySnapshot.empty) {
          
          this.hasNext = false;
          this.isLoadingMore = false;
          return;
        }

        querySnapshot.forEach((doc) => {
          const data = doc.data();

          if (data) {
            const quote = Quote.fromJSON({...data, ...{id: doc.id}});
            this.quotes.push(quote);
          }
        });
        
        this.isLoadingMore = false;
        this.hasNext = querySnapshot.size >= this.limit;
        this.lastFetchedDoc = querySnapshot.docs[querySnapshot.size - 1];
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

      ${this.isLoadingMore ?
        html`<kor-spinner label="Loading more quotes..."></kor-spinner>` :
        html`
        <kor-button
          label="Load more..."
          @click=${this.fetchMoreRecent}>
        </kor-button>
        `
      }

<kor-button style=${styleMap(this.fabStyles)} label="scroll to top"></kor-button>
      <!-- <div class=${classMap(this.fabClasses)}>
      </div> -->
    `;
  }
}
