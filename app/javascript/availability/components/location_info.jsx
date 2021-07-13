import React from 'react';
import PropTypes from 'prop-types';
import availability from '../index.js';

const Spinner = () => (
    <span className="spinner-border spinner-border-sm" 
          role="status" aria-hidden="true"></span>
);

const LocationInfo = ({holding}) => {
    const mapLocation = (locationID) => {
        return (locationID in availability.allLocations) ? availability.allLocations[locationID] : "";
    }

    // Location information presented to the user is different based on a few scenarios
    // First, if it's related to ILL
    if (availability.isIllLink(holding)) {
        return (
            <a 
                data-type="ill-link" 
                data-catkey={holding.catkey}
                data-call-number={holding.callNumber} 
                data-link-type={availability.illLinkType(holding)}
                data-item-location={holding.locationID}
                href="#"
            >
                <Spinner />
                {availability.illLinkText(holding)}
            </a>
        )
    }

    // AEON
    if (availability.isArchivalThesis(holding)) {
        const illiadURL = "https://psu.illiad.oclc.org/illiad/upm/lending/lendinglogon.html";
        const aeonLocationText = mapLocation(holding.locationID);

        return (<>
            <a 
                data-type="ill-link" 
                data-catkey={holding.catkey}
                data-call-number={holding.callNumber}
                data-link-type="archival-thesis" 
                data-item-type={holding.itemTypeID}
                href="#">
                    <Spinner />
                    Request Scan - Penn State Users
            </a><br />

            <a href={illiadURL}>Request Scan - Guest</a><br />

            <a 
                data-type="aeon-link" 
                data-catkey={holding.catkey}
                data-call-number={holding.callNumber}
                data-link-type="archival-thesis"
                data-item-type={holding.itemTypeID}
                data-item-id={holding.itemID}
                data-item-location={aeonLocationText}
                href="#">
                    <Spinner />
                    View in Special Collections
            </a>
        </>)
    }

    // Special Collections
    if (availability.isArchivalMaterial(holding)) {
        const specialCollectionsText = mapLocation(holding.locationID);

        return (<>
            {specialCollectionsText}<br /> 

            <a 
                data-type="aeon-link" 
                data-catkey={holding.catkey}
                data-call-number={holding.callNumber}
                data-link-type="archival-material"
                data-item-type={holding.itemTypeID}
                data-item-id={holding.itemID}
                data-item-location={specialCollectionsText}
                href="#">
                    <Spinner />
                    Request Material
            </a>
        </>);
    }

    // Otherwise use the default translation map for location display, no link
    return mapLocation(holding.locationID);
};

// eslint-react: defines valid prop types passed to this component
LocationInfo.propTypes = {
    holding: PropTypes.object
};

export default LocationInfo;
