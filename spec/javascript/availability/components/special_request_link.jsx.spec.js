import { render, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import SpecialRequestLink from '../../../../app/javascript/availability/components/special_request_link';
import availability from '../../../../app/javascript/availability';

describe('when locationText is sent to SpecialRequestLink', () => {
  const baseUrl = 'https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30';
  const holdingData = {
    locationID: 'BINDERY',
    callNumber: '123',
    catkey: '456',
    itemID: 'item ID',
    itemTypeID: 'BOOK',
  };

  const testLink = async (getByRole, container, label, href) => {
    expect(getByRole('link')).toHaveAttribute('href', '#');
    expect(container.getElementsByClassName('spinner-border').length).toBe(1);

    await waitFor(() =>
      expect(container.getElementsByClassName('spinner-border').length).toBe(0)
    );

    expect(getByRole('link')).toHaveTextContent(label);
    expect(getByRole('link')).toHaveAttribute('href', href);
  };

  describe('when all fields are present', () => {
    const moreParams =
      '&Location=item%20location&ItemNumber=item%20ID&CallNumber=123' +
      '&ItemTitle=book%20title&ItemAuthor=author%20name&ItemEdition=1&ItemPublisher=' +
      'publisher%20name&ItemPlace=pub%20place&ItemDate=2021&ItemInfo1=restrictions' +
      '&SubLocation=sublocation%201%3B%20sublocation%202';

    beforeEach(() => {
      global.fetch = jest.fn(() =>
        Promise.resolve({
          json: () =>
            Promise.resolve({
              title_245ab_tsim: 'book title',
              author_tsim: 'author name',
              pub_date_illiad_ssm: 2021,
              isbn_ssm: '1234',
              edition_display_ssm: '1',
              publisher_name_ssm: 'publisher name',
              publication_place_ssm: 'pub place',
              restrictions_access_note_ssm: 'restrictions',
              sublocation_ssm: ['sublocation 1', 'sublocation 2'],
            }),
        })
      );
    });

    test('renders an Aeon link', async () => {
      const { getByRole, container } = render(
        <SpecialRequestLink
          holding={holdingData}
          locationText="item location"
        />
      );

      const href = `${baseUrl}&ReferenceNumber=456&Genre=BOOK${moreParams}`;

      await testLink(getByRole, container, 'Request Material', href);
    });

    test('renders an Aeon link for an archival thesis item', async () => {
      const { getByRole, container } = render(
        <SpecialRequestLink
          holding={{
            ...holdingData,
            itemTypeID: 'ARCHIVES',
            locationID: 'AH-X-TRANS',
          }}
          locationText="item location"
        />
      );

      const href = `${baseUrl}&ReferenceNumber=456&Genre=ARCHIVES${moreParams}`;

      await testLink(getByRole, container, 'View in Special Collections', href);
    });
  });

  test('renders an Aeon link with some fields missing', async () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () =>
          Promise.resolve({
            title_245ab_tsim: 'book title',
            isbn_ssm: '1234',
          }),
      })
    );

    const { getByRole, container } = render(
      <SpecialRequestLink holding={holdingData} locationText="item location" />
    );

    const href =
      `${baseUrl}&ReferenceNumber=456&Genre=BOOK&Location=item%20location` +
      '&ItemNumber=item%20ID&CallNumber=123' +
      '&ItemTitle=book%20title&ItemAuthor=&ItemEdition=&ItemPublisher=' +
      '&ItemPlace=&ItemDate=&ItemInfo1=&SubLocation=';

    await testLink(getByRole, container, 'Request Material', href);
  });

  test('renders a basic Aeon link if the response comes back with no data', async () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve({}),
      })
    );

    const { getByRole, container } = render(
      <SpecialRequestLink holding={holdingData} locationText="item location" />
    );

    await testLink(
      getByRole,
      container,
      'Use Aeon to request this item',
      'https://aeon.libraries.psu.edu/RemoteAuth/aeon.dll'
    );

    expect(getByRole('link')).toHaveAttribute('target', '_blank');
  });

  test('renders a basic Aeon link if the AJAX request fails', async () => {
    global.fetch = jest.fn(() => Promise.reject());

    const { getByRole, container } = render(
      <SpecialRequestLink holding={holdingData} locationText="item location" />
    );

    await testLink(
      getByRole,
      container,
      'Use Aeon to request this item',
      'https://aeon.libraries.psu.edu/RemoteAuth/aeon.dll'
    );

    expect(getByRole('link')).toHaveAttribute('target', '_blank');
  });
});

