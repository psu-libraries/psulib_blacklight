export default function googlePreview() {
  const element = document.getElementById('google-preview');
  const urlComponents = {
    googlePreviewUrl: '/links/google-preview-data',
    searchItem: element?.dataset?.searchItem,
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
      element.firstElementChild.innerHTML += 'Read online at Google Books';
      element.style.display = 'revert';
    } else if (bookInfo.preview === 'partial') {
      element.firstElementChild.innerHTML += 'Search inside at Google Books';
      element.style.display = 'revert';
    }
  };
}
