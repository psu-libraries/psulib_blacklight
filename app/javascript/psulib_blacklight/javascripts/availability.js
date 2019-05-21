/**
 * @file
 * Real Time Availability
 */
import locations from './locations.json';

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
    var titleIDs = "";

    // Sirsi Web Services Availability url
    var url = 'sirsi url here';
    $('.availability').each(function() {
        // Get the catkeys
        var catkeys = $(this).attr("data-keys");
        // Format catkeys to compose titleID params
        titleIDs += '&titleID=' + catkeys;
    });

    if (titleIDs.length > 0) {
        $.get(url + titleIDs, function (xml) {
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
                        var availabilityStructuredData = availabilityDataStructurer(rawHoldings, libraries);
                        availabilityHoldingsPlaceHolder.html(printAvailabilityData(availabilityStructuredData));
                        availabilitySnippet(availabilitySnippetPlaceHolder, availabilityStructuredData, totalCopiesAvailable);
                    } else {
                        availability.addClass("invisible");
                    }
                });

            });
        }, "xml");
    }
}

function printAvailabilityData(availabilityData) {
    var markupForHoldings = '';
    availabilityData.forEach(function(element) {
        markupForHoldings += `
                                <h4>${element.summary.library} (${element.summary.countAtLibrary} ${element.summary.pluralize})</h4>
                                <table class="table table-hover table-sm">
                                    <caption class="sr-only">Listing where to find this item in our buildings.</caption>
                                    <thead class="thead-light">
                                        <tr>
                                            <th>Location</th>
                                            <th>Call number</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${element.holdings.map(holding => `
                                            <tr>
                                                <td>${holding.location}</td>
                                                <td>${holding.callNumber}</td>
                                                <td>${holding.status}</td>
                                            </tr>
                                        `).join('')}
                                    </tbody>
                                </table>
                            `
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

function availabilityDataStructurer(holdingMetadata, availableCountInLibraries) {
    var availabilityStructuredData = [];
    var holdingData = [];
    var pluralize = "";

    if (Object.keys(holdingMetadata).length > 0) {
        Object.keys(holdingMetadata).forEach(function (library, index){
            pluralize = (holdingMetadata[library].length > 1) ? 'items' : 'item';
            holdingData = {
                "summary":
                    {
                        "library": library,
                        "countAtLibrary": holdingMetadata[library].length,
                        "pluralize": pluralize
                    },
                "holdings":  holdingMetadata[library]
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

