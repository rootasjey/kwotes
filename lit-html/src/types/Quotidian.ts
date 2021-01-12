import { Quote } from './Quote';

export class Quotidian implements IQuotidian {
  date = new Date();
  quote = {
    date: new Date(),
    name: '',
    id: '',
    author: {id: '', name: '',},
  };

  constructor({ date, quote }: IQuotidianParams) {
    this.date = date;
    this.quote = new Quote(quote);
  }

  static fromJSON(data: any) {
    return new Quotidian({ date: new Date(), quote: data.quote });
  }

  static empty() {
    return new Quotidian({ 
      date: new Date(), 
      quote: Quote.empty(), 
    });
  }
}
