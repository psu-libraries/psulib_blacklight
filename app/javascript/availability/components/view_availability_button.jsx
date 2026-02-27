import PropTypes from 'prop-types';
import availability from '../index';

const ViewAvailabilityButton = ({ titleID, title }) => (
  <div className="row">
    <div className="availability-button col-md-auto pr-0">
      <p>
        <button
          className="btn btn-primary header"
          type="button"
          onClick={() => availability.loadAvailability(titleID)}
          data-bs-toggle="collapse"
          data-bs-target={`#availability-${titleID}`}
          aria-expanded="false"
          aria-controls={`${titleID}-location`}
          aria-label={`View ${title} availability`}
        >
          <span>View Availability </span>
          <i className="fa fa-chevron-right" aria-hidden="true" />
        </button>
      </p>
    </div>
    <div className="availability-snippet col-md-auto">
    </div>
    <div className="availability-spinner col-md-auto invisible">
      <p>
        <span
          className="spinner-border spinner-border-sm"
          role="status"
          aria-hidden="true"
        />{' '}
        Finding items...
      </p>
    </div>
  </div>
);

// eslint-react: defines valid prop types passed to this component
ViewAvailabilityButton.propTypes = {
  titleID: PropTypes.string,
  title: PropTypes.string,
};

export default ViewAvailabilityButton;
