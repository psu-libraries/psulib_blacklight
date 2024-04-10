function hathilink() {
  const elements = document.getElementsByClassName("hathilink");
  const googlePreviewElement = document.getElementById('google-preview');

  for (var n = 0; n < elements.length; n++) {
    const urlComponents = {
      hathitrustUrl: 'https://catalog.hathitrust.org/api/volumes/brief/',
      searchItem: elements[n].dataset.searchItem,
    };
    const { hathitrustUrl, searchItem } = urlComponents;
    const hathiLinkUrlQuery = `${hathitrustUrl}${searchItem}.json`;

    if (searchItem) {
      $.ajax({
        url: hathiLinkUrlQuery,
        success(response) {
          const bookInfo = response["items"];
          if (bookInfo) {
            setLink(bookInfo);
          }
        },
      });
    }

    let setLink = function (bookInfo) {
      for (var i = 0; i < bookInfo.length; i++) {
        if (bookInfo[i].usRightsString === "Full view") {
          elements[n].firstElementChild.href = bookInfo[i].itemURL;
          elements[n].style.display = '';
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