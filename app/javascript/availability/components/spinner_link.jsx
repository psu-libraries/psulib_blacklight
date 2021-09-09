import PropTypes from 'prop-types';
import Spinner from './spinner';

const SpinnerLink = ({label, linkTarget, showSpinner, url}) => {
    return (
        <a href={url} target={linkTarget}>
            <Spinner isVisible={showSpinner} />

            {label}
        </a>
    );
};

// eslint-react: defines valid prop types passed to this component
SpinnerLink.propTypes = {
    label: PropTypes.string,
    linkTarget: PropTypes.string,
    showSpinner: PropTypes.bool,
    url: PropTypes.string
};

export default SpinnerLink;
