import PropTypes from 'prop-types';
import HoldingDetails from './holding_details';
import SummaryHoldings from './summary_holdings';
import ViewMoreButton from './view_more_button';

const Availability = ({ structuredHoldings, summaryHoldings }) => (
  <>
    { structuredHoldings.map((element, index) => {
      const { holdings } = element;
      const { catkey } = holdings[0];
      const uniqueID = catkey + index;
      const moreHoldings = holdings.length > 4 ? holdings.splice(4, holdings.length) : [];
      const librarySummaryHoldings = summaryHoldings ? summaryHoldings[element.summary.libraryID] : null;

      return (
        <div key={index} data-library={element.summary.libraryID}>
          <h5>
            {element.summary.library}
            {' '}
            (
            {element.summary.countAtLibrary}
            {' '}
            {element.summary.pluralize}
            )
          </h5>

          <table id={`holdings-${uniqueID}`} className="table table-sm">
            <caption className="sr-only">Listing where to find this item in our buildings.</caption>
            <thead className="thead-light">
              <tr>
                <th>Call number</th>
                <th>Material</th>
                <th>Location</th>
              </tr>
            </thead>
            <tbody>
              <SummaryHoldings summaryHoldings={librarySummaryHoldings} />

              { holdings.map((holding, holdingIndex) => (
                <tr key={holdingIndex}>
                  <HoldingDetails holding={holding} />
                </tr>
              )) }

              { moreHoldings.map((holding, holdingIndex) => (
                <tr key={holdingIndex} className="collapse" id={`collapseHoldings${uniqueID}`}>
                  <HoldingDetails holding={holding} />
                </tr>
              )) }
            </tbody>
          </table>

          { (moreHoldings.length > 0) && (
            <ViewMoreButton uniqueID={uniqueID} />
          ) }
        </div>
      );
    }) }
  </>
);

// eslint-react: defines valid prop types passed to this component
Availability.propTypes = {
  structuredHoldings: PropTypes.array,
  summaryHoldings: PropTypes.object,
};

export default Availability;
