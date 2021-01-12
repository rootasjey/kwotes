interface IQuote {
  name: string;
  date: Date;
  id: string;
  author: {
    id: string;
    name: string;
  };
}

interface IQuoteParams {
  date: Date;
  name: string;
  id: string;
  author: {
    id: string;
    name: string;
  };
}
