import PropTypes from 'prop-types';
import availability from '../index';
import SpecialRequestLink from './special_request_link';

const LocationInfo = ({ holding }) => {
  const mapLocation = (locationID) =>
    locationID in availability.allLocations
      ? availability.allLocations[locationID]
      : '';

  // Microform
  if (availability.isMicroform(holding)) {
    return (
      <>
        {mapLocation(holding.locationID)}
        <br />
        <SpecialRequestLink holding={holding} />
      </>
    );
  }

  // Location information presented to the user is different based on a few scenarios
  // First, if it's related to ILL
  if (availability.isIllLink(holding)) {
    return <SpecialRequestLink holding={holding} />;
  }

  // AEON
  if (availability.isArchivalThesis(holding)) {
    const illiadURL =
      'https://psu.illiad.oclc.org/upm2/lending/lendinglogon.html';
    const aeonLocationText = mapLocation(holding.locationID);

    return (
      <>
        <SpecialRequestLink holding={holding} />

        <br />

        <a href={illiadURL}>Request Scan - Guest</a>

        <br />

        <SpecialRequestLink holding={holding} locationText={aeonLocationText} />
      </>
    );
  }

  // Special Collections
  if (availability.isArchivalMaterial(holding)) {
    const specialCollectionsText = mapLocation(holding.locationID);

    return (
      <>
        {specialCollectionsText}

        <br />

        <SpecialRequestLink
          holding={holding}
          locationText={specialCollectionsText}
        />
      </>
    );
  }

  // Otherwise use the default translation map for location display, no link
  return mapLocation(holding.locationID);
};

// eslint-react: defines valid prop types passed to this component
LocationInfo.propTypes = {
  holding: PropTypes.object,
};

export default LocationInfo;
