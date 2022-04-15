import PropTypes from 'prop-types';

const A11yNavButton = ({ index, label, uniqueID }) => {
  /**
   * Changes focus to the desired `A11yRow` specified by the generated element ID.
   *
   * Allows screen reader users to page through the results in the holdings table.
   */
  const updateA11yFocus = () => {
    const el = document.getElementById(`a11y-${uniqueID}-${index}`);
    el.focus();
  };

  if (index === null) {
    return null;
  }

  return (
    <button
      type="button"
      onClick={() => {
        updateA11yFocus();
      }}
    >
      {label}
    </button>
  );
};

// eslint-react: defines valid prop types passed to this component
A11yNavButton.propTypes = {
  index: PropTypes.number,
  label: PropTypes.string,
  uniqueID: PropTypes.string,
};

export default A11yNavButton;
