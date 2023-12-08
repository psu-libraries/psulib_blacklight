import PropTypes from 'prop-types';
import PublicNote from './public_note';
import LocationInfo from './location_info';
import CourseReserveDueDate from './course_reserve_due_date';
import MapScanLink from './map_scan_link';

const HoldingDetails = ({ holding }) => (
  <>
    <td>
      {holding.callNumber}
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

// eslint-react: defines valid prop types passed to this component
HoldingDetails.propTypes = {
  holding: PropTypes.object,
};

export default HoldingDetails;
