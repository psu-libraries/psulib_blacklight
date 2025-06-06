import PropTypes from 'prop-types';
import { useEffect, useState } from 'react';
import availability from '../index';
import SpinnerLink from './spinner_link';

const cache = {};

const clearCache = () => {
  Object.keys(cache).forEach((key) => {
    delete cache[key];
  });
};

const SpecialRequestLink = ({ holding, locationText }) => {
  const [hasData, setHasData] = useState(false);
  const [showSpinner, setShowSpinner] = useState(true);
  const [url, setUrl] = useState('#');
  const { catkey } = holding;
  const callNumber = encodeURIComponent(holding.callNumber);

  useEffect(() => {
    createUrl();
  }, []);

  const fetchJson = (jsonUrl) => {
    if (!cache[jsonUrl]) {
      return fetch(jsonUrl)
        .then((response) => response.json())
        .then((data) => {
          cache[jsonUrl] = data;
          return data;
        });
    }
    return Promise.resolve(cache[jsonUrl]);
  };

  const createUrl = () => {
    let linkUrl = locationText
      ? 'https://aeon.libraries.psu.edu/RemoteAuth/aeon.dll'
      : 'https://psu.illiad.oclc.org/illiad/';
    fetchJson(`/catalog/${catkey}/raw.json`)
      .then((data) => {
        if (Object.keys(data).length > 0) {
          setHasData(true);
          const title = encodeURIComponent(data.title_245ab_tsim);
          const author = encodeURIComponent(data.author_tsim || '');
          const pubDate = data.pub_date_illiad_ssm || '';
          if (locationText) {
            linkUrl = aeonLinkUrl(linkUrl, data, title, author, pubDate);
          } else {
            linkUrl = illLinkUrl(linkUrl, data, title, author, pubDate);
          }
        }
      })
      .catch(() => {})
      .finally(() => {
        setShowSpinner(false);
        setUrl(linkUrl);
      });
  };

  const illLinkUrl = (linkUrl, data, title, author, pubDate) => {
    const itemLocation = encodeURIComponent(holding.locationID);
    const linkType = encodeURIComponent(illLinkType());
    linkUrl += 'upm/illiad.dll/OpenURL?Action=10';
    if (linkType === 'archival-thesis') {
      linkUrl += '&Form=20&Genre=GenericRequestThesisDigitization';
    } else {
      const isbnField = data.isbn_valid_ssm;
      const isbn =
        !isbnField || isbnField.length === 0 ? '' : data.isbn_valid_ssm[0];
      linkUrl += `&Form=30&isbn=${isbn}`;
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
    if (catkey) {
      linkUrl += `&catkey=${catkey}`;
    }
    return linkUrl;
  };

  const illLinkType = () => {
    if (availability.isReserves(holding)) return 'reserves-scan';
    if (availability.isMicroform(holding)) return 'news-microform-scan';
    if (availability.isArchivalThesis(holding)) return 'archival-thesis';

    return 'request-via-ill';
  };

  const aeonLinkUrl = (linkUrl, data, title, author, pubDate) => {
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
  };

  const publisher = (data) =>
    encodeURIComponent(data.publisher_name_ssm ? data.publisher_name_ssm : '');

  const pubPlace = (data) =>
    encodeURIComponent(
      data.publication_place_ssm ? data.publication_place_ssm : '',
    );

  const edition = (data) =>
    encodeURIComponent(
      data.edition_display_ssm ? data.edition_display_ssm : '',
    );

  const restrictions = (data) =>
    encodeURIComponent(
      data.restrictions_access_note_ssm
        ? data.restrictions_access_note_ssm
        : '',
    );

  const subLocation = (data) =>
    encodeURIComponent(
      data.sublocation_ssm ? data.sublocation_ssm.join('; ') : '',
    );

  const label = () => {
    let text = '';
    if (locationText) {
      if (!hasData) {
        text = 'Use Aeon to request this item';
      } else {
        text = availability.isArchivalThesis(holding)
          ? 'View in Special Collections'
          : 'Request Material';
      }
    } else if (!hasData) {
      text = 'Use ILLiad to request this item';
    } else if (
      availability.isMicroform(holding) ||
      availability.isArchivalThesis(holding)
    ) {
      text = 'Request Scan - Penn State Users';
    }
    return text || availability.illiadLocations[holding.locationID];
  };

  const linkTarget = () => (hasData ? null : '_blank');

  return (
    <SpinnerLink
      label={label()}
      linkTarget={linkTarget()}
      showSpinner={showSpinner}
      url={url}
    />
  );
};

// eslint-react: defines valid prop types passed to this component
SpecialRequestLink.propTypes = {
  holding: PropTypes.object,
  locationText: PropTypes.string,
};

export { clearCache };
export default SpecialRequestLink;
