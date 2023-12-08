import PropTypes from 'prop-types';
import React from 'react';
import availability from '../index';

const SummaryHoldings = ({ summaryHoldings }) => {
  if (!summaryHoldings) {
    return null;
  }

  const listStyle = {
    marginBottom: 0,
    listStyleType: 'none',
  };

  return (
    <tr className="table-primary">
      <td colSpan="3">
        {Object.keys(summaryHoldings).map((locationID) => {
          const locationName = availability.allLocations[locationID];
          const locationData = summaryHoldings[locationID][0];

          return (
            <React.Fragment key={locationID}>
              <div className="h6">{locationName}: Holdings Summary</div>

              <ul style={listStyle}>
               
                {summaryHoldings[locationID].length > 1 ? (
                  <ul style={{ listStyleType: 'none', padding: 0, marginLeft: '0' }}>
                    {/* Summaries */}
                    {summaryHoldings[locationID].map((data, index) => (
                      <li key={`location${index}`}>
                        <div>{data.call_number}</div>
                        <ul>
                          {data.summary.map((summary, i) => (
                            <li key={`summary${i}`}>{summary}</li>
                          ))}
                        </ul>
                      </li>
                    ))}
                  </ul>
                ) : (
                  <ul style={{ listStyleType: 'none', padding: 0, marginLeft: '0' }}>
                    {/* Summaries */}
                    {locationData.summary.map((summary, i) => (
                      <li key={`summary${i}`}>{summary}</li>
                    ))}
                  </ul>
                )}

                {/* Indexes */}
                {locationData.index.length > 0 && (
                  <li>
                    <div className="h6 mt-2">
                      <span className="sr-only">{locationName}</span>
                      Indexes
                    </div>

                    <ul style={listStyle}>
                      {locationData.index.map((index, i) => (
                        <li key={`index${i}`}>{index}</li>
                      ))}
                    </ul>
                  </li>
                )}

                {/* Supplements */}
                {locationData.supplement.length > 0 && (
                  <li>
                    <div className="h6 mt-2">
                      <span className="sr-only">{locationName}</span>
                      Supplements
                    </div>

                    <ul style={listStyle}>
                      {locationData.supplement.map((supplement, i) => (
                        <li key={`supplement${i}`}>{supplement}</li>
                      ))}
                    </ul>
                  </li>
                )}
              </ul>
            </React.Fragment>
          );
        })}
      </td>
    </tr>
  );
};

// eslint-react: defines valid prop types passed to this component
SummaryHoldings.propTypes = {
  summaryHoldings: PropTypes.object,
};

export default SummaryHoldings;
