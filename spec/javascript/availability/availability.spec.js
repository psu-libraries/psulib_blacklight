// eslint-disable-next-line import/no-extraneous-dependencies
import $ from 'jquery';
import availability from '../../../app/javascript/availability/index';
import 'bootstrap';

global.$ = $;
global.jQuery = $;

jest.mock(
  '../../../app/javascript/availability/libraries_locations.json',
  () => ({
    closed_libraries: ['NEWKEN'],
    locations: {
      'STACKS-NK': 'Stacks - General Collection',
      'STACKS-AB': 'Stacks - General Collection',
      'STACKS-FE': 'Stacks - General Collection',
      'STACKS-YK': 'Stacks - General Collection',
    },
    libraries: {
      NEWKEN: 'Penn State New Kensington',
      ABINGTON: 'Penn State Abington',
      FAYETTE: 'Penn State Fayette',
      YORK: 'Penn State York',
    },
    non_holdable: ['CHECKEDOUT'],
  }),
  { virtual: true },
);
jest.mock('react-dom', () => ({
  render: jest.fn(),
}));
const summaryHoldingsMock = {};

beforeEach(() => {
  document.body.innerHTML = `<div class="availability" data-keys="0">
  <div class="no-recalls-button text-right d-none mb-2">
    <a href="ill_url" class="btn btn-primary pr-4 pl-4">I Want It</a>
  </div>
  <div class="hold-button text-right d-none mb-2">
  <a href="symphony_url" class="btn btn-primary pr-4 pl-4">I Want It</a>
  </div>
  </div>`;
});

describe('when a holdable record is only in a closed library', () => {
  test('I Want It directs to ILLiad placement', () => {
    const allHoldingsMock = [
      [
        {
          catkey: '0',
          libraryID: 'NEWKEN',
          locationID: 'STACKS-NK',
          holdable: 'true',
          reserveCollectionID: '',
        },
      ],
    ];

    availability.availabilityDisplay(allHoldingsMock, summaryHoldingsMock);

    const noRecallsButton = document.querySelector('.no-recalls-button');
    const holdButton = document.querySelector('.hold-button');

    expect(holdButton.classList.contains('d-none')).toBe(true);
    expect(holdButton.classList.contains('d-md-inline')).toBe(false);
    expect(noRecallsButton.classList.contains('d-none')).toBe(false);
    expect(noRecallsButton.classList.contains('d-md-inline')).toBe(true);
  });
});

describe('when a holdable record is in a closed library and a holdable location', () => {
  test('I Want It directs to Symphony placement', () => {
    const allHoldingsMock = [
      [
        {
          catkey: '0',
          libraryID: 'NEWKEN',
          locationID: 'STACKS-NK',
          holdable: 'true',
          reserveCollectionID: '',
        },
        {
          catkey: '0',
          libraryID: 'FAYETTE',
          locationID: 'STACKS-FE',
          holdable: 'true',
          reserveCollectionID: '',
        },
      ],
    ];

    availability.availabilityDisplay(allHoldingsMock, summaryHoldingsMock);

    const noRecallsButton = document.querySelector('.no-recalls-button');
    const holdButton = document.querySelector('.hold-button');

    expect(holdButton.classList.contains('d-none')).toBe(false);
    expect(holdButton.classList.contains('d-md-inline')).toBe(true);
    expect(noRecallsButton.classList.contains('d-none')).toBe(true);
    expect(noRecallsButton.classList.contains('d-md-inline')).toBe(false);
  });
});

describe('when a holdable record is in a closed library and a non holdable location', () => {
  test('I Want It directs to ILLiad placement', () => {
    const allHoldingsMock = [
      [
        {
          catkey: '0',
          libraryID: 'NEWKEN',
          locationID: 'STACKS-NK',
          holdable: 'true',
          reserveCollectionID: '',
        },
        {
          catkey: '0',
          libraryID: 'ABINGTON',
          locationID: 'CHECKEDOUT',
          holdable: 'true',
          reserveCollectionID: '',
        },
      ],
    ];

    availability.availabilityDisplay(allHoldingsMock, summaryHoldingsMock);

    const noRecallsButton = document.querySelector('.no-recalls-button');
    const holdButton = document.querySelector('.hold-button');

    expect(holdButton.classList.contains('d-none')).toBe(true);
    expect(holdButton.classList.contains('d-md-inline')).toBe(false);
    expect(noRecallsButton.classList.contains('d-none')).toBe(false);
    expect(noRecallsButton.classList.contains('d-md-inline')).toBe(true);
  });
});

describe('when a holdable record is only in a non holdable location', () => {
  test('I Want It directs to ILLiad placement', () => {
    const allHoldingsMock = [
      [
        {
          catkey: '0',
          libraryID: 'ABINGTON',
          locationID: 'CHECKEDOUT',
          holdable: 'true',
          reserveCollectionID: '',
        },
      ],
    ];

    availability.availabilityDisplay(allHoldingsMock, summaryHoldingsMock);

    const noRecallsButton = document.querySelector('.no-recalls-button');
    const holdButton = document.querySelector('.hold-button');

    expect(holdButton.classList.contains('d-none')).toBe(true);
    expect(holdButton.classList.contains('d-md-inline')).toBe(false);
    expect(noRecallsButton.classList.contains('d-none')).toBe(false);
    expect(noRecallsButton.classList.contains('d-md-inline')).toBe(true);
  });
});

describe('when a holdable record is in a holdable location', () => {
  test('I Want It directs to Symphony placement', () => {
    const allHoldingsMock = [
      [
        {
          catkey: '0',
          libraryID: 'YORK',
          locationID: 'STACKS-YK',
          holdable: 'true',
          reserveCollectionID: '',
        },
      ],
    ];

    availability.availabilityDisplay(allHoldingsMock, summaryHoldingsMock);

    const noRecallsButton = document.querySelector('.no-recalls-button');
    const holdButton = document.querySelector('.hold-button');

    expect(holdButton.classList.contains('d-none')).toBe(false);
    expect(holdButton.classList.contains('d-md-inline')).toBe(true);
    expect(noRecallsButton.classList.contains('d-none')).toBe(true);
    expect(noRecallsButton.classList.contains('d-md-inline')).toBe(false);
  });
});

describe('when a record is not holdable', () => {
  test('I Want It is not rendered', () => {
    const allHoldingsMock = [
      [
        {
          catkey: '0',
          libraryID: 'ABINGTON',
          locationID: 'STACKS-AB',
          holdable: 'false',
          reserveCollectionID: '',
        },
      ],
    ];

    availability.availabilityDisplay(allHoldingsMock, summaryHoldingsMock);

    const noRecallsButton = document.querySelector('.no-recalls-button');
    const holdButton = document.querySelector('.hold-button');

    expect(holdButton.classList.contains('d-none')).toBe(true);
    expect(holdButton.classList.contains('d-md-inline')).toBe(false);
    expect(noRecallsButton.classList.contains('d-none')).toBe(true);
    expect(noRecallsButton.classList.contains('d-md-inline')).toBe(false);
  });
});
