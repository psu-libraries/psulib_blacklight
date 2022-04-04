import PropTypes from 'prop-types';
import { Fragment, useState } from 'react';
import HoldingDetails from './holding_details';
import SummaryHoldings from './summary_holdings';
import ViewMoreButton from './view_more_button';

const Availability = ({ structuredHoldings, summaryHoldings }) => (
  <>
    {structuredHoldings.map((element, index) => {
      const initialVisibleCount = 4;
      const pageSize = 100;
      const { holdings, summary } = element;
      const { catkey } = holdings[0];
      const uniqueID = catkey + index;
      const librarySummaryHoldings = summaryHoldings
        ? summaryHoldings[summary.libraryID]
        : null;

      const [visibleHoldings, setVisibleHoldings] = useState(
        holdings.slice(0, initialVisibleCount)
      );
      const [moreHoldings, setMoreHoldings] = useState(
        holdings.length > initialVisibleCount
          ? holdings.slice(initialVisibleCount)
          : []
      );
      const [a11yIndex, setA11yIndex] = useState(0);

      const viewMore = () => {
        setA11yIndex(visibleHoldings.length);
        setVisibleHoldings([
          ...visibleHoldings,
          ...moreHoldings.slice(0, pageSize),
        ]);
        setMoreHoldings(moreHoldings.slice(pageSize));
      };

      return (
        <div key={index} data-library={summary.libraryID}>
          <h5>
            {`${summary.library} (${summary.countAtLibrary} ${summary.pluralize})`}
          </h5>

          <table id={`holdings-${uniqueID}`} className="table table-sm">
            <caption className="sr-only">
              Listing where to find this item in our buildings.
            </caption>
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
                  {a11yIndex > 0 && holdingIndex === a11yIndex && (
                    <tr className="sr-only">
                      <td
                        tabIndex={-1}
                        ref={(el) => {
                          if (el) {
                            el.focus();
                          }
                        }}
                      >
                        More Holdings
                      </td>
                    </tr>
                  )}
                  <tr>
                    <HoldingDetails holding={holding} />
                  </tr>
                </Fragment>
              ))}
            </tbody>
          </table>

          {moreHoldings.length > 0 && (
            <ViewMoreButton
              onClick={() => {
                viewMore();
              }}
            />
          )}
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
