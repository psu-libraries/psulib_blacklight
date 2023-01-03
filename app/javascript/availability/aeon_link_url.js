function aeonLinkUrl({
  linkUrl,
  data,
  title,
  author,
  pubDate,
  holding,
  callNumber,
  locationText,
  catkey,
}) {
  const itemLocation = encodeURIComponent(locationText);
  const itemID = encodeURIComponent(holding.itemID);
  const { itemTypeID } = holding;
  const genre = itemTypeID === 'ARCHIVES' ? 'ARCHIVES' : 'BOOK';
  linkUrl =
    'https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30' +
    `&ReferenceNumber=${catkey}&Genre=${genre}&Location=${itemLocation}` +
    `&ItemNumber=${itemID}&CallNumber=${callNumber}` +
    `&ItemTitle=${title}&ItemAuthor=${author}&ItemEdition=${edition(data)}` +
    `&ItemPublisher=${publisher(data)}&ItemPlace=${pubPlace(data)}` +
    `&ItemDate=${pubDate}&ItemInfo1=${restrictions(data)}` +
    `&SubLocation=${subLocation(data)}`;
  return linkUrl;
}

const publisher = (data) =>
  encodeURIComponent(data.publisher_name_ssm ? data.publisher_name_ssm : '');

const pubPlace = (data) =>
  encodeURIComponent(
    data.publication_place_ssm ? data.publication_place_ssm : ''
  );

const edition = (data) =>
  encodeURIComponent(data.edition_display_ssm ? data.edition_display_ssm : '');

const restrictions = (data) =>
  encodeURIComponent(
    data.restrictions_access_note_ssm ? data.restrictions_access_note_ssm : ''
  );

const subLocation = (data) =>
  encodeURIComponent(
    data.sublocation_ssm ? data.sublocation_ssm.join('; ') : ''
  );

export default aeonLinkUrl;
