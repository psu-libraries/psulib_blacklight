import React from 'react';
import availability from '../index.js';

const MapScanLink = (props) => {
    const holding = props.holding;

    if (availability.isUPSpecialMap(holding)) {
        return (
            <>
                <br /><a target="_blank" href={availability.mapScanUrl}>Request scan</a>
            </>
        );
    }

    return null;
};

export default MapScanLink;
