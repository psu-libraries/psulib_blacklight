import React from 'react';
import availability from '../index.js';
import PublicNote from './public_note.jsx';
import LocationInfo from './location_info.jsx';
import CourseReserveDueDate from './course_reserve_due_date.jsx';
import MapScanLink from './map_scan_link.jsx';

const HoldingDetails = (props) => {
    const holding = props.holding;

    return (
        <>
            <td>
                {availability.generateCallNumber(holding)}
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

    return null;
};

export default HoldingDetails;
