import { render, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import AeonLink from '../../../../app/javascript/availability/components/aeon_link';

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
      <AeonLink holding={holdingData} locationText="item location" />
    );

    const href = `${baseUrl}&ReferenceNumber=456&Genre=BOOK${moreParams}`;

    await testLink(getByRole, container, 'Request Material', href);
  });

  test('renders an Aeon link for an archival thesis item', async () => {
    const { getByRole, container } = render(
      <AeonLink
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
    <AeonLink holding={holdingData} locationText="item location" />
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

  const { getByRole, container } = render(<AeonLink holding={holdingData} />);

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

  const { getByRole, container } = render(<AeonLink holding={holdingData} />);

  await testLink(
    getByRole,
    container,
    'Use Aeon to request this item',
    'https://aeon.libraries.psu.edu/RemoteAuth/aeon.dll'
  );

  expect(getByRole('link')).toHaveAttribute('target', '_blank');
});
