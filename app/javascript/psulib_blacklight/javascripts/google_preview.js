$(document).ready(() => {
  const element = document.getElementById('google-preview');

  // Function to process GBS info and update the dom.
  window.ProcessGBSBookInfo = function (booksInfo) {
    for (const key in booksInfo) {
      const bookInfo = booksInfo[key];
      if (bookInfo) {
        element.href = bookInfo.preview_url;
        if (bookInfo.preview === 'full') {
          element.innerHTML += 'Full View in Google Books';
          element.style.display = '';
        } else if (bookInfo.preview === 'partial') {
          element.innerHTML += 'Preview in Google Books';
          element.style.display = '';
        }
      }
    }
  };

  if (element) {
    const searchItem = element.attributes.data.value;
    const script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = `//books.google.com/books?jscmd=viewapi&bibkeys=${searchItem}&callback=ProcessGBSBookInfo`;
    document.getElementsByTagName('head')[0].appendChild(script);
  }
});
