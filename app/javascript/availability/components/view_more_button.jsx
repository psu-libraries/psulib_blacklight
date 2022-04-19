import PropTypes from 'prop-types';

const ViewMoreButton = ({ onClick }) => (
  <button className="btn btn-primary mb-3" type="button" onClick={onClick}>
    View More
  </button>
);

// eslint-react: defines valid prop types passed to this component
ViewMoreButton.propTypes = {
  onClick: PropTypes.func,
};

export default ViewMoreButton;
