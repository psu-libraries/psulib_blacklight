export function hathilink() {
  const element = document.getElementById("hathilink");
  const urlComponents = {
    hathitrustUrl: '/links/hathi-link',
    searchItem: element?.dataset?.searchItem,
  };
  const { hathitrustUrl, searchItem } = urlComponents;
  const hathiLinkUrlQuery = `${hathitrustUrl}/?search_item=${searchItem}`;

  if (searchItem) {
    $.ajax({
      // Do not run as async request
      // Needs to run to completion to determine if Google Preview is needed
      async: false,
      url: hathiLinkUrlQuery,
      success(response) {
        const itemUrl = response["itemUrl"];
        if (itemUrl) {
          setLink(itemUrl, element);
        }
      },
    });
  }

  function setLink(itemUrl, element) {
    element.firstElementChild.href = itemUrl;
    element.classList.remove("d-none");
  }
};
