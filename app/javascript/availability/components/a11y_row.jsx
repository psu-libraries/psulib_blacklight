import PropTypes from 'prop-types';
import A11yNavButton from './a11y_nav_button';

/**
 * Provides screen reader users of the Availability feature the ability to navigate through
 * the holdings table using the previous/next buttons. Clicking the buttons sets the focus
 * to the previous/next page of elements, respectively.
 */
const A11yRow = ({
  lastA11yIndex,
  holdingIndex,
  initialVisibleCount,
  pageSize,
  uniqueID,
  visibleHoldingsCount,
}) => {
  const holdingsPageHeading = (idx) => {
    let lastIndex = initialVisibleCount;

    if (idx > 0) {
      lastIndex = 1 + Math.min(idx + pageSize, visibleHoldingsCount - 1);
    }

    return `Holdings ${idx + 1} - ${lastIndex}`;
  };

  const prevA11yIndex = (idx) => {
    if (idx === 0) {
      return null;
    }

    if (idx === initialVisibleCount) {
      return 0;
    }

    return idx - pageSize;
  };

  const nextA11yIndex = (idx) => {
    if (idx === 0 && visibleHoldingsCount > initialVisibleCount) {
      return initialVisibleCount;
    }

    if (idx + pageSize >= visibleHoldingsCount) {
      return null;
    }

    return idx + pageSize;
  };

  /**
   * If this newly-created `A11yRow` is the last `A11yRow` in the containing table,
   * focus it so that screen reader users are aware that new elements have been
   * added to the table.
   * Called on initial render of this component.
   * @param el - The `<td>` element considered for focus.
   * @param idx - The current index of the `A11yRow` component inside the holdings table.
   */
  const focusNewA11yRow = (el, idx) => {
    if (el && lastA11yIndex > 0 && idx === lastA11yIndex) {
      el.focus();
    }
  };

  return (
    <tr className="sr-only">
      <td
        id={`a11y-${uniqueID}-${holdingIndex}`}
        tabIndex={-1}
        ref={(el) => {
          focusNewA11yRow(el, holdingIndex);
        }}
      >
        {holdingsPageHeading(holdingIndex)}

        <A11yNavButton
          index={prevA11yIndex(holdingIndex)}
          label="Previous"
          uniqueID={uniqueID}
        />

        <A11yNavButton
          index={nextA11yIndex(holdingIndex)}
          label="Next"
          uniqueID={uniqueID}
        />
      </td>
    </tr>
  );
};

// eslint-react: defines valid prop types passed to this component
A11yRow.propTypes = {
  lastA11yIndex: PropTypes.number,
  holdingIndex: PropTypes.number,
  initialVisibleCount: PropTypes.number,
  pageSize: PropTypes.number,
  uniqueID: PropTypes.string,
  visibleHoldingsCount: PropTypes.number,
};

export default A11yRow;
