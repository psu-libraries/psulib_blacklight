import PropTypes from 'prop-types';
import { Fragment, useState } from 'react';
import A11yRow from './a11y_row';
import HoldingDetails from './holding_details';
import SummaryHoldings from './summary_holdings';
import ViewMoreButton from './view_more_button';

const Availability = ({ structuredHoldings, summaryHoldings }) => (
  <>
    {structuredHoldings.map((element, index) => {
      const totalHoldingsCount = structuredHoldings
        .map((e) => e.holdings.length)
        .reduce((acum, val) => acum + val, 0);
      const initialVisibleCount = 4;
      const pageSize = totalHoldingsCount > 1000 ? 500 : 100;
      const { holdings, summary } = element;
      const { catkey } = holdings[0];
      const uniqueID = catkey + index;
      const librarySummaryHoldings = summaryHoldings
        ? summaryHoldings[summary.libraryID]
        : null;

      const [visibleHoldings, setVisibleHoldings] = useState(
        holdings.slice(0, initialVisibleCount),
      );
      const [moreHoldings, setMoreHoldings] = useState(
        holdings.length > initialVisibleCount
          ? holdings.slice(initialVisibleCount)
          : [],
      );
      const [lastA11yIndex, setLastA11yIndex] = useState(0);

      const showA11yRow = (holdingIndex) =>
        holdings.length > initialVisibleCount &&
        (holdingIndex === 0 ||
          (holdingIndex - initialVisibleCount) % pageSize === 0);

      function tooltipInit() {
        $('i.fas.fa-info-circle[data-bs-toggle="tooltip"]').tooltip();
      }

      const viewMore = () => {
        setLastA11yIndex(visibleHoldings.length);
        setVisibleHoldings([
          ...visibleHoldings,
          ...moreHoldings.slice(0, pageSize),
        ]);
        setMoreHoldings(moreHoldings.slice(pageSize));
        // reinitialize tooltips when loading new records
        setTimeout(() => {
          tooltipInit();
        }, 100);
      };

      return (
        <div key={index} data-library={summary.libraryID}>
          <h5>
            {`${summary.library} (${summary.countAtLibrary} ${summary.pluralize})`}
          </h5>
          <h5 className="sr-only">
            Listing where to find this item in the library.
          </h5>
          <table id={`holdings-${uniqueID}`} className="table table-sm">
            <thead className="thead-light">
              <tr>
                <th>Call number</th>
                <th>Material</th>
                <th>Location</th>
              </tr>
            </thead>
            <tbody>
              <SummaryHoldings summaryHoldings={librarySummaryHoldings} />

              {visibleHoldings.map((holding, holdingIndex) => (
                <Fragment key={holdingIndex}>
                  {showA11yRow(holdingIndex) && (
                    <A11yRow
                      lastA11yIndex={lastA11yIndex}
                      holdingIndex={holdingIndex}
                      initialVisibleCount={initialVisibleCount}
                      pageSize={pageSize}
                      uniqueID={uniqueID}
                      visibleHoldingsCount={visibleHoldings.length}
                    />
                  )}
                  <tr>
                    <HoldingDetails holding={holding} />
                  </tr>
                </Fragment>
              ))}
            </tbody>
          </table>

          {moreHoldings.length > 0 && <ViewMoreButton onClick={viewMore} />}
        </div>
      );
    })}
  </>
);

// eslint-react: defines valid prop types passed to this component
Availability.propTypes = {
  structuredHoldings: PropTypes.array,
  summaryHoldings: PropTypes.object,
};

export default Availability;
