import React from 'react';
import PropTypes from 'prop-types';
import availability from '../index.js';

const MapScanLink = ({holding}) => {
    if (availability.isUPSpecialMap(holding)) {
        return (
            <div>
                <a target="_blank" rel="noreferrer" href={availability.mapScanUrl}>Request scan</a>
            </div>
        );
    }

    return null;
};

// eslint-react: defines valid prop types passed to this component
MapScanLink.propTypes = {
    holding: PropTypes.object
};

export default MapScanLink;
