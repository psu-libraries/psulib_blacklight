import PropTypes from 'prop-types';

const Snippet = ({ data }) => {
  const hasCopiesAvailable = () => data[0].holdings[0].totalCopiesAvailable > 0;

  const librariesText = () => {
    const libraries = [];

    data.forEach((d) => {
      if (d.summary.library === 'ON-ORDER') {
        libraries.push('');
      } else {
        libraries.push(d.summary.library);
      }
    });

    return libraries.join(', ');
  };

  if (!hasCopiesAvailable()) {
    return null;
  }

  return data.length > 2 ? 'Multiple Locations' : librariesText();
};

// eslint-react: defines valid prop types passed to this component
Snippet.propTypes = {
  data: PropTypes.array,
};

export default Snippet;
