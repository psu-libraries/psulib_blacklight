import PropTypes from 'prop-types';

const Spinner = ({isVisible}) => {
    if (!isVisible) {
        return null;
    }

    return (
        <span
            className="spinner-border spinner-border-sm"
            role="status"
            aria-hidden="true"
        ></span>
    );
};

// eslint-react: defines valid prop types passed to this component
Spinner.propTypes = {
    isVisible: PropTypes.bool
};

export default Spinner;
