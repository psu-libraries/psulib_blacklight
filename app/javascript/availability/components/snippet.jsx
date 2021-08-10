import PropTypes from 'prop-types';

const Snippet = ({data}) => {
    const hasCopiesAvailable = () => {
        return data[0].holdings[0].totalCopiesAvailable > 0;
    };

    const librariesText = () => {
        let libraries = [];

        for (let index in data) {
            if (data[index].summary.library === 'ON-ORDER') {
                libraries.push('')
            } else {
                libraries.push(data[index].summary.library);
            }
        }

        return libraries.join(', ');
    };

    if (!hasCopiesAvailable()) {
        return null;
    }

    return data.length > 2 ? 'Multiple Locations' : librariesText();
};

// eslint-react: defines valid prop types passed to this component
Snippet.propTypes = {
    data: PropTypes.array
};

export default Snippet;
