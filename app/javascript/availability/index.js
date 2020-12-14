/**
 * @file
 * Real Time Availability
 */

import locations from './libraries_locations.json';
import item_types from './item_types.json';

const availability = {
    // Load Sirsi locations
    allLocations: locations.locations,
    allLibraries: locations.libraries,
    illiadLocations: locations.request_via_ill,
    allItemTypes: item_types.item_types,
    movedLocations: [],

    sirsiUrl: 'https://cat.libraries.psu.edu:28443/symwsbc/rest/standard/lookupTitleInfo?' +
              'clientID=BCCAT&includeAvailabilityInfo=true&includeItemInfo=true' +
              '&includeBoundTogether=true',
    sirsiItemUrl: 'https://cat.libraries.psu.edu:28443/symwsbc/rest/standard/lookupTitleInfo?' +
                  'clientID=BCPAC&includeAvailabilityInfo=true&includeItemInfo=true',
    mapScanUrl: 'https://libraries.psu.edu/about/libraries/donald-w-hamer-center-maps-and-' +
                'geospatial-information/map-scanning-and-printing',

    executeAvailability() {
        availability.loadAvailability();

        $(".availability").on("click", "[data-type=view-more-holdings]", function () {
            $(this).toggleClass('toggle-more');
            if ($(this).hasClass('toggle-more')) {
                $(this).text("View More");
            }
            else {
                $(this).text("View Less");
            }
        });
    },

    /**
     * Load real time holdings and availability info from Sirsi Web Services
     */
    loadAvailability() {
        let titleIDs = [];

        // Get the catkeys
        $('.availability').each(function () {
            titleIDs.push($(this).attr("data-keys"));
        });

        if (titleIDs.length > 0) {
            let allHoldings = [];
            let boundHoldings = [];
            const sirsiRequestParams = titleIDs.map(url => '&titleID=' + url).join('');

            $.ajax({
                url: availability.sirsiUrl + sirsiRequestParams
            }).then(function (response) {
                    $(response).find('TitleInfo').each(function () {
                        const catkey = $(this).children('titleID').text();
                        const totalCopiesAvailable = parseInt($(this)
                            .find("totalCopiesAvailable").text(), 10);
                        const holdable = $(this).find("holdable").text();
                        const numberOfBoundwithLinks = parseInt($(this)
                            .find("numberOfBoundwithLinks").text(), 10);

                        const titleInfo = {
                            jQueryObj: $(this),
                            catkey: catkey,
                            totalCopiesAvailable: totalCopiesAvailable,
                            holdable: holdable
                        };

                        // Process for regular records
                        allHoldings = availability.getAllHoldings(allHoldings, titleInfo);

                        // Process for bound-with records
                        if (numberOfBoundwithLinks > 0) {
                            boundHoldings = availability.getBoundHoldings(boundHoldings, titleInfo);
                        }
                    });

                    if (Object.keys(boundHoldings).length > 0) {
                        // Get bound with parents and print availability data
                        availability.processBoundParents(boundHoldings, allHoldings);
                    }
                    else {
                        // Print availability data
                        availability.availabilityDisplay(allHoldings);
                    }
                }, function() {
                    availability.displayErrorMsg();
                }
            );
        }
    },

    getAllHoldings(allHoldings, titleInfo) {
        allHoldings[titleInfo.catkey] = [];

        titleInfo.jQueryObj.children('CallInfo').each(function () {
            const libraryID = $(this).children('libraryID').text();

            // Only for not online items (online items uses 856 urls for display)
            if (libraryID.toUpperCase() !== 'ONLINE') {
                const callNumber = $(this).children('callNumber').text();

                $(this).children("ItemInfo").each(function () {
                    const currentLocationID = $(this).children("currentLocationID").text().toUpperCase();
                    const homeLocationID = $(this).children("homeLocationID").text().toUpperCase();
                    const itemID = $(this).children("itemID").text();
                    const itemTypeID = $(this).children("itemTypeID").text().toUpperCase();
                    const reserveCollectionID =  $(this).children("reserveCollectionID").text();

                    allHoldings[titleInfo.catkey].push({
                        catkey: titleInfo.catkey,
                        libraryID: libraryID,
                        locationID: currentLocationID,
                        homeLocationID: homeLocationID,
                        itemID: itemID,
                        callNumber: callNumber,
                        itemTypeID: itemTypeID,
                        totalCopiesAvailable: titleInfo.totalCopiesAvailable,
                        holdable: titleInfo.holdable,
                        reserveCollectionID: reserveCollectionID
                    });
                });
            }
        });

        return allHoldings;
    },

    getBoundHoldings(boundHoldings, titleInfo) {
        boundHoldings[titleInfo.catkey] = [];

        titleInfo.jQueryObj.children('BoundwithLinkInfo').each(function () {
            const linkedAsParent = $(this).children('linkedAsParent').text();
            const linkedItemID = $(this).children('itemID').text();
            const callNumber = $(this).children('callNumber').text();

            $(this).children('linkedTitle').each(function () {
                const linkedCatkey = $(this).children('titleID').text();

                if (linkedAsParent === 'true' && titleInfo.catkey !== linkedCatkey) {
                    boundHoldings[titleInfo.catkey][linkedItemID] = [];
                    const linkedTitle = $(this).children('title').text();
                    const author = $(this).children('author').text();
                    const yearOfPublication = $(this).children('yearOfPublication').text();
                    const boundinStatement = callNumber + " bound in " + linkedTitle + " " + author +
                        " " + yearOfPublication;

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

        if (Object.keys(boundHoldings[titleInfo.catkey]).length == 0) {
            delete boundHoldings[titleInfo.catkey];
        }

        return boundHoldings;
    },

    processBoundParents(boundHoldings, allHoldings) {
        const catkeys = Object.keys(boundHoldings);

        let itemIDs = [];
        $.each(catkeys, function(i, catkey) {
            itemIDs.push(Object.keys(boundHoldings[catkey]));
        });
        itemIDs = $.map(itemIDs, function(value){ return value; });
        const sirsiBoundRequestParams = itemIDs.map(url => '&itemID=' + url).join('');

        $.ajax({
            url: availability.sirsiItemUrl + sirsiBoundRequestParams
        }).then(function (response) {
            $(response).find('TitleInfo').each(function () {
                const parentCatkey = $(this).children('titleID').text();

                $(this).children('CallInfo').each(function () {
                    const libraryID = $(this).children('libraryID').text();
                    const callNumber = $(this).children('callNumber').text();

                    $(this).children("ItemInfo").each(function () {
                        const currentLocationID = $(this).children("currentLocationID")
                            .text()
                            .toUpperCase();
                        const homeLocationID = $(this).children("homeLocationID").text().toUpperCase();
                        const itemID = $(this).children("itemID").text();
                        const itemTypeID = $(this).children("itemTypeID").text().toUpperCase();
                        const reserveCollectionID =  $(this).children("reserveCollectionID").text();

                        $.each(catkeys, function(i, catkey) {
                            if (itemID in boundHoldings[catkey]) {
                                boundHoldings[catkey][itemID].forEach(function (boundHolding) {
                                    boundHolding.parentCatkey = parentCatkey;
                                    boundHolding.parentCallNumber = callNumber;
                                    boundHolding.itemTypeID = itemTypeID;
                                    boundHolding.libraryID = libraryID;
                                    boundHolding.locationID = currentLocationID;
                                    boundHolding.homeLocationID = homeLocationID;
                                    boundHolding.reserveCollectionID = reserveCollectionID;

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

            // Print availability data
            availability.availabilityDisplay(allHoldings);
        }, function () {
            availability.displayErrorMsg();
        });
    },

    availabilityDisplay(allHoldings) {
        $('.availability').each(function () {
            const availabilityHTML = $(this);
            const catkey = availabilityHTML.data("keys");

            if (catkey in allHoldings) {
                const rawHoldings = allHoldings[catkey];
                const availabilityButton = availabilityHTML.find('.availability-button');
                const holdingsPlaceHolder = availabilityHTML.find('.availability-holdings');
                const snippetPlaceHolder = availabilityHTML.find('.availability-snippet');
                const holdButton = availabilityHTML.find('.hold-button');

                // If at least one physical copy, then display availability and holding info
                if (Object.keys(rawHoldings).length > 0) {
                    availabilityButton.removeClass("invisible").addClass("visible");
                    const holdings = availability.groupByLibrary(rawHoldings);
                    const structuredHoldings = availability.availabilityDataStructurer(holdings);
                    holdingsPlaceHolder.html(availability.printAvailabilityData(structuredHoldings));
                    availability.availabilitySnippet(snippetPlaceHolder, structuredHoldings);

                    // If holdable, then display the hold button
                    if (availability.showHoldButton(rawHoldings)) {
                        holdButton.removeClass("invisible").addClass("visible");
                    }
                } else {
                    // Document view
                    $('.metadata-availability').remove();
                    // Results view
                    $(this).parent('.blacklight-availability').remove();
                }
            }
            else {
                // Results view
                // When catkey not in the response, even the spinner
                // should not be displayed so remove the parent
                $(this).parent('.blacklight-availability').remove();
            }
        });

        // Check for ILL and Aeon options and update links
        availability.createILLURL();
        availability.createAeonURL();
    },

    printAvailabilityData(availabilityData) {
        let markupForHoldings = '';

        availabilityData.forEach(function(element, index) {
            const holdings = element.holdings;
            const catkey = holdings[0].catkey;
            const uniqueID = catkey + index;
            const moreHoldings = holdings.length > 4 ? holdings.splice(4,holdings.length) : [];

            markupForHoldings += `
                            <div data-library="${element.summary.libraryID}">
                                <h5>${element.summary.library} (${element.summary.countAtLibrary} 
                                    ${element.summary.pluralize})</h5>
                                <table id="holdings-${uniqueID}" class="table table-sm">
                                    <caption class="sr-only">Listing where to find this item in our
                                                             buildings.</caption>
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
                                                <td>${availability.generateCallNumber(holding)}</td>
                                                <td>${holding.itemType}</td>
                                                <td>${availability.generateLocationHTML(holding)}
                                                    ${availability.appendMapScanLink(holding)}</td>
                                            </tr>
                                        `).join('')}
                                        ${moreHoldings.map(moreHolding => `
                                             <tr class="collapse" id="collapseHoldings${uniqueID}">
                                                <td>${availability.generateCallNumber(moreHolding)}</td>
                                                <td>${moreHolding.itemType}</td>
                                                <td>${availability.generateLocationHTML(moreHolding)}</td>
                                            </tr>     
                                         `).join('')}
                                        </tbody>
                                    </table>
                              `;
            if (moreHoldings.length > 0) {
                markupForHoldings += `<button class="btn btn-primary toggle-more" 
                                    data-type="view-more-holdings" 
                                    data-target="#collapseHoldings${uniqueID}" 
                                    data-toggle="collapse" role="button" 
                                    aria-expanded="false" 
                                    aria-controls="collapseHoldings${uniqueID}">View More
                                   </button>`;
            }

            markupForHoldings += '</div>';
        });

        return markupForHoldings;
    },

    librariesText(holdingData) {
        let libraries = [];

        for (let index in holdingData) {
            if (holdingData[index].summary.library === 'ON-ORDER') {
                libraries.push('')
            } else {
                libraries.push(holdingData[index].summary.library);
            }
        }

        return libraries.join(', ');
    },

    availabilitySnippet(snippetPlaceHolder, holdingData) {
        let snippet = "";
        const totalCopiesAvailable = holdingData[0].holdings[0].totalCopiesAvailable;

        if (totalCopiesAvailable > 0) {
            snippet = holdingData.length > 2 ? 'Multiple Locations' : availability.librariesText(holdingData);
        }
        else {
            // No available copies, do not display a snippet
            snippet = '';
        }
        snippetPlaceHolder.html(snippet);
    },

    availabilityDataStructurer(holdingMetadata) {
        let availabilityStructuredData = [];
        let holdingData = [];
        let pluralize = "";
        let library = "";
        let allItemTypes = availability.allItemTypes;

        if (Object.keys(holdingMetadata).length > 0) {
            Object.keys(holdingMetadata).forEach(function (libraryID, index) {
                library = (libraryID in availability.allLibraries) ? availability.allLibraries[libraryID] : "";
                pluralize = (holdingMetadata[libraryID].length > 1) ? 'items' : 'item';

                // Supplement data with an itemType and remove callNumber conditionally
                holdingMetadata[libraryID].forEach(function(element) {
                    element.itemType = element.itemTypeID in allItemTypes ? allItemTypes[element.itemTypeID] : "";
                });

                holdingData = {
                    "summary":
                        {
                            "libraryID": libraryID,
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
    },

    // Group holding by library
    groupByLibrary(holdings) {
        return holdings.reduce(function (accumulator, object) {
            const key = object['libraryID'];

            if (!accumulator[key]) {
                accumulator[key] = [];
            }
            accumulator[key].push(object);

            return accumulator;
        }, {});
    },

    generateCallNumber(holding) {
        // Do not display call number for on loan items
        return (holding.locationID === "ILLEND") ? "" : holding.callNumber;
    },

    generateLocationHTML(holding) {
        const spinner = '<span class="spinner-border spinner-border-sm" ' +
            '                role="status" aria-hidden="true"></span>';

        // Location information presented to the user is different based on a few scenarios
        // First, if it's related to ILL
        if (availability.isIllLink(holding)) {
            const illLocation = `<a 
                            data-type="ill-link" 
                            data-catkey="${holding.catkey}" 
                            data-call-number="${holding.callNumber}" 
                            data-link-type="${availability.illLinkType(holding)}"
                            data-item-location="${holding.locationID}"
                            href="#"
                        >${spinner}${availability.illLinkText(holding)}</a>`;

            return illLocation;
        }

        // AEON
        if (availability.isArchivalThesis(holding)) {
            const illiadURL = "https://psu.illiad.oclc.org/illiad/upm/lending/lendinglogon.html";
            const aeonLocationText = availability.mapLocation(availability.allLocations, holding.locationID);

            const aeonLocation = `<a 
                                data-type="ill-link" 
                                data-catkey="${holding.catkey}" 
                                data-call-number="${holding.callNumber}" 
                                data-link-type="archival-thesis" 
                                data-item-type="${holding.itemTypeID}" 
                                href="#">${spinner}Request Scan - Penn State Users</a><br>
                            <a href="${illiadURL}">Request Scan - Guest</a><br>
                            <a 
                                data-type="aeon-link" 
                                data-catkey="${holding.catkey}"
                                data-call-number="${holding.callNumber}"
                                data-link-type="archival-thesis"
                                data-item-type="${holding.itemTypeID}"
                                data-item-id="${holding.itemID}"
                                data-item-location="${aeonLocationText}"
                                href="#">${spinner}View in Special Collections</a>`;

            return aeonLocation;
        }

        // Special Collections
        if (availability.isArchivalMaterial(holding)) {
            const specialCollectionsText = availability.mapLocation(availability.allLocations, holding.locationID);

            const specialCollectionsLocation = `${specialCollectionsText}<br> 
                                        <a 
                                            data-type="aeon-link" 
                                            data-catkey="${holding.catkey}" 
                                            data-call-number="${holding.callNumber}" 
                                            data-link-type="archival-material" 
                                            data-item-type="${holding.itemTypeID}" 
                                            data-item-id="${holding.itemID}" 
                                            data-item-location="${specialCollectionsText}" 
                                            href="#">${spinner}Request Material</a>`;
            return specialCollectionsLocation;
        }

        // Otherwise use the default translation map for location display, no link
        return availability.mapLocation(availability.allLocations, holding.locationID);
    },

    appendMapScanLink(holding) {
        if (availability.isUPSpecialMap(holding)) {
            return `<br><a target="_blank" href="${availability.mapScanUrl}">Request scan</a>`;
        }
    },

    createILLURL() {
        // Now that the availability data has been rendered, check for ILL options and update links
        $('.availability-holdings [data-type="ill-link"]').each(function () {
            let ILLURL = "https://psu-illiad-oclc-org.ezaccess.libraries.psu.edu/illiad/upm/illiad.dll/" +
                "OpenURL?Action=10";
            let illLinkObj = $(this);
            const catkey = $(this).data('catkey');
            const callNumber = encodeURIComponent($(this).data('call-number'));
            const linkType = encodeURIComponent($(this).data('link-type'));
            const itemLocation = encodeURIComponent($(this).data('item-location'));

            $.get(`/catalog/${catkey}/raw.json`, function(data) {
                if (Object.keys(data).length > 0) {
                    const title = encodeURIComponent(data.title_245ab_tsim);
                    const author = encodeURIComponent(data.author_tsim ? data.author_tsim : "");
                    const pubDate = data.pub_date_illiad_ssm ? data.pub_date_illiad_ssm : "";
                    if (linkType === "archival-thesis") {
                        ILLURL += "&Form=20&Genre=GenericRequestThesisDigitization";
                    }
                    else {
                        const ISBN = data.isbn_ssm ? data.isbn_ssm : "";
                        ILLURL += `&Form=30&isbn=${ISBN}`;
                    }
                    if (linkType === "reserves-scan") {
                        ILLURL += `&Genre=GenericRequestReserves&location=${itemLocation}`;
                    }
                    if (linkType === "news-microform-scan") {
                        ILLURL += `&Genre=GenericRequestMicroScan&location=${itemLocation}`;
                    }
                    ILLURL += `&title=${title}&callno=${callNumber}&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu`;
                    if (author) {
                        ILLURL += `&aulast=${author}`;
                    }
                    if (pubDate) {
                        ILLURL += `&date=${pubDate}`;
                    }
                }
            }).done(function () {
                let spinner = illLinkObj.find('span');
                spinner.remove();
                illLinkObj.attr('href', ILLURL);
            });
        });
    },

    createAeonURL() {
        // Now that the availability data has been rendered, check for Aeon options and update links
        $('.availability-holdings [data-type="aeon-link"]').each(function () {
            let aeonLinkObj = $(this);
            const catkey = $(this).data('catkey');
            const callNumber = encodeURIComponent($(this).data('call-number'));
            const itemLocation = encodeURIComponent($(this).data('item-location'));
            const itemID = encodeURIComponent($(this).data('item-id'));
            const itemTypeID = $(this).data('item-type');
            const genre = itemTypeID === "ARCHIVES" ? "ARCHIVES" : "BOOK";
            let aeonURL = `https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30` +
                `&ReferenceNumber=${catkey}&Genre=${genre}&Location=${itemLocation}` +
                `&ItemNumber=${itemID}&CallNumber=${callNumber}`;

            $.get(`/catalog/${catkey}/raw.json`, function(data) {
                if (Object.keys(data).length > 0) {
                    const title = encodeURIComponent(data.title_245ab_tsim);
                    const author = encodeURIComponent(data.author_tsim ? data.author_tsim : "");
                    const publisher = encodeURIComponent(data.publisher_name_ssm ? data.publisher_name_ssm : "");
                    const pubDate = encodeURIComponent(data.pub_date_illiad_ssm ? data.pub_date_illiad_ssm : "");
                    const pubPlace = encodeURIComponent(data.publication_place_ssm ? data.publication_place_ssm : "");
                    const edition = encodeURIComponent(data.edition_display_ssm ? data.edition_display_ssm : "");
                    const restrictions = encodeURIComponent(
                        data.restrictions_access_note_ssm ? data.restrictions_access_note_ssm : ""
                    );
                    const subLocation = encodeURIComponent(data.sublocation_ssm ? data.sublocation_ssm.join("; ") : "");
                    aeonURL += `&ItemTitle=${title}&ItemAuthor=${author}&ItemEdition=${edition}&ItemPublisher=` +
                        `${publisher}&ItemPlace=${pubPlace}&ItemDate=${pubDate}&ItemInfo1=${restrictions}` +
                        `&SubLocation=${subLocation}`;

                }
            }).done(function () {
                let spinner = aeonLinkObj.find('span');
                spinner.remove();
                aeonLinkObj.attr('href', aeonURL);
            });
        });
    },

    mapLocation(locations, locationID) {
        return (locationID in locations) ? locations[locationID] : "";
    },

    displayErrorMsg() {
        // Display the error message
        $('.availability').each(function () {
            $(this).addClass('availability-error alert alert-light');
            $(this).html("Please check back shortly for item availability or " +
                "<a href=\"https://libraries.psu.edu/ask\">ask a librarian</a> for assistance.");
        });
    },

    isMoved(location) {
        return availability.movedLocations.includes(location);
    },

    illLinkText(holding) {
        if (availability.isMicroform(holding)) return "Request Scan - Penn State Users";

        return availability.illiadLocations[holding.locationID];
    },

    illLinkType(holding) {
        if (availability.isReserves(holding)) return "reserves-scan";
        if (availability.isMicroform(holding)) return "news-microform-scan";

        return "request-via-ill";
    },

    isReserves(holding) {
        return ['RESERVE-EM', 'RESERVE-EG', 'RESERVE-PM'].includes(holding.locationID);
    },

    isMicroform(holding) {
        return (['UP-MICRO'].includes(holding.libraryID) &&
            holding.homeLocationID !== 'THESIS-NML' &&
            holding.itemTypeID === 'MICROFORM');
    },

    isIllLink(holding) {
        return (holding.locationID in availability.illiadLocations || availability.isMicroform(holding));
    },

    isArchivalThesis(holding) {
        return ['ARKTHESES', 'AH-X-TRANS'].includes(holding.locationID);
    },

    isArchivalMaterial(holding) {
        return (['UP-SPECCOL'].includes(holding.libraryID) && !availability.isMoved(holding.homeLocationID));
    },

    isUPSpecialMap(holding) {
        return ['MAPSPEC'].includes(holding.itemTypeID) && ['UP-MAPS'].includes(holding.libraryID);
    },

    showHoldButton(holdings) {
        return holdings[0].holdable === 'true' && !availability.allCourseReserves(holdings);
    },

    allCourseReserves(holdings) {
        for (const holding of holdings) {
            if (holding.reserveCollectionID.length === 0) {
                return false;
            }
        }

        return true;
    }
};

export default availability;