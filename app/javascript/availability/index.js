/**
 * @file
 * Real Time Availability
 */

import React from 'react';
import ReactDOM from 'react-dom';
import locations from './libraries_locations.json';
import itemTypes from './item_types.json';
import reserveCirculationRules from './reserve_circulation_rules.json';
import Availability from './components/availability';
import Snippet from './components/snippet';

const availability = {
  // Load Sirsi locations
  allLocations: locations.locations,
  allLibraries: locations.libraries,
  illiadLocations: locations.request_via_ill,
  reservesScanLocations: locations.reserves_scan,
  allItemTypes: itemTypes.item_types,
  reserveCirculationRules: reserveCirculationRules.reserve_circulation_rules,
  movedLocations: [],

  sirsiUrl: '/availability/sirsi-data/?',
  sirsiItemUrl: '/availability/sirsi-item-data/?',
  mapScanUrl: 'https://libraries.psu.edu/about/libraries/donald-w-hamer-center-maps-and-'
              + 'geospatial-information/map-scanning-and-printing',

  executeAvailability() {
    availability.loadAvailability();

    $('.availability').on('click', '[data-type=view-more-holdings]', function () {
      $(this).toggleClass('toggle-more');
      if ($(this).hasClass('toggle-more')) {
        $(this).text('View More');
      } else {
        $(this).text('View Less');
      }
    });
  },

  /**
     * Load real time holdings and availability info from Sirsi Web Services
     */
  loadAvailability() {
    const titleIDs = [];
    const summaryHoldings = {};

    // Get the catkeys
    $('.availability').each(function () {
      const titleID = $(this).attr('data-keys');
      titleIDs.push(titleID);

      const summaryHoldingsData = $(this).attr('data-summary-holdings');
      if (summaryHoldingsData) {
        summaryHoldings[titleID] = JSON.parse(summaryHoldingsData);
      }
    });

    if (titleIDs.length > 0) {
      let allHoldings = [];
      let boundHoldings = [];
      const sirsiRequestParams = titleIDs.map((url) => `title_ids[]=${url}`).join('&');

      $.ajax({
        url: availability.sirsiUrl + sirsiRequestParams,
      }).then((response) => {
        $(response).find('TitleInfo').each(function () {
          const catkey = $(this).children('titleID').text();
          const totalCopiesAvailable = parseInt($(this)
            .find('totalCopiesAvailable').text(), 10);
          const holdable = $(this).find('holdable').text();
          const numberOfBoundwithLinks = parseInt($(this)
            .find('numberOfBoundwithLinks').text(), 10);

          const titleInfo = {
            jQueryObj: $(this),
            catkey,
            totalCopiesAvailable,
            holdable,
          };

          // Process for regular records
          allHoldings = availability.getAllHoldings(allHoldings, titleInfo);

          // Process for bound-with records
          if (numberOfBoundwithLinks > 0) {
            boundHoldings = availability.getBoundHoldings(boundHoldings, titleInfo);
          }

          // check to see if the item is only available online AND is in ON-ORDER status
          const isOnlineOnOrderOnly = availability.getIsOnlineOnOrderOnly(titleInfo);

          if (isOnlineOnOrderOnly) {
            $(`.availability[data-keys="${catkey}"`).data('isOnlineOnOrderOnly', true);
          }
        });

        if (Object.keys(boundHoldings).length > 0) {
          // Get bound with parents and print availability data
          availability.processBoundParents(boundHoldings, allHoldings, summaryHoldings);
        } else {
          // Print availability data
          availability.availabilityDisplay(allHoldings, summaryHoldings);
        }
      }, () => {
        availability.displayErrorMsg();
      });
    }
  },

  getAllHoldings(allHoldings, titleInfo) {
    allHoldings[titleInfo.catkey] = [];

    titleInfo.jQueryObj.children('CallInfo').each(function () {
      const libraryID = $(this).children('libraryID').text();

      // Only for not online items (online items uses 856 urls for display)
      if (libraryID.toUpperCase() !== 'ONLINE') {
        const callNumber = $(this).children('callNumber').text();

        $(this).children('ItemInfo').each(function () {
          const currentLocationID = $(this).children('currentLocationID').text().toUpperCase();
          const homeLocationID = $(this).children('homeLocationID').text().toUpperCase();
          const itemID = $(this).children('itemID').text();
          const itemTypeID = $(this).children('itemTypeID').text().toUpperCase();
          const reserveCollectionID = $(this).children('reserveCollectionID').text();
          const reserveCirculationRule = $(this).children('reserveCirculationRule').text();
          const dueDate = $(this).children('dueDate').text();
          const publicNote = $(this).children('publicNote').text();

          allHoldings[titleInfo.catkey].push({
            catkey: titleInfo.catkey,
            libraryID,
            locationID: currentLocationID,
            homeLocationID,
            itemID,
            callNumber,
            itemTypeID,
            totalCopiesAvailable: titleInfo.totalCopiesAvailable,
            holdable: titleInfo.holdable,
            reserveCollectionID,
            reserveCirculationRule,
            dueDate,
            publicNote,
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
          const boundinStatement = `${callNumber} bound in ${linkedTitle} ${author} ${yearOfPublication}`;

          boundHoldings[titleInfo.catkey][linkedItemID].push({
            catkey: titleInfo.catkey,
            linkedItemID,
            linkedCatkey,
            linkedTitle,
            author,
            yearOfPublication,
            callNumber: boundinStatement,
            totalCopiesAvailable: titleInfo.totalCopiesAvailable,
            holdable: titleInfo.holdable,
          });
        }
      });
    });

    if (Object.keys(boundHoldings[titleInfo.catkey]).length === 0) {
      delete boundHoldings[titleInfo.catkey];
    }

    return boundHoldings;
  },

  /**
     * Determines whether the item is available ONLY online and all copies are ON-ORDER
     */
  getIsOnlineOnOrderOnly(titleInfo) {
    let isOnlineOnOrderOnly = true;

    titleInfo.jQueryObj.children('CallInfo').each(function () {
      const libraryID = $(this).children('libraryID').text();

      if (libraryID.toUpperCase() !== 'ONLINE') {
        isOnlineOnOrderOnly = false;
        return false;
      }

      $(this).children('ItemInfo').each(function () {
        const currentLocationID = $(this).children('currentLocationID').text().toUpperCase();

        if (currentLocationID !== 'ON-ORDER') {
          isOnlineOnOrderOnly = false;
          return false;
        }
      });
    });

    return isOnlineOnOrderOnly;
  },

  processBoundParents(boundHoldings, allHoldings, summaryHoldings) {
    const catkeys = Object.keys(boundHoldings);

    let itemIDs = [];
    $.each(catkeys, (i, catkey) => {
      itemIDs.push(Object.keys(boundHoldings[catkey]));
    });
    itemIDs = $.map(itemIDs, (value) => value);
    const sirsiBoundRequestParams = itemIDs.map((url) => `item_ids[]=${url}`).join('&');

    $.ajax({
      url: availability.sirsiItemUrl + sirsiBoundRequestParams,
    }).then((response) => {
      $(response).find('TitleInfo').each(function () {
        const parentCatkey = $(this).children('titleID').text();

        $(this).children('CallInfo').each(function () {
          const libraryID = $(this).children('libraryID').text();
          const callNumber = $(this).children('callNumber').text();

          $(this).children('ItemInfo').each(function () {
            const currentLocationID = $(this).children('currentLocationID')
              .text()
              .toUpperCase();
            const homeLocationID = $(this).children('homeLocationID').text().toUpperCase();
            const itemID = $(this).children('itemID').text();
            const itemTypeID = $(this).children('itemTypeID').text().toUpperCase();
            const reserveCollectionID = $(this).children('reserveCollectionID').text();

            $.each(catkeys, (i, catkey) => {
              if (itemID in boundHoldings[catkey]) {
                boundHoldings[catkey][itemID].forEach((boundHolding) => {
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
      availability.availabilityDisplay(allHoldings, summaryHoldings);
    }, () => {
      availability.displayErrorMsg();
    });
  },

  availabilityDisplay(allHoldings, summaryHoldings) {
    $('.availability').each(function () {
      const availabilityHTML = $(this);
      const catkey = availabilityHTML.data('keys');
      const isOnlineOnOrderOnly = availabilityHTML.data('isOnlineOnOrderOnly');

      if (catkey in allHoldings) {
        const rawHoldings = allHoldings[catkey];
        const availabilityButton = availabilityHTML.find('.availability-button');
        const holdingsPlaceHolder = availabilityHTML.find('.availability-holdings');
        const snippetPlaceHolder = availabilityHTML.find('.availability-snippet');
        const holdButton = availabilityHTML.find('.hold-button');

        // If at least one physical copy, then display availability and holding info
        if (Object.keys(rawHoldings).length > 0) {
          availabilityButton.removeClass('invisible').addClass('visible');
          const holdings = availability.groupByLibrary(rawHoldings);
          const structuredHoldings = availability.availabilityDataStructurer(holdings);

          ReactDOM.render(
            React.createElement(
              Availability,
              {
                structuredHoldings,
                summaryHoldings: summaryHoldings ? summaryHoldings[catkey] : null,
              },
            ),
            holdingsPlaceHolder[0],
          );

          if (snippetPlaceHolder && snippetPlaceHolder.length === 1) {
            ReactDOM.render(
              React.createElement(Snippet, { data: structuredHoldings }),
              snippetPlaceHolder[0],
            );
          }

          // If holdable, then display the hold button
          if (availability.showHoldButton(rawHoldings)) {
            holdButton.removeClass('d-none').addClass('d-md-inline');
          }
        } else if (isOnlineOnOrderOnly) {
          // only have online copies, but they are in the process of being acquired by the library
          const beingAcquiredMsg = 'Being acquired by the library';

          // Document view
          holdingsPlaceHolder.html(`<h5>${beingAcquiredMsg}</h5>`);
          // Results view
          snippetPlaceHolder.parent('.row').html(`<strong>${beingAcquiredMsg}</strong>`);
        } else {
          // Document view
          $('.metadata-availability').remove();
          // Results view
          $(this).parent('.blacklight-availability').remove();
        }
      } else {
        // Results view
        // When catkey not in the response, even the spinner
        // should not be displayed so remove the parent
        $(this).parent('.blacklight-availability').remove();
      }
    });

    // initialize tooltips
    $('i.fas.fa-info-circle[data-toggle="tooltip"]').tooltip();
  },

  availabilityDataStructurer(holdingMetadata) {
    const availabilityStructuredData = [];
    let holdingData = [];
    let pluralize = '';
    let library = '';
    const { allItemTypes } = availability;

    if (Object.keys(holdingMetadata).length > 0) {
      Object.keys(holdingMetadata).forEach((libraryID, index) => {
        library = (libraryID in availability.allLibraries) ? availability.allLibraries[libraryID] : '';
        pluralize = (holdingMetadata[libraryID].length > 1) ? 'items' : 'item';

        // Supplement data with an itemType and remove callNumber conditionally
        holdingMetadata[libraryID].forEach((element) => {
          element.itemType = element.itemTypeID in allItemTypes ? allItemTypes[element.itemTypeID] : '';
        });

        holdingData = {
          summary:
                        {
                          libraryID,
                          library,
                          countAtLibrary: holdingMetadata[libraryID].length,
                          pluralize,
                        },
          holdings: holdingMetadata[libraryID],
        };

        availabilityStructuredData[index] = holdingData;
      });
    }

    return availabilityStructuredData;
  },

  // Group holding by library
  groupByLibrary(holdings) {
    return holdings.reduce((accumulator, object) => {
      const key = object.libraryID;

      if (!accumulator[key]) {
        accumulator[key] = [];
      }
      accumulator[key].push(object);

      return accumulator;
    }, {});
  },

  displayErrorMsg() {
    // Display the error message
    $('.availability').each(function () {
      $(this).addClass('availability-error alert alert-light');
      $(this).html('Please check back shortly for item availability or '
                  + '<a href="https://libraries.psu.edu/ask">ask a librarian</a> for assistance.');
    });
  },

  isMoved(location) {
    return availability.movedLocations.includes(location);
  },

  isReserves(holding) {
    return availability.reservesScanLocations.includes(holding.locationID);
  },

  isMicroform(holding) {
    return (['UP-MICRO'].includes(holding.libraryID)
            && holding.homeLocationID !== 'THESIS-NML'
            && holding.itemTypeID === 'MICROFORM');
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
  },
};

export default availability;
