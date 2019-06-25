/**
 * @file
 * Real Time Availability
 */
import locations from './libraries_locations.json';
import item_types from './item_types.json';

$(document).on('turbolinks:load', function() {
    loadAvailability(locations, item_types);

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

/**
 * Load real time holdings and availability info from Sirsi Web Services
 */
function loadAvailability(locations, item_types) {
    // Load Sirsi locations
    var all_locations = locations.locations;
    var all_libraries = locations.libraries;
    var request_via_ill_locations = locations.request_via_ill;
    var all_item_types = item_types.item_types;
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
                var holdable = $(this).find("holdable").text();

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
                            var location = resolveLocation(currentLocationID, request_via_ill_locations, all_locations, titleID, callNumber);
                            var itemTypeID = $(this).children("itemTypeID").text().toUpperCase();
                            var itemType = (itemTypeID in all_item_types) ? all_item_types[itemTypeID] : "";
                            // var chargeable = $(this).children("chargeable").text();

                            // Do not display call number for on loan items
                            if (currentLocationID === 'ILLEND') {
                                callNumber = '';
                            }

                            holdings.push({
                                library: library,
                                location: location,
                                callNumber: callNumber,
                                itemType: itemType
                            });
                        });
                    }
                });

                $('.availability[data-keys="' + titleID +'"]').each(function () {
                    var availability = $(this);
                    var availabilityButton = availability.find('.availability-button');
                    var availabilityHoldingsPlaceHolder = availability.find('.availability-holdings');
                    var availabilitySnippetPlaceHolder = availability.find('.availability-snippet');
                    var holdButton = availability.find('.hold-button');

                    // If holdable, then display the hold button
                    if (holdable === 'true' && totalCopiesAvailable > 0) {
                        holdButton.removeClass("invisible").addClass("visible");
                    }

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
        }, "xml")
            .done(function(data) {
                // Now that the availability data has been rendered, check for ILL options and update links
                $('.availability-holdings [data-type="ill-link"]').each(function() {
                    var catkey = $(this).data('catkey');
                    var callNumber = $(this).data('call-number');
                    var archivalThesis = $(this).is('[data-archival-thesis]');
                    createILLURL($(this), catkey, callNumber, archivalThesis);
                });
                // Now that the availability data has been rendered, check for Aeon options and update links
                $('.availability-holdings [data-type="aeon-link"]').each(function() {
                    var catkey = $(this).data('catkey');
                    var callNumber = $(this).data('call-number');
                    var itemLocation = $(this).data('item-location');
                    createAeonURL($(this), catkey, callNumber, itemLocation);
                });
            }).fail(function(data) {
                $('.availability').each(function () {
                    $(this).addClass('availability-error alert alert-light');
                    $(this).html("Please check back shortly for item availability or <a href=\"https://libraries.psu.edu/ask\">ask a librarian</a> for assistance.");
                });
            });
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
                                <table id="holdings-${uniqueID}" class="table table-sm">
                                    <caption class="sr-only">Listing where to find this item in our buildings.</caption>
                                    <thead class="thead-light">
                                        <tr>
                                            <th>Call number</th>
                                            <th>Material</th>
                                            <th>Location</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${holdings.map(holding => `
                                            <tr>
                                                <td>${holding.callNumber}</td>
                                                <td>${holding.itemType}</td>
                                                <td>${holding.location}</td>
                                            </tr>
                                        `).join('')}
                                        ${moreHoldings.map(moreHolding => `
                                             <tr class="collapse" id="collapseHoldings${uniqueID}">
                                                <td>${moreHolding.callNumber}</td>
                                                <td>${moreHolding.itemType}</td>
                                                <td>${moreHolding.location}</td>
                                            </tr>     
                                         `).join('')}
                                        </tbody>
                                    </table>
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
        if (holdingData[index].summary.library === 'ON-ORDER') {
            libraries.push('')
        } else {
            libraries.push(holdingData[index].summary.library);
        }
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

function resolveLocation(currentLocationID, request_via_ill_locations, all_locations, titleID, callNumber) {
    var location = '';
    var spinner = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>';

    // Check request via ILL locations
    if (currentLocationID in request_via_ill_locations) {
        location = `<a data-type="ill-link" data-catkey="${titleID}" data-call-number="${callNumber}" href="#">${spinner}Copy unavailable, request via Interlibrary Loan</a>`;
    } else if (['ARKTHESES', 'AH-X-TRANS'].includes(currentLocationID)) {
        var aeonLocation = (currentLocationID in all_locations) ? all_locations[currentLocationID] : "";
        location = `<a data-type="ill-link" data-catkey="${titleID}" data-call-number="${callNumber}" data-archival-thesis href="#">${spinner}Request Scan - Penn State Users</a><br>
                    <a href="https://psu.illiad.oclc.org/illiad/upm/lending/lendinglogon.html">Request Scan - Guest</a><br>
                    <a data-type="aeon-link" data-catkey="${titleID}" data-call-number="${callNumber}" data-archival-thesis data-item-location="${aeonLocation}" href="#">${spinner}View in Special Collections</a>`;
    } else {
        location = (currentLocationID in all_locations) ? all_locations[currentLocationID] : "";
    }

    return location;
}

function createILLURL(jQueryObj, catkey, callNumber, archivalThesis) {
    $.get(`/catalog/${catkey}/raw.json`, function(data) {
        var ILLURL = "https://psu-illiad-oclc-org.ezaccess.libraries.psu.edu/illiad/upm/illiad.dll/OpenURL?Action=10";

        if (Object.keys(data).length > 0) {
            var title = data.title_display_ssm;
            var author = data.author_tsim ? data.author_tsim : "";
            var pubdate = data.pub_date_illiad_ssm ? data.pub_date_illiad_ssm : "";
            if (archivalThesis) {
                ILLURL += "&Form=20&Genre=GenericRequestThesisDigitization";
            }
            else {
                var ISBN = data.isbn_ssm ? data.isbn_ssm : "";
                ILLURL += `&Form=30&isbn=${ISBN}`;
            }
            ILLURL += `&title=${title}&callno=${callNumber}&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu`;
            if (author) {
                ILLURL += `&aulast=${author}`;
            }
            if (pubdate) {
                ILLURL += `&date=${pubdate}`;
            }
        }
        var spinner = jQueryObj.find('span');
        spinner.remove();
        jQueryObj.attr('href', ILLURL);
    });
}

function createAeonURL(jQueryObj, catkey, callNumber, itemLocation) {
    $.get(`/catalog/${catkey}/raw.json`, function(data) {
        var aeonURL = "https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30";
            if (Object.keys(data).length > 0) {
            var title = data.title_display_ssm;
            var author = data.author_tsim ? data.author_tsim : "";
            var publisher = data.publisher_name_ssm ? data.publisher_name_ssm : "";
            var pubdate = data.pub_date_illiad_ssm ? data.pub_date_illiad_ssm : "";
            var pubPlace = data.publication_place_ssm ? data.publication_place_ssm : "";
            var edition = data.edition_display_ssm ? data.edition_display_ssm : "";
            aeonURL += `&ReferenceNumber=${catkey}&Genre=THESIS&ItemTitle=${title}&ItemAuthor=${author}&Location=${itemLocation}&ItemNumber=&ItemEdition=${edition}&CallNumber=${callNumber}&ItemPublisher=${publisher}&ItemPlace=${pubPlace}&ItemDate=${pubdate}&ItemVolume=&ItemInfo1=`;
        }
        var spinner = jQueryObj.find('span');
        spinner.remove();
        jQueryObj.attr('href', aeonURL);
    });
}
