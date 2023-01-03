import availability from './index';

function illLinkUrl({
  linkUrl,
  data,
  title,
  author,
  pubDate,
  holding,
  callNumber,
}) {
  const linkType = encodeURIComponent(illLinkType(holding));
  const itemLocation = encodeURIComponent(holding.locationID);
  linkUrl += 'upm/illiad.dll/OpenURL?Action=10';
  if (linkType === 'archival-thesis') {
    linkUrl += '&Form=20&Genre=GenericRequestThesisDigitization';
  } else {
    const ISBN = data.isbn_valid_ssm[0] ? data.isbn_valid_ssm[0] : '';
    linkUrl += `&Form=30&isbn=${ISBN}`;
  }
  if (linkType === 'reserves-scan') {
    linkUrl += `&Genre=GenericRequestReserves&location=${itemLocation}`;
  }
  if (linkType === 'news-microform-scan') {
    linkUrl += `&Genre=GenericRequestMicroScan&location=${itemLocation}`;
  }
  linkUrl += `&title=${title}&callno=${callNumber}&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu`;
  if (author) {
    linkUrl += `&aulast=${author}`;
  }
  if (pubDate) {
    linkUrl += `&date=${pubDate}`;
  }
  return linkUrl;
}

const illLinkType = (holding) => {
  if (availability.isReserves(holding)) return 'reserves-scan';
  if (availability.isMicroform(holding)) return 'news-microform-scan';
  if (availability.isArchivalThesis(holding)) return 'archival-thesis';

  return 'request-via-ill';
};

export default illLinkUrl;
