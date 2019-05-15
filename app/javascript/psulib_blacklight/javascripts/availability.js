/**
 * @file
 * Real Time Availability info from Sirsi Web Services
 */

/**
 * Load locations
 *
 * @returns {Promise}
 */
loadLocations = function () {
    return new Promise (function(resolve, reject) {
        $.getJSON('locations', function(data) {
            resolve(data);
        });
    });
};

$(document).ready(function () {
    // Load Sirsi locations
    loadLocations().then(function(locations) {
        all_locations = locations.all_locations;
        all_libraries = locations.libraries;

        // Sirsi Web Services Availability url
        url = 'sirsi url here';

        $('.availability').each(function () {
            var availability = $(this);
            var availabilityHoldingsPlaceHolder = availability.find('.availability-holdings');
            var availabilitySnippetPlaceHolder = availability.find('.availability-snippet');
            // Get the catkeys
            catkeys = $(this).attr("data-keys");
            // Format catkeys to compose titleID params
            titleIDs = '&titleID=' + catkeys;

            $.get(url + titleIDs, function (xml) {
                totalCopiesAvailable = 0;
                holdings = [];
                libraries = [];

                $(xml).find('TitleInfo').each(function () {
                    totalCopiesAvailable += parseInt($(this).find("totalCopiesAvailable").text(), 10);
                    $(this).children('CallInfo').each(function () {
                        libraryID = $(this).children('libraryID').text();
                        library = (libraryID in all_libraries) ? all_libraries[libraryID] : "";
                        callNumber = $(this).children('callNumber').text();
                        numberOfCopies = $(this).children('numberOfCopies').text();

                        // Only for not online items (online items uses 856 urls for display)
                        if (libraryID.toUpperCase() !== 'ONLINE') {
                            libraries[library] = numberOfCopies;
                            // Holdings
                            $(this).children("ItemInfo").each(function () {
                                currentLocationID = $(this).children("currentLocationID").text().toUpperCase();
                                homeLocationID = $(this).children("homeLocationID").text().toUpperCase();
                                chargeable = $(this).children("chargeable").text();
                                status = resolveStatus(chargeable, homeLocationID, currentLocationID);

                                var location = (homeLocationID in all_locations) ? all_locations[homeLocationID] : "";
                                holdings.push({
                                    library : library,
                                    location: location,
                                    callNumber: callNumber,
                                    status: status
                                });
                            });
                        }
                    });
                });

                // If at least one copy available, then display Available
                if (Object.keys(holdings).length > 0) {
                    availabilityHoldings(availabilityHoldingsPlaceHolder, holdings, libraries);
                    availabilitySnippet(availabilitySnippetPlaceHolder, libraries, totalCopiesAvailable);
                } else {
                    availability.hide();
                }
            }, "xml");
        });
    });
});

function availabilitySnippet(availabilitySnippetPlaceHolder, libraries, totalCopiesAvailable) {
    if (totalCopiesAvailable > 0) {
        librariesText = Object.keys(libraries).slice(0, 2).join(', ');
        snippet = libraries.length > 2 ? 'Multiple Locations' : librariesText;
    }
    else {
        // No available copies, do not display a snippet
        snippet = '';
    }
    availabilitySnippetPlaceHolder.html(snippet);
}

function availabilityHoldings(availabilityHoldingsPlaceHolder, holdings, libraries) {
    availability = resolveHoldings(holdings, libraries);
    availabilityHoldingsPlaceHolder.html(availability);
}

function resolveHoldings(allHoldings, libraries) {
    allHoldings = groupByLibrary(allHoldings);

    holdingsDisplay = '<table class="table">';
    if (Object.keys(allHoldings).length > 0) {
        for (library in allHoldings) {
            holdingsPerLibrary = allHoldings[library];
            numberOfCopiesAtLibrary = libraries[library];
            holdingsDisplay += '<thead class="thead-light"><tr>';
            holdingsDisplay += '<th scope="col" colspan="2">' + library + ' (' + numberOfCopiesAtLibrary + ')</th>';
            holdingsDisplay += '<th scope="col">Status</th>';
            holdingsDisplay += '</tr></thead>';

            holdingsPerLibrary.forEach(function (holding) {
                holdingsDisplay += '<tbody><tr>'
                holdingsDisplay += '<td>' + holding.location + '</td>';
                holdingsDisplay += '<td>' + holding.callNumber + '</td>';
                holdingsDisplay += '<td>' + holding.status + '</td>';
                holdingsDisplay += '</tr></tbody>';
            });
        }
    }
    holdingsDisplay += '</table>';
    return holdingsDisplay;
}

// Group holding by library
function groupByLibrary(holdings) {
    return holdings.reduce(function (acc, obj) {
        var key = obj['library'];
        if (!acc[key]) {
            acc[key] = [];
        }
        acc[key].push(obj);
        return acc;
    }, {});
}

function resolveStatus(chargeable, homeLocationID, currentLocationID) {
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
