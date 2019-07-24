/**
 * @file
 * Real Time Availability
 */
import locations from './libraries_locations.json';
import item_types from './item_types.json';

// Load Sirsi locations
var allLocations = locations.locations;
var allLibraries = locations.libraries;
var illiadLocations = locations.request_via_ill;
var allItemTypes = item_types.item_types;

$(document).on('turbolinks:load', function() {
    loadAvailability();

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
function loadAvailability() {
    var titleIDs = [];

    // Get the catkeys
    $('.availability').each(function () {
        titleIDs.push($(this).attr("data-keys"));
    });

    if (titleIDs.length > 0) {
        var allHoldings = [];
        var boundHoldings = [];

        $.get('/available/' + titleIDs.join(','), function (xml) {
            $(xml).find('TitleInfo').each(function () {
                var catkey = $(this).children('titleID').text();
                var totalCopiesAvailable = parseInt($(this).find("totalCopiesAvailable").text(), 10);
                var holdable = $(this).find("holdable").text();
                var numberOfBoundwithLinks = parseInt($(this).find("numberOfBoundwithLinks").text(), 10);

                var titleInfo = {
                    jQueryObj: $(this),
                    catkey: catkey,
                    totalCopiesAvailable: totalCopiesAvailable,
                    holdable: holdable
                };

                // Process for regular records
                allHoldings = getAllHoldings(allHoldings, titleInfo);

                // Process for bound-with records
                if (numberOfBoundwithLinks > 0) {
                    boundHoldings = getBoundHoldings(boundHoldings, titleInfo);
                }
            });
        }, "xml")
            .then(function () {
                    if (Object.keys(boundHoldings).length > 0) {
                        // Get bound with parents and print availability data
                        processBoundParents(boundHoldings, allHoldings);
                    }
                    else {
                        // Print availability data
                        availabilityDisplay(allHoldings);
                    }
                }, function() {
                    displayErrorMsg();
                }
            );
    }
}

function getAllHoldings(allHoldings, titleInfo) {
    allHoldings[titleInfo.catkey] = [];

    titleInfo.jQueryObj.children('CallInfo').each(function () {
        var libraryID = $(this).children('libraryID').text();

        // Only for not online items (online items uses 856 urls for display)
        if (libraryID.toUpperCase() !== 'ONLINE') {
            var callNumber = $(this).children('callNumber').text();

            $(this).children("ItemInfo").each(function () {
                var currentLocationID = $(this).children("currentLocationID").text().toUpperCase();
                var itemID = $(this).children("itemID").text();
                var itemTypeID = $(this).children("itemTypeID").text().toUpperCase();

                allHoldings[titleInfo.catkey].push({
                    catkey: titleInfo.catkey,
                    libraryID: libraryID,
                    locationID: currentLocationID,
                    itemID: itemID,
                    callNumber: callNumber,
                    itemTypeID: itemTypeID,
                    totalCopiesAvailable: titleInfo.totalCopiesAvailable,
                    holdable: titleInfo.holdable
                });
            });
        }
    });

    return allHoldings;
}

function getBoundHoldings(boundHoldings, titleInfo) {
    boundHoldings[titleInfo.catkey] = [];

    titleInfo.jQueryObj.children('BoundwithLinkInfo').each(function () {
        var linkedAsParent = $(this).children('linkedAsParent').text();
        var linkedItemID = $(this).children('itemID').text();
        var callNumber = $(this).children('callNumber').text();

        $(this).children('linkedTitle').each(function () {
            var linkedCatkey = $(this).children('titleID').text();

            if (linkedAsParent === 'true' && titleInfo.catkey !== linkedCatkey) {
                boundHoldings[titleInfo.catkey][linkedItemID] = [];
                var linkedTitle = $(this).children('title').text();
                var author = $(this).children('author').text();
                var yearOfPublication = $(this).children('yearOfPublication').text();
                var boundinStatement = callNumber + " bound in " + linkedTitle + " " + author + " " + yearOfPublication;

                boundHoldings[titleInfo.catkey][linkedItemID].push({
                    catkey: titleInfo.catkey,
                    linkedItemID: linkedItemID,
                    linkedCatkey: linkedCatkey,
                    linkedTitle: linkedTitle,
                    author: author,
                    yearOfPublication: yearOfPublication,
                    callNumber: boundinStatement,
                    totalCopiesAvailable: titleInfo.totalCopiesAvailable,
                    holdable: titleInfo.holdable
                });

            }

        });
    });

    return boundHoldings;
}

function processBoundParents(boundHoldings, allHoldings) {
    var catkeys = Object.keys(boundHoldings);

    var itemIDs = [];
    $.each(catkeys, function(i, catkey) {
        itemIDs.push(Object.keys(boundHoldings[catkey]));
    });
    itemIDs = $.map(itemIDs, function(value){ return value; });

    $.get('/available/bound/' + itemIDs.join(','), function (xml) {
        $(xml).find('TitleInfo').each(function () {
            var parentCatkey = $(this).children('titleID').text();

            $(this).children('CallInfo').each(function () {
                var libraryID = $(this).children('libraryID').text();
                var callNumber = $(this).children('callNumber').text();

                $(this).children("ItemInfo").each(function () {
                    var currentLocationID = $(this).children("currentLocationID").text().toUpperCase();
                    var itemID = $(this).children("itemID").text();
                    var itemTypeID = $(this).children("itemTypeID").text().toUpperCase();

                    $.each(catkeys, function(i, catkey) {
                        if (itemID in boundHoldings[catkey]) {
                            boundHoldings[catkey][itemID].forEach(function (boundHolding) {
                                boundHolding.parentCatkey = parentCatkey;
                                boundHolding.parentCallNumber = callNumber;
                                boundHolding.itemTypeID = itemTypeID;
                                boundHolding.libraryID = libraryID;
                                boundHolding.locationID = currentLocationID;

                                allHoldings[catkey].push(boundHolding);

                                // once processed remove to avoid duplicates
                                // when children of same parent are in the search results
                                delete boundHoldings[catkey][itemID];
                            });
                        }
                    });
                });
            });
        });
    }, "xml")
        .then(function () {
            // Print availability data
            availabilityDisplay(allHoldings);
        }, function () {
            displayErrorMsg();
        });
}

function availabilityDisplay(allHoldings) {
    $('.availability').each(function () {
        var availability = $(this);
        var catkey = availability.data("keys");

        if (catkey in allHoldings) {
            var rawHoldings = allHoldings[catkey];
            var availabilityButton = availability.find('.availability-button');
            var holdingsPlaceHolder = availability.find('.availability-holdings');
            var snippetPlaceHolder = availability.find('.availability-snippet');
            var holdButton = availability.find('.hold-button');

            // If at least one physical copy, then display availability and holding info
            if (Object.keys(rawHoldings).length > 0) {
                availabilityButton.removeClass("invisible").addClass("visible");
                var holdings = groupByLibrary(rawHoldings);
                var structuredHoldings = availabilityDataStructurer(holdings);
                holdingsPlaceHolder.html(printAvailabilityData(structuredHoldings));
                availabilitySnippet(snippetPlaceHolder, structuredHoldings);

                // If holdable, then display the hold button
                if (rawHoldings[0].holdable === 'true') {
                    holdButton.removeClass("invisible").addClass("visible");
                }
            } else {
                // Document view
                $('.metadata-availability').remove();
                // Results view
                $(this).parent('.blacklight-availability').remove();
            }
        }
    });

    // Check for ILL and Aeon options and update links
    createILLURL();
    createAeonURL();
}

function printAvailabilityData(availabilityData) {
    var markupForHoldings = '';

    availabilityData.forEach(function(element, index) {
        var holdings = element.holdings;
        var catkey = holdings[0].catkey;
        var uniqueID = catkey + index;

        holdings.forEach(function(holding) {
            var item = {
                catkey: catkey,
                currentLocationID: holding.locationID,
                callNumber: holding.callNumber,
                itemID: holding.itemID
            };
            holding.location = printLocationHTML(item);
            holding.itemType = (holding.itemTypeID in allItemTypes) ? allItemTypes[holding.itemTypeID] : "";

            // Do not display call number for on loan items
            if (holding.locationID === 'ILLEND') {
                holding.callNumber = '';
            }
        });

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

function librariesText(holdingData) {
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

function availabilitySnippet(snippetPlaceHolder, holdingData) {
    var snippet = "";
    var totalCopiesAvailable = holdingData[0].holdings[0].totalCopiesAvailable;

    if (totalCopiesAvailable > 0) {
        snippet = holdingData.length > 2 ? 'Multiple Locations' : librariesText(holdingData);
    }
    else {
        // No available copies, do not display a snippet
        snippet = '';
    }
    snippetPlaceHolder.html(snippet);
}

function availabilityDataStructurer(holdingMetadata) {
    var availabilityStructuredData = [];
    var holdingData = [];
    var pluralize = "";
    var library = "";

    if (Object.keys(holdingMetadata).length > 0) {
        Object.keys(holdingMetadata).forEach(function (libraryID, index) {
            library = (libraryID in allLibraries) ? allLibraries[libraryID] : "";
            pluralize = (holdingMetadata[libraryID].length > 1) ? 'items' : 'item';

            holdingData = {
                "summary":
                    {
                        "library": library,
                        "countAtLibrary": holdingMetadata[libraryID].length,
                        "pluralize": pluralize
                    },
                "holdings": holdingMetadata[libraryID]
            };

            availabilityStructuredData[index] = holdingData;
        })
    }

    return availabilityStructuredData;
}

// Group holding by library
function groupByLibrary(holdings) {
    return holdings.reduce(function (accumulator, object) {
        var key = object['libraryID'];

        if (!accumulator[key]) {
            accumulator[key] = [];
        }
        accumulator[key].push(object);

        return accumulator;
    }, {});
}

function printLocationHTML(item) {
    var location = '';
    var spinner = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>';

    // Check request via ILL locations
    if (item.currentLocationID in illiadLocations) {
        location = `<a data-type="ill-link" data-catkey="${item.catkey}" data-call-number="${item.callNumber}" href="#">${spinner}Copy unavailable, request via Interlibrary Loan</a>`;
    } else if (['ARKTHESES', 'AH-X-TRANS'].includes(item.currentLocationID)) {
        var aeonLocation = mapLocation(allLocations, item);
        var shared = `data-catkey="${item.catkey}" data-call-number="${item.callNumber}" data-archival-thesis`;

        location = `<a data-type="ill-link" ${shared} href="#">${spinner}Request Scan - Penn State Users</a><br>
                    <a href="https://psu.illiad.oclc.org/illiad/upm/lending/lendinglogon.html">Request Scan - Guest</a><br>
                    <a data-type="aeon-link" ${shared} data-item-id="${item.itemID}" data-item-location="${aeonLocation}" href="#">${spinner}View in Special Collections</a>`;
    } else {
        location = mapLocation(allLocations, item);
    }

    return location;
}

function createILLURL(jQueryObj) {
    var illLinkObj = ";"
    $('.availability-holdings [data-type="ill-link"]').each(function () {
        illLinkObj = $(this);
        var catkey = $(this).data('catkey');
        var callNumber = $(this).data('call-number');
        var archivalThesis = $(this).is('[data-archival-thesis]');
        var item = {
            catkey: catkey,
            callNumber: callNumber,
            archivalThesis: archivalThesis
        };

        $.get(`/catalog/${item.catkey}/raw.json`, function(data) {
            var ILLURL = "https://psu-illiad-oclc-org.ezaccess.libraries.psu.edu/illiad/upm/illiad.dll/OpenURL?Action=10";

            if (Object.keys(data).length > 0) {
                var title = data.title_245ab_tsim;
                var author = data.author_tsim ? data.author_tsim : "";
                var pubDate = data.pub_date_illiad_ssm ? data.pub_date_illiad_ssm : "";
                if (item.archivalThesis) {
                    ILLURL += "&Form=20&Genre=GenericRequestThesisDigitization";
                }
                else {
                    var ISBN = data.isbn_ssm ? data.isbn_ssm : "";
                    ILLURL += `&Form=30&isbn=${ISBN}`;
                }
                ILLURL += `&title=${title}&callno=${item.callNumber}&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu`;
                if (author) {
                    ILLURL += `&aulast=${author}`;
                }
                if (pubDate) {
                    ILLURL += `&date=${pubDate}`;
                }
            }
            var spinner = illLinkObj.find('span');
            spinner.remove();
            illLinkObj.attr('href', ILLURL);
        });
    });
}

function createAeonURL() {
    var aeonLinkObj = "";
    // Now that the availability data has been rendered, check for Aeon options and update links
    $('.availability-holdings [data-type="aeon-link"]').each(function () {
        aeonLinkObj = $(this);
        var catkey = $(this).data('catkey');
        var callNumber = $(this).data('call-number');
        var itemLocation = $(this).data('item-location');
        var itemID = $(this).data('item-id');
        var item = {
            catkey: catkey,
            callNumber: callNumber,
            itemLocation: itemLocation,
            itemID: itemID
        };

        $.get(`/catalog/${item.catkey}/raw.json`, function(data) {
            var aeonURL = "https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30";
            aeonURL += `&ReferenceNumber=${item.catkey}&Genre=BOOK&Location=${item.itemLocation}&ItemNumber=${item.itemID}&CallNumber=${item.callNumber}`;
            if (Object.keys(data).length > 0) {
                var title = data.title_245ab_tsim;
                var author = data.author_tsim ? data.author_tsim : "";
                var publisher = data.publisher_name_ssm ? data.publisher_name_ssm : "";
                var pubDate = data.pub_date_illiad_ssm ? data.pub_date_illiad_ssm : "";
                var pubPlace = data.publication_place_ssm ? data.publication_place_ssm : "";
                var edition = data.edition_display_ssm ? data.edition_display_ssm : "";
                var restrictions = data.restrictions_access_note_ssm ? data.restrictions_access_note_ssm : "";
                aeonURL += `&ItemTitle=${title}&ItemAuthor=${author}&ItemEdition=${edition}&ItemPublisher=${publisher}&ItemPlace=${pubPlace}&ItemDate=${pubDate}&ItemInfo1=${restrictions}`;

            }
            var spinner = aeonLinkObj.find('span');
            spinner.remove();
            aeonLinkObj.attr('href', aeonURL);
        });
    });
}

function mapLocation(locations, item) {
    return (item.currentLocationID in locations) ? locations[item.currentLocationID] : "";
}

function displayErrorMsg() {
    // Display the error message
    $('.availability').each(function () {
        $(this).addClass('availability-error alert alert-light');
        $(this).html("Please check back shortly for item availability or <a href=\"https://libraries.psu.edu/ask\">ask a librarian</a> for assistance.");
    });
}