export async function hathilink() {
  const element = document.getElementById("hathilink");

  const urlComponents = {
    hathitrustUrl: 'https://catalog.hathitrust.org/api/volumes/brief/',
    searchItem: element?.dataset?.searchItem,
  };
  const { hathitrustUrl, searchItem } = urlComponents;
  const hathiLinkUrlQuery = `${hathitrustUrl}${searchItem}.json`;

  if (searchItem) {
    $.ajax({
      // This whole function is async so make the ajax synchronous
      async: false,
      url: hathiLinkUrlQuery,
      success(response) {
        const bookInfo = response["items"];
        if (bookInfo) {
          setLink(bookInfo, element);
        }
      },
    });
  }

  function setLink(bookInfo, element) {
    for (let i = 0; i < bookInfo.length; i++) {
      if (bookInfo[i].usRightsString === "Full view") {
        element.firstElementChild.href = bookInfo[i].itemURL;
        element.classList.remove("d-none");
        return
      }
    }
  };
};
