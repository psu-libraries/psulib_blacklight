import React from 'react';
import availability from '../index.js';

const CourseReserveDueDate = (props) => {
    const holding = props.holding;

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

        return (<>
            <br /><strong>Due back at:</strong> {time} on {day}<br />{circulationRule}
        </>);
    }

    return null;
};

export default CourseReserveDueDate;
