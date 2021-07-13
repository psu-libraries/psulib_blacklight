import React from 'react';
import PropTypes from 'prop-types';
import PublicNote from './public_note.jsx';
import LocationInfo from './location_info.jsx';
import CourseReserveDueDate from './course_reserve_due_date.jsx';
import MapScanLink from './map_scan_link.jsx';

const HoldingDetails = ({holding}) => {
    const generateCallNumber = () => {
        // Do not display call number for on loan items
        return (holding.locationID === "ILLEND") ? "" : holding.callNumber;
    };

    return (
        <>
            <td>
                {generateCallNumber(holding)}
                <PublicNote holding={holding} />
            </td>
            <td>{holding.itemType}</td>
            <td>
                <LocationInfo holding={holding} />
                <CourseReserveDueDate holding={holding} />
                <MapScanLink holding={holding} />
            </td>
        </>
    );
};

// eslint-react: defines valid prop types passed to this component
HoldingDetails.propTypes = {
    holding: PropTypes.object
};

export default HoldingDetails;
