$(document).ready(() => {
  const element = document.getElementById('google-preview');
  const urlComponents = {
    googlePreviewUrl: '/preview/google-preview-data',
    searchItem: element.dataset.searchItem,
  };
  const { googlePreviewUrl, searchItem } = urlComponents;
  const googlePreviewUrlQuery = `${googlePreviewUrl}/?search_item=${searchItem}`;

  if (searchItem) {
    $.ajax({
      url: googlePreviewUrlQuery,
      success(response) {
        const bookInfo = response[searchItem];
        if (bookInfo) {
          setPreviewButton(bookInfo);
        } else {
          for (const key in response) {
            const bookInfoIter = response[key];
            setPreviewButton(bookInfoIter);
          }
        }
      },
    });
  }

  let setPreviewButton = function (bookInfo) {
    element.firstElementChild.href = bookInfo.preview_url;
    if (bookInfo.preview === 'full') {
      element.firstElementChild.innerHTML += 'Full View in Google Books';
      element.style.display = '';
    } else if (bookInfo.preview === 'partial') {
      element.firstElementChild.innerHTML += 'Preview in Google Books';
      element.style.display = '';
    }
  };
});
