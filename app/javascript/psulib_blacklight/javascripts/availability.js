/**
 * @file
 * Real Time Availability
 */
import locations from './libraries_locations.json';

$(document).on('turbolinks:load', function() {
    loadAvailability(locations);
});

/**
 * Load real time holdings and availability info from Sirsi Web Services
 */
function loadAvailability(locations) {
    // Load Sirsi locations
    var all_locations = locations.locations;
    var all_libraries = locations.libraries;
    var titleIDs = [];

    // Get the catkeys
    $('.availability').each(function() {
        titleIDs.push($(this).attr("data-keys"));
    });

    if (titleIDs.length > 0) {
        $.get('/available/' + titleIDs.join(','), function (xml) {
            $(xml).find('TitleInfo').each(function () {
                var holdings = [];
                var libraries = [];
                var titleID = $(this).children('titleID').text();
                var totalCopiesAvailable = parseInt($(this).find("totalCopiesAvailable").text(), 10);

                $(this).children('CallInfo').each(function () {
                    var libraryID = $(this).children('libraryID').text();
                    var library = (libraryID in all_libraries) ? all_libraries[libraryID] : "";
                    var callNumber = $(this).children('callNumber').text();
                    var numberOfCopies = $(this).children('numberOfCopies').text();

                    // Only for not online items (online items uses 856 urls for display)
                    if (libraryID.toUpperCase() !== 'ONLINE') {
                        var libAndCount = [];
                        libAndCount['library'] = library;
                        libAndCount['numberOfCopies'] = numberOfCopies;
                        libraries.push(libAndCount);

                        // Holdings
                        $(this).children("ItemInfo").each(function () {
                            var currentLocationID = $(this).children("currentLocationID").text().toUpperCase();
                            var homeLocationID = $(this).children("homeLocationID").text().toUpperCase();
                            var chargeable = $(this).children("chargeable").text();
                            var status = resolveStatus(chargeable, homeLocationID, currentLocationID);

                            var location = (homeLocationID in all_locations) ? all_locations[homeLocationID] : "";
                            holdings.push({
                                library: library,
                                location: location,
                                callNumber: callNumber,
                                status: status
                            });
                        });
                    }
                });

                $('.availability[data-keys="' + titleID +'"]').each(function () {
                    var availability = $(this);
                    var availabilityButton = availability.find('.availability-button');
                    var availabilityHoldingsPlaceHolder = availability.find('.availability-holdings');
                    var availabilitySnippetPlaceHolder = availability.find('.availability-snippet');

                    // If at least one physical copy, then display availability and holding info
                    if (Object.keys(holdings).length > 0) {
                        availabilityButton.removeClass("invisible").addClass("visible");
                        var rawHoldings = groupByLibrary(holdings);
                        var availabilityStructuredData = availabilityDataStructurer(rawHoldings);
                        availabilityHoldingsPlaceHolder.html(printAvailabilityData(availabilityStructuredData, titleID));
                        availabilitySnippet(availabilitySnippetPlaceHolder, availabilityStructuredData, totalCopiesAvailable);
                    } else {
                        availability.addClass("invisible");
                    }
                });

            });
        }, "xml");
    }
}

function printAvailabilityData(availabilityData, titleID) {
    var markupForHoldings = '';
    availabilityData.forEach(function(element, index) {
        var holdings = element.holdings;
        var uniqueID = titleID + index;
        var moreHoldings = holdings.length > 4 ? holdings.splice(4,holdings.length) : [];
        markupForHoldings += `
                                <h5>${element.summary.library} (${element.summary.countAtLibrary} ${element.summary.pluralize})</h5>
                                <table id="holdings-${uniqueID}" class="table table-hover table-sm">
                                    <caption class="sr-only">Listing where to find this item in our buildings.</caption>
                                    <thead class="thead-light">
                                        <tr>
                                            <th>Location</th>
                                            <th>Call number</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${holdings.map(holding => `
                                            <tr>
                                                <td>${holding.location}</td>
                                                <td>${holding.callNumber}</td>
                                                <td>${holding.status}</td>
                                            </tr>
                                        `).join('')}
                                        ${moreHoldings.map(moreHolding => `
                                             <tr class="collapse" id="collapseHoldings${uniqueID}">
                                                <td>${moreHolding.location}</td>
                                                <td>${moreHolding.callNumber}</td>
                                                <td>${moreHolding.status}</td>
                                            </tr>     
                                         `).join('')}
                                        </tbody>
                                    </table>
                                    <tr>
                              `;
        if (moreHoldings.length > 0) {
            markupForHoldings += `<button class="btn btn-primary toggle-more" data-type="view-more-holdings" data-target="#collapseHoldings${uniqueID}" data-toggle="collapse" role="button" aria-expanded="false" aria-controls="collapseHoldings${uniqueID}">View More</button>`;
        }
    });

    return markupForHoldings;
}

function librariesText(holdingData){
    var libraries = [];

    for (var index in holdingData) {
        libraries.push(holdingData[index].summary.library);
    }

    return libraries.join(', ');
}

function availabilitySnippet(availabilitySnippetPlaceHolder, holdingData, totalCopiesAvailable) {
    var snippet = "";
    if (totalCopiesAvailable > 0) {
        snippet = holdingData.length > 2 ? 'Multiple Locations' : librariesText(holdingData);
    }
    else {
        // No available copies, do not display a snippet
        snippet = '';
    }
    availabilitySnippetPlaceHolder.html(snippet);
}

function availabilityDataStructurer(holdingMetadata) {
    var availabilityStructuredData = [];
    var holdingData = [];
    var pluralize = "";

    if (Object.keys(holdingMetadata).length > 0) {
        Object.keys(holdingMetadata).forEach(function (library, index) {
            pluralize = (holdingMetadata[library].length > 1) ? 'items' : 'item';
            holdingData = {
                "summary":
                    {
                        "library": library,
                        "countAtLibrary": holdingMetadata[library].length,
                        "pluralize": pluralize
                    },
                "holdings": holdingMetadata[library]
            };

            availabilityStructuredData[index] = holdingData;
        })
    }

    return availabilityStructuredData;
}

// Group holding by library
function groupByLibrary(holdings) {
    return holdings.reduce(function (accumulator, object) {
        var key = object['library'];

        if (!accumulator[key]) {
            accumulator[key] = [];
        }
        accumulator[key].push(object);

        return accumulator;
    }, {});
}

function resolveStatus(chargeable, homeLocationID, currentLocationID) {
    var status = "";
    if (chargeable === 'true') {
        status = homeLocationID !== 'ON-ORDER' ? 'Available' : 'Being Acquired by the Library';
    }
    else {
        switch (currentLocationID) {
            case 'CHECKEDOUT':
                status = 'Checked Out';
                break;
            case 'MISSING':
                status = 'Missing';
                break;
            default:
                status = 'Not Available';
        }
    }

    return status;
}

$(document).ready(function() {
    $(".availability").on("click", "[data-type=view-more-holdings]", function () {
        $(this).toggleClass('toggle-more');
        if ($(this).hasClass('toggle-more')) {
            $(this).text("View More");
        }
        else {
            $(this).text("View Less");
        }
    });
});