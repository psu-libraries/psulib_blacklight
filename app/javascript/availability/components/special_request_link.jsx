import PropTypes from 'prop-types';
import { useEffect, useState } from 'react';
import availability from '../index';
import illLinkUrl from '../ill_link_url';
import aeonLinkUrl from '../aeon_link_url';
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
          const author = encodeURIComponent(data.author_tsim || '');
          const pubDate = data.pub_date_illiad_ssm || '';
          const urlArgs = {
            linkUrl,
            data,
            title,
            author,
            pubDate,
            holding,
            callNumber,
          };
          if (locationText) {
            urlArgs.locationText = locationText;
            urlArgs.catkey = catkey;
            linkUrl = aeonLinkUrl(urlArgs);
          } else {
            linkUrl = illLinkUrl(urlArgs);
          }
        }
      })
      .catch(() => {})
      .finally(() => {
        setShowSpinner(false);
        setUrl(linkUrl);
      });
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
