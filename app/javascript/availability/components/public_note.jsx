import React from 'react';
import PropTypes from 'prop-types';

const PublicNote = ({holding}) => {
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

// eslint-react: defines valid prop types passed to this component
PublicNote.propTypes = {
    holding: PropTypes.object
};

export default PublicNote;
