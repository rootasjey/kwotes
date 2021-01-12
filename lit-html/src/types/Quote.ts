export class Quote implements IQuote {
  name = '';
  id = '';
  author = {
    id: '',
    name: '',
  };
  date = new Date();

  constructor(data: IQuoteParams) {
    const { id, name, date, author } = data;
    this.name = name;
    this.id = id;
    this.date = date;
    this.author = author;
  }

  static fromJSON(data: any) {
    return new Quote({ 
      id: data.id,
      date: new Date(), 
      name: data.name, 
      author: {
        id: data.author.id,
        name: data.author.name,
      },
    });
  }

  static empty() {
    return new Quote({ 
      date: new Date(), 
      name: '' ,
      id: '',
      author: {
        id: '',
        name: '',
      },
    });
  }
}
