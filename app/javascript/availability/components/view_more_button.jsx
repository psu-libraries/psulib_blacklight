import PropTypes from 'prop-types';

const ViewMoreButton = ({ uniqueID }) => (
  <button
    className="btn btn-primary toggle-more"
    type="button"
    data-type="view-more-holdings"
    data-target={`#collapseHoldings${uniqueID}`}
    data-toggle="collapse"
    aria-expanded="false"
    aria-controls={`#collapseHoldings${uniqueID}`}
  >
    View More
  </button>
);

// eslint-react: defines valid prop types passed to this component
ViewMoreButton.propTypes = {
  uniqueID: PropTypes.string,
};

export default ViewMoreButton;
