import PropTypes from 'prop-types';
import availability from '../index.js';

const MapScanLink = ({holding}) => {
    const isUPSpecialMap = () => {
        return ['MAPSPEC'].includes(holding.itemTypeID) && ['UP-MAPS'].includes(holding.libraryID);
    };

    if (!isUPSpecialMap()) {
        return null;
    }

    return (
        <div>
            <a target="_blank" rel="noreferrer" href={availability.mapScanUrl}>Request scan</a>
        </div>
    );
};

// eslint-react: defines valid prop types passed to this component
MapScanLink.propTypes = {
    holding: PropTypes.object
};

export default MapScanLink;
