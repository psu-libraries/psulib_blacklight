import PropTypes from 'prop-types';
import { useEffect, useState } from 'react';
import availability from '../index';
import SpinnerLink from './spinner_link';

const SpecialRequestLink = ({ holding, locationText }) => {
  const [hasData, setHasData] = useState(false);
  const [showSpinner, setShowSpinner] = useState(true);
  const [url, setUrl] = useState('#');

  useEffect(() => {
    if (locationText) {
      createAeonUrl();
    } else {
      createIllUrl();
    }
  }, []);

  const fetchJson = (jsonUrl) =>
    fetch(jsonUrl).then((response) => response.json());

  const createIllUrl = () => {
    let illUrl =
      'https://psu-illiad-oclc-org.ezaccess.libraries.psu.edu/illiad/';
    const { catkey } = holding;
    const callNumber = encodeURIComponent(holding.callNumber);
    const linkType = encodeURIComponent(illLinkType());
    const itemLocation = encodeURIComponent(holding.locationID);

    fetchJson(`/catalog/${catkey}/raw.json`)
      .then((data) => {
        if (Object.keys(data).length > 0) {
          setHasData(true);

          const title = encodeURIComponent(data.title_245ab_tsim);
          const author = encodeURIComponent(
            data.author_tsim ? data.author_tsim : ''
          );
          const pubDate = data.pub_date_illiad_ssm
            ? data.pub_date_illiad_ssm
            : '';

          illUrl += 'upm/illiad.dll/OpenURL?Action=10';
          if (linkType === 'archival-thesis') {
            illUrl += '&Form=20&Genre=GenericRequestThesisDigitization';
          } else {
            const ISBN = data.isbn_valid_ssm[0] ? data.isbn_valid_ssm[0] : '';
            illUrl += `&Form=30&isbn=${ISBN}`;
          }
          if (linkType === 'reserves-scan') {
            illUrl += `&Genre=GenericRequestReserves&location=${itemLocation}`;
          }
          if (linkType === 'news-microform-scan') {
            illUrl += `&Genre=GenericRequestMicroScan&location=${itemLocation}`;
          }
          illUrl += `&title=${title}&callno=${callNumber}&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu`;
          if (author) {
            illUrl += `&aulast=${author}`;
          }
          if (pubDate) {
            illUrl += `&date=${pubDate}`;
          }
        }
      })
      .catch(() => { })
      .finally(() => {
        setShowSpinner(false);
        setUrl(illUrl);
      });
  };

  const illLinkType = () => {
    if (availability.isReserves(holding)) return 'reserves-scan';
    if (availability.isMicroform(holding)) return 'news-microform-scan';
    if (availability.isArchivalThesis(holding)) return 'archival-thesis';

    return 'request-via-ill';
  };

  const createAeonUrl = () => {
    const { catkey } = holding;
    const callNumber = encodeURIComponent(holding.callNumber);
    const itemLocation = encodeURIComponent(locationText);
    const itemID = encodeURIComponent(holding.itemID);
    const { itemTypeID } = holding;
    const genre = itemTypeID === 'ARCHIVES' ? 'ARCHIVES' : 'BOOK';
    let aeonUrl = 'https://aeon.libraries.psu.edu/RemoteAuth/aeon.dll';

    fetchJson(`/catalog/${catkey}/raw.json`)
      .then((data) => {
        if (Object.keys(data).length > 0) {
          setHasData(true);

          aeonUrl =
            'https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30' +
            `&ReferenceNumber=${catkey}&Genre=${genre}&Location=${itemLocation}` +
            `&ItemNumber=${itemID}&CallNumber=${callNumber}`;

          const title = encodeURIComponent(data.title_245ab_tsim);
          const author = encodeURIComponent(
            data.author_tsim ? data.author_tsim : ''
          );
          const publisher = encodeURIComponent(
            data.publisher_name_ssm ? data.publisher_name_ssm : ''
          );
          const pubDate = encodeURIComponent(
            data.pub_date_illiad_ssm ? data.pub_date_illiad_ssm : ''
          );
          const pubPlace = encodeURIComponent(
            data.publication_place_ssm ? data.publication_place_ssm : ''
          );
          const edition = encodeURIComponent(
            data.edition_display_ssm ? data.edition_display_ssm : ''
          );
          const restrictions = encodeURIComponent(
            data.restrictions_access_note_ssm
              ? data.restrictions_access_note_ssm
              : ''
          );
          const subLocation = encodeURIComponent(
            data.sublocation_ssm ? data.sublocation_ssm.join('; ') : ''
          );
          aeonUrl +=
            `&ItemTitle=${title}&ItemAuthor=${author}&ItemEdition=${edition}&ItemPublisher=` +
            `${publisher}&ItemPlace=${pubPlace}&ItemDate=${pubDate}&ItemInfo1=${restrictions}` +
            `&SubLocation=${subLocation}`;
        }
      })
      .catch(() => { })
      .finally(() => {
        setShowSpinner(false);
        setUrl(aeonUrl);
      });
  };

  const label = () => {
    if (locationText) {
      if (!hasData) {
        return 'Use Aeon to request this item';
      }

      return availability.isArchivalThesis(holding)
        ? 'View in Special Collections'
        : 'Request Material';
    }
    if (!hasData) {
      return 'Use ILLiad to request this item';
    }

    if (
      availability.isMicroform(holding) ||
      availability.isArchivalThesis(holding)
    ) {
      return 'Request Scan - Penn State Users';
    }

    return availability.illiadLocations[holding.locationID];
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

export default SpecialRequestLink;
