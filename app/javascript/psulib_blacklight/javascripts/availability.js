/**
 * @file
 * Real Time Availability info from Sirsi Web Services
 */

/**
 * Load locations
 *
 * @returns {Promise}
 */
var loadLocations = function () {
    return new Promise (function(resolve, reject) {
        $.getJSON('locations', function(data) {
            resolve(data);
        });
    });
};

$(document).ready(function () {
    // Load Sirsi locations
    loadLocations().then(function(fromResolve) {
        var locations =  fromResolve;
        var inProcessLocations = locations.in_process;
        var illLocations = locations.request_via_ill;
        var inLibraryUseLocations = locations.in_library_use;
        var all_locations = locations.all_locations;
        var all_libraries = locations.libraries;

        // Sirsi Web Services Availability url
        var url = "url here";

        $('.availability').each(function () {
            var availabilityHoldingsPlaceHolder = $(this).find('.availability-holdings');
            var availabilitySnippetPlaceHolder = $(this).find('.availability-snippet');

            // Get the catkeys
            var catkeys = $(this).attr("data-keys");
            // Format catkeys to compose titleID params
            var titleIDs = '&titleID=' + catkeys;

            $.get(url + titleIDs, function (xml) {
                var totalCopiesAvailable = 0;
                var locations = [];
                var libraries = [];
                var online = [];
                var checkedout = false;
                var inProcess = [];
                var viaILL = [];
                var inLibraryUse = false;

                $(xml).find('TitleInfo').each(function () {
                    totalCopiesAvailable += parseInt($(this).find("totalCopiesAvailable").text(), 10);

                    $(this).children("CallInfo").each(function () {
                        var libraryID = $(this).children("libraryID").text();
                        // Check if online resource
                        if(libraryID.toUpperCase() == 'ONLINE') {
                            online.push("Online");
                        }
                        else {
                            libraries.push(all_libraries[libraryID]);

                            var callNumber = $(this).children("callNumber").text();
                            $(this).children("ItemInfo").each(function () {
                                var currentLocationID = $(this).children("currentLocationID").text();
                                currentLocationID = currentLocationID.toUpperCase();
                                // No location info if item is checked out
                                if (currentLocationID == "CHECKEDOUT") {
                                    checkedout = true;
                                }
                                // No location info if item is in process, get the message
                                else if(currentLocationID in inProcessLocations) {
                                    inProcess.push(inProcessLocations[currentLocationID]);
                                }
                                // No location info if item is available via ILL, get the message
                                else if(currentLocationID in illLocations) {
                                    viaILL.push(illLocations[currentLocationID]);
                                }
                                else {
                                    var location = (currentLocationID in all_locations) ? all_locations[currentLocationID] : "";
                                    locations.push(location + ', ' + callNumber);
                                    // Check if in library use only
                                    if(currentLocationID in inLibraryUseLocations) {
                                        inLibraryUse = true;
                                    }
                                }
                            });
                        }
                    });
                });

                // If at least one copy available, then display Available
                var available = totalCopiesAvailable > 0 && (locations.length > 0 || online.length > 0);

                // Check locations and add to the display text
                var locationText = "";
                if(locations.length > 0) {
                    // If available in 1 or 2 locations, display location and call number,
                    // If available in more than one location, display as "Multiple Locations"
                    locationText = locations.length > 1 ? "Multiple Locations" : locations[0] ;
                }

                // Check if online and add to the display text
                if(online.length > 0) {
                    // If only available online, add that to display
                    locationText += locationText ? ", Online" : "Online";
                }

                var label = "";
                if(available) {
                    // If available only in one location which is a in library use location then
                    // display label as In Library Use, otherwise display Available
                    label = (inLibraryUse && locations.length == 1) ? "In Library Use" : "Available";
                }
                else {
                    if(checkedout) {
                        label = 'Checked Out';
                    }
                    else if(inProcess.length > 0) {
                        label = 'In Process'
                        locationText  = inProcess[0];
                    }
                    else if(viaILL.length > 0) {
                        label='Request via ILL'
                        locationText = viaILL[0];
                    }
                }

                availabilityHoldings(availabilityHoldingsPlaceHolder, label, locationText);
                availabilitySnippet(availabilitySnippetPlaceHolder, libraries);
            }, "xml");
        });
    });
});

var availabilitySnippet = function (availabilitySnippetPlaceHolder, libraries) {
    var librariesText = libraries.slice(0,2).join(', ');
    availabilitySnippetPlaceHolder.html(librariesText);
};

var availabilityHoldings = function (availabilityHoldingsPlaceHolder, status, locationText) {
    var availability = '<p><span class="label">' + status + '</span> ' + locationText + '</p>';
    availabilityHoldingsPlaceHolder.html(availability);
};