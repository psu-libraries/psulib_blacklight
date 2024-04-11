function hathilink() {
  const elements = document.getElementsByClassName("hathilink");
  const googlePreviewElement = document.getElementById('google-preview');

  for (let i = 0; i < elements.length; i++) {
    const urlComponents = {
      hathitrustUrl: 'https://catalog.hathitrust.org/api/volumes/brief/',
      searchItem: elements[i].dataset.searchItem,
    };
    const { hathitrustUrl, searchItem } = urlComponents;
    const hathiLinkUrlQuery = `${hathitrustUrl}${searchItem}.json`;

    if (searchItem) {
      $.ajax({
        url: hathiLinkUrlQuery,
        success(response) {
          const bookInfo = response["items"];
          if (bookInfo) {
            setLink(bookInfo, elements[i]);
          }
        },
      });
    }

    let setLink = function (bookInfo, element) {
      for (let i = 0; i < bookInfo.length; i++) {
        if (bookInfo[i].usRightsString === "Full view") {
          element.firstElementChild.href = bookInfo[i].itemURL;
          element.style.display = '';
          // return to break the loop and return true so we know we don't need a google preview
          return true
        }
      }
      // return false so we know we should try google preview
      return false
    };
  };
};

export { hathilink };