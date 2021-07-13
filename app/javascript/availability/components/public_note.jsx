import React from 'react';

const PublicNote = (props) => {
    const holding = props.holding;

    if (holding.publicNote) {
        return (
            <i 
                className="fas fa-info-circle" 
                data-toggle="tooltip" 
                data-placement="right" 
                title={holding.publicNote}></i>
        );
    }

    return null;
};

export default PublicNote;
