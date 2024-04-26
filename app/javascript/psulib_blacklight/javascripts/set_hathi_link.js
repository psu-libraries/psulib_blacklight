export default function setHathiLink() {
  const element = document.getElementById('hathi-link');
  const urlComponents = {
    hathiTrustUrl: '/links/hathi-link',
    searchItem: element?.dataset?.searchItem,
  };
  const { hathiTrustUrl, searchItem } = urlComponents;
  const hathiLinkUrlQuery = `${hathiTrustUrl}/?search_item=${searchItem}`;

  if (searchItem) {
    $.ajax({
      // Do not run as async request
      // Needs to run in same thread to determine if Google Preview is needed
      async: false,
      url: hathiLinkUrlQuery,
      success(response) {
        const { itemUrl: url } = response;
        if (url) {
          setLink(url);
        }
      },
    });
  }

  function setLink(itemUrl) {
    element.firstElementChild.href = itemUrl;
    element.style.display = 'revert';
  }
}
