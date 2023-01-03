import PropTypes from 'prop-types';
import { useEffect, useState } from 'react';
import availability from '../index';
import SpinnerLink from './spinner_link';

const SpecialRequestLink = ({ holding, locationText }) => {
  const [hasData, setHasData] = useState(false);
  const [showSpinner, setShowSpinner] = useState(true);
  const [url, setUrl] = useState('#');
  const { catkey } = holding;
  const callNumber = encodeURIComponent(holding.callNumber);

  useEffect(() => {
    createUrl();
  }, []);

  const fetchJson = (jsonUrl) =>
    fetch(jsonUrl).then((response) => response.json());

  const createUrl = () => {
    let linkUrl = locationText
      ? 'https://aeon.libraries.psu.edu/RemoteAuth/aeon.dll'
      : 'https://psu-illiad-oclc-org.ezaccess.libraries.psu.edu/illiad/';
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

          if (locationText) {
            const itemLocation = encodeURIComponent(locationText);
            const itemID = encodeURIComponent(holding.itemID);
            const { itemTypeID } = holding;
            const genre = itemTypeID === 'ARCHIVES' ? 'ARCHIVES' : 'BOOK';
            linkUrl =
              'https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30' +
              `&ReferenceNumber=${catkey}&Genre=${genre}&Location=${itemLocation}` +
              `&ItemNumber=${itemID}&CallNumber=${callNumber}`;

            const publisher = encodeURIComponent(
              data.publisher_name_ssm ? data.publisher_name_ssm : ''
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
            linkUrl +=
              `&ItemTitle=${title}&ItemAuthor=${author}&ItemEdition=${edition}&ItemPublisher=` +
              `${publisher}&ItemPlace=${pubPlace}&ItemDate=${pubDate}&ItemInfo1=${restrictions}` +
              `&SubLocation=${subLocation}`;
          } else {
            const linkType = encodeURIComponent(illLinkType());
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
          }
        }
      })
      .catch(() => {})
      .finally(() => {
        setShowSpinner(false);
        setUrl(linkUrl);
      });
  };

  const illLinkType = () => {
    if (availability.isReserves(holding)) return 'reserves-scan';
    if (availability.isMicroform(holding)) return 'news-microform-scan';
    if (availability.isArchivalThesis(holding)) return 'archival-thesis';

    return 'request-via-ill';
  };

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

export default SpecialRequestLink;
