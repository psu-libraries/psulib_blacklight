import React from 'react';
import PropTypes from 'prop-types';
import HoldingDetails from './holding_details.jsx';
import ViewMoreButton from './view_more_button.jsx';

const Availability = ({data}) => { return (
    <>
        { data.map((element, index) => {
            const holdings = element.holdings;
            const catkey = holdings[0].catkey;
            const uniqueID = catkey + index;
            const moreHoldings = holdings.length > 4 ? holdings.splice(4, holdings.length) : [];

            return (
                <div key={index} data-library={element.summary.libraryID}>
                    <h5>{element.summary.library} ({element.summary.countAtLibrary} {element.summary.pluralize})</h5>

                    <table id={"holdings-" + uniqueID} className="table table-sm">
                        <caption className="sr-only">Listing where to find this item in our buildings.</caption>
                        <thead className="thead-light">
                            <tr>
                                <th>Call number</th>
                                <th>Material</th>
                                <th>Location</th>
                            </tr>
                        </thead>
                        <tbody>
                            { holdings.map((holding, index) => (
                                <tr key={index}>
                                    <HoldingDetails holding={holding} />
                                </tr>
                            )) }

                            { moreHoldings.map((holding, index) => (
                                <tr key={index} className="collapse" id={"collapseHoldings" + uniqueID}>
                                    <HoldingDetails holding={holding} />
                                </tr>
                            )) }
                        </tbody>
                    </table>

                    { (moreHoldings.length > 0) && (
                        <ViewMoreButton uniqueID={uniqueID} />
                    ) }
                </div>
            )
        }) }
    </>
)};

// eslint-react: defines valid prop types passed to this component
Availability.propTypes = {
    data: PropTypes.array
};

export default Availability;
