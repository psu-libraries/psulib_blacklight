import React from 'react'
import CourseReserveDueDate from './course_reserve_due_date.jsx';
import LocationInfo from './location_info.jsx';
import MapScanLink from './map_scan_link.jsx';
import PublicNote from './public_note.jsx';
import availability from '../index.js';

const Availability = (props) => { return (
    <>
        { props.data.map((element, index) => { 
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
                                    <td>{availability.generateCallNumber(holding)}
                                        <PublicNote holding={holding} /></td>
                                    <td>{holding.itemType}</td>
                                    <td><LocationInfo holding={holding} />
                                        <CourseReserveDueDate holding={holding} />
                                        <MapScanLink holding={holding} /></td>
                                </tr>
                            )) }

                            { moreHoldings.map((moreHolding, index) => (
                                <tr key={index} className="collapse" id={"collapseHoldings" + uniqueID}>
                                    <td>{availability.generateCallNumber(moreHolding)}</td>
                                    <td>{moreHolding.itemType}</td>
                                    <td><LocationInfo holding={moreHolding} />
                                        <CourseReserveDueDate holding={moreHolding} /></td>
                                </tr>
                            )) }
                        </tbody>
                    </table>

                    { (moreHoldings.length > 0) ? (
                        <b><button className="btn btn-primary toggle-more" 
                        data-type="view-more-holdings" 
                        data-target={"#collapseHoldings" + uniqueID} 
                        data-toggle="collapse" role="button" 
                        aria-expanded="false" 
                        aria-controls={"collapseHoldings" + uniqueID}>View More
                        </button></b>
                    ) : null }
                </div>
            )
        }) }
    </>
)};

export default Availability;
