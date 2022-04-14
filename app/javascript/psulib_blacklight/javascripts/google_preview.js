$(document).ready(() => {
  const element = document.getElementById('google-preview');
  const googlePreviewUrl = '/preview/google-preview-data';
  const googlePreviewUrlQuery = `${googlePreviewUrl}/?search_item=${element.attributes.data.value.toString()}`;

  if (element) {
    $.ajax({
      url: googlePreviewUrlQuery,
      success(response) {
        for (const key in response) {
          const bookInfo = response[key];
          if (bookInfo) {
            element.firstElementChild.href = bookInfo.preview_url;
            if (bookInfo.preview === 'full') {
              element.firstElementChild.innerHTML +=
                'Full View in Google Books';
              element.style.display = '';
            } else if (bookInfo.preview === 'partial') {
              element.firstElementChild.innerHTML += 'Preview in Google Books';
              element.style.display = '';
            }
          }
        }
      },
    });
  }
});
