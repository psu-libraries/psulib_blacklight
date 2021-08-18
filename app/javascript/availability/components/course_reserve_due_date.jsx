import React from 'react';
import PropTypes from 'prop-types';
import availability from '../index.js';

const CourseReserveDueDate = ({holding}) => {
    if (availability.isOnCourseReserve(holding)) {
        const dueDate = new Date(holding.dueDate);

        const day = dueDate.toLocaleDateString('en-us', {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            timeZone: 'America/New_York'
        });

        const time = dueDate.toLocaleTimeString('en-us', {
            hour: 'numeric',
            minute: '2-digit',
            timeZone: 'America/New_York'
        });

        const circulationRule = availability.reserveCirculationRules[holding.reserveCirculationRule];

        return (
            <div>
                <strong>Due back at:</strong> {time} on {day}<br />{circulationRule}
            </div>
        );
    }

    return null;
};

// eslint-react: defines valid prop types passed to this component
CourseReserveDueDate.propTypes = {
    holding: PropTypes.object
};

export default CourseReserveDueDate;