describe('when locationText is not sent to SpecialRequestLink', () => {
  const baseUrl =
    'https://psu-illiad-oclc-org.ezaccess.libraries.psu.edu/illiad/upm/illiad.dll/' +
    'OpenURL?Action=10';
  const holdingData = { locationID: 'BINDERY', callNumber: '123' };

  const testLink = async (getByRole, container, label, href) => {
    expect(getByRole('link')).toHaveAttribute('href', '#');
    expect(container.getElementsByClassName('spinner-border').length).toBe(1);

    await waitFor(() =>
      expect(container.getElementsByClassName('spinner-border').length).toBe(0)
    );

    expect(getByRole('link')).toHaveTextContent(label);
    expect(getByRole('link')).toHaveAttribute('href', href);
  };

  describe('when all fields are present', () => {
    const moreParams =
      '&title=book%20title&callno=123&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu' +
      '&aulast=author%20name&date=2021';

    beforeEach(() => {
      global.fetch = jest.fn(() =>
        Promise.resolve({
          json: () =>
            Promise.resolve({
              title_245ab_tsim: 'book title',
              author_tsim: 'author name',
              pub_date_illiad_ssm: 2021,
              isbn_valid_ssm: ['1234'],
            }),
        })
      );
    });

    test('renders an ILL link', async () => {
      const { getByRole, container } = render(
        <SpecialRequestLink holding={holdingData} />
      );

      const href = `${baseUrl}&Form=30&isbn=1234${moreParams}`;

      await testLink(
        getByRole,
        container,
        'Copy unavailable, request via Interlibrary Loan',
        href
      );
    });

    test('renders a reserves scan link', async () => {
      availability.reservesScanLocations = ['BINDERY'];

      const { getByRole, container } = render(
        <SpecialRequestLink holding={holdingData} />
      );

      const reservesScanParams =
        '&Form=30&isbn=1234&Genre=GenericRequestReserves&location=BINDERY';
      const href = baseUrl + reservesScanParams + moreParams;

      await testLink(
        getByRole,
        container,
        'Copy unavailable, request via Interlibrary Loan',
        href
      );

      availability.reservesScanLocations = [];
    });

    test('renders a non-ILL microform link', async () => {
      const { getByRole, container } = render(
        <SpecialRequestLink
          holding={{
            callNumber: '123',
            locationID: 'MFILM-NML',
            libraryID: 'UP-MICRO',
            itemTypeID: 'MICROFORM',
          }}
        />
      );

      const microformParams =
        '&Form=30&isbn=1234&Genre=GenericRequestMicroScan&location=MFILM-NML';
      const href = baseUrl + microformParams + moreParams;

      await testLink(
        getByRole,
        container,
        'Request Scan - Penn State Users',
        href
      );
    });

    test('renders an ILL microform link', async () => {
      const { getByRole, container } = render(
        <SpecialRequestLink
          holding={{
            callNumber: '123',
            locationID: 'ILL',
            libraryID: 'UP-MICRO',
            itemTypeID: 'MICROFORM',
          }}
        />
      );

      const microformParams = '&Form=30&isbn=1234';
      const href = baseUrl + microformParams + moreParams;

      await testLink(
        getByRole,
        container,
        'Copy unavailable, request via Interlibrary Loan',
        href
      );
    });

    test('renders an archival thesis link', async () => {
      const { getByRole, container } = render(
        <SpecialRequestLink
          holding={{ ...holdingData, locationID: 'ARKTHESES' }}
        />
      );

      const archivalThesisParams =
        '&Form=20&Genre=GenericRequestThesisDigitization';
      const href = baseUrl + archivalThesisParams + moreParams;

      await testLink(
        getByRole,
        container,
        'Request Scan - Penn State Users',
        href
      );
    });
  });

  describe('when no isbn_valid_ssm', () => {
    const moreParams =
      '&title=book%20title&callno=123&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu' +
      '&aulast=author%20name&date=2021';

    beforeEach(() => {
      global.fetch = jest.fn(() =>
        Promise.resolve({
          json: () =>
            Promise.resolve({
              title_245ab_tsim: 'book title',
              author_tsim: 'author name',
              pub_date_illiad_ssm: 2021
            }),
        })
      );
    });

    test('renders an ILL link', async () => {
      const { getByRole, container } = render(
        <SpecialRequestLink holding={holdingData} />
      );

      const href = `${baseUrl}&Form=30&isbn=${moreParams}`;

      await testLink(
        getByRole,
        container,
        'Copy unavailable, request via Interlibrary Loan',
        href
      );
    });
  });

  test('renders a link with no author info', async () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () =>
          Promise.resolve({
            title_245ab_tsim: 'book title',
            pub_date_illiad_ssm: 2021,
            isbn_valid_ssm: ['1234'],
          }),
      })
    );

    const { getByRole, container } = render(
      <SpecialRequestLink holding={holdingData} />
    );

    const href =
      `${baseUrl}&Form=30&isbn=1234&title=book%20title&callno=123` +
      '&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu&date=2021';

    await testLink(
      getByRole,
      container,
      'Copy unavailable, request via Interlibrary Loan',
      href
    );
  });

  test('renders a link with no publication date', async () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () =>
          Promise.resolve({
            title_245ab_tsim: 'book title',
            author_tsim: 'author name',
            isbn_valid_ssm: ['1234'],
          }),
      })
    );

    const { getByRole, container } = render(
      <SpecialRequestLink holding={holdingData} />
    );

    const href =
      `${baseUrl}&Form=30&isbn=1234&title=book%20title&callno=123` +
      '&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu&aulast=author%20name';

    await testLink(
      getByRole,
      container,
      'Copy unavailable, request via Interlibrary Loan',
      href
    );
  });

  test('renders a link with no ISBN', async () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () =>
          Promise.resolve({
            title_245ab_tsim: 'book title',
            author_tsim: 'author name',
            isbn_valid_ssm: [],
            pub_date_illiad_ssm: 2021,
          }),
      })
    );

    const { getByRole, container } = render(
      <SpecialRequestLink holding={holdingData} />
    );

    const href =
      `${baseUrl}&Form=30&isbn=&title=book%20title&callno=123` +
      '&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu&aulast=author%20name&date=2021';

    await testLink(
      getByRole,
      container,
      'Copy unavailable, request via Interlibrary Loan',
      href
    );
  });

  test('renders a basic ILL link the response comes back with no data', async () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve({}),
      })
    );

    const { getByRole, container } = render(
      <SpecialRequestLink holding={holdingData} />
    );

    await testLink(
      getByRole,
      container,
      'Use ILLiad to request this item',
      'https://psu-illiad-oclc-org.ezaccess.libraries.psu.edu/illiad/'
    );

    expect(getByRole('link')).toHaveAttribute('target', '_blank');
  });

  test('renders a basic ILL link if the AJAX request fails', async () => {
    global.fetch = jest.fn(() => Promise.reject());

    const { getByRole, container } = render(
      <SpecialRequestLink holding={holdingData} />
    );

    await testLink(
      getByRole,
      container,
      'Use ILLiad to request this item',
      'https://psu-illiad-oclc-org.ezaccess.libraries.psu.edu/illiad/'
    );

    expect(getByRole('link')).toHaveAttribute('target', '_blank');
  });
});
