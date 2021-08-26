import PropTypes from 'prop-types';
import availability from '../index.js';
import IllLink from './ill_link.jsx';
import AeonLink from './aeon_link.jsx';

const LocationInfo = ({holding}) => {
    const mapLocation = (locationID) => {
        return (locationID in availability.allLocations) ? availability.allLocations[locationID] : "";
    }

    // Location information presented to the user is different based on a few scenarios
    // First, if it's related to ILL
    if (availability.isIllLink(holding)) {
        return (
            <IllLink holding={holding} />
        );
    }

    // AEON
    if (availability.isArchivalThesis(holding)) {
        const illiadURL = "https://psu.illiad.oclc.org/illiad/upm/lending/lendinglogon.html";
        const aeonLocationText = mapLocation(holding.locationID);

        return (
            <>
                <IllLink holding={holding} />

                <br />

                <a href={illiadURL}>Request Scan - Guest</a><br />

                <AeonLink
                    holding={holding}
                    locationText={aeonLocationText}
                />
            </>
        )
    }

    // Special Collections
    if (availability.isArchivalMaterial(holding)) {
        const specialCollectionsText = mapLocation(holding.locationID);

        return (
            <>
                {specialCollectionsText}

                <br /> 

                <AeonLink
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
    holding: PropTypes.object
};

export default LocationInfo;
