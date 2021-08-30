import {render, waitFor} from '@testing-library/react';
import '@testing-library/jest-dom'
import IllLink from '../../../../app/javascript/availability/components/ill_link';
import availability from '../../../../app/javascript/availability';

const baseUrl = 'https://psu-illiad-oclc-org.ezaccess.libraries.psu.edu/illiad/upm/illiad.dll/' +
                'OpenURL?Action=10';

const testLink = async (getByRole, container, label, href) => {
  expect(getByRole('link')).toHaveAttribute('href', '#');
  expect(container.getElementsByClassName('spinner-border').length).toBe(1);

  await waitFor(() => expect(container.getElementsByClassName('spinner-border').length).toBe(0));

  expect(getByRole('link')).toHaveTextContent(label);
  expect(getByRole('link')).toHaveAttribute('href', href);
};

describe('when all fields are present', () => {
  const moreParams = '&title=book%20title&callno=123&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu' +
                     '&aulast=author%20name&date=2021';

  beforeEach(() => {
    $.get = jest.fn().mockImplementation(() => {
      return Promise.resolve({
        title_245ab_tsim: 'book title',
        author_tsim: 'author name',
        pub_date_illiad_ssm: 2021,
        isbn_ssm: '1234'
      });
    });
  });

  test('renders an ILL link', async () => {
    const {getByRole, container} = render(
      <IllLink holding={{locationID: 'BINDERY', callNumber: '123'}} />
    );

    const href = baseUrl + '&Form=30&isbn=1234' + moreParams;

    await testLink(
      getByRole,
      container,
      'Copy unavailable, request via Interlibrary Loan',
      href
    );
  });
  
  test('renders a reserves scan link', async () => {
    availability.reservesScanLocations = ['BINDERY'];
  
    const {getByRole, container} = render(
      <IllLink holding={{locationID: 'BINDERY', callNumber: '123'}} />
    );

    const href = baseUrl + 
      '&Form=30&isbn=1234' +
      '&Genre=GenericRequestReserves&location=BINDERY' + // reserves scan params
      moreParams;

    await testLink(
      getByRole,
      container,
      'Copy unavailable, request via Interlibrary Loan',
      href
    );
  
    availability.reservesScanLocations = [];
  });
  
  test('renders a microform link', async () => {
    const {getByRole, container} = render(
      <IllLink holding={{locationID: 'BINDERY', callNumber: '123', libraryID: 'UP-MICRO', itemTypeID: 'MICROFORM'}} />
    );

    const href = baseUrl +
      '&Form=30&isbn=1234' +
      '&Genre=GenericRequestMicroScan&location=BINDERY' + // microform params
      moreParams;

    await testLink(
      getByRole,
      container,
      'Request Scan - Penn State Users',
      href
    );
  });
  
  test('renders an archival thesis link', async () => {
    const {getByRole, container} = render(
      <IllLink holding={{locationID: 'ARKTHESES', callNumber: '123'}} />
    );

    const href = baseUrl +
      '&Form=20&Genre=GenericRequestThesisDigitization' + // archival thesis params
      moreParams;

    await testLink(
      getByRole,
      container,
      'Request Scan - Penn State Users',
      href
    );
  });
});

test('renders a link with no author info', async () => {
  $.get = jest.fn().mockImplementation(() => {
    return Promise.resolve({
      title_245ab_tsim: 'book title',
      pub_date_illiad_ssm: 2021,
      isbn_ssm: '1234'
    });
  });

  const {getByRole, container} = render(
    <IllLink holding={{locationID: 'BINDERY', callNumber: '123'}} />
  );

  const href = baseUrl +
    '&Form=30&isbn=1234&title=book%20title&callno=123' +
    '&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu&date=2021';

    await testLink(
      getByRole,
      container,
      'Copy unavailable, request via Interlibrary Loan',
      href
    );
});

test('renders a link with no publication date', async () => {
  $.get = jest.fn().mockImplementation(() => {
    return Promise.resolve({
      title_245ab_tsim: 'book title',
      author_tsim: 'author name',
      isbn_ssm: '1234'
    });
  });

  const {getByRole, container} = render(
    <IllLink holding={{locationID: 'BINDERY', callNumber: '123'}} />
  );

  const href = baseUrl +
    '&Form=30&isbn=1234&title=book%20title&callno=123' +
    '&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu&aulast=author%20name';

  await testLink(
    getByRole,
    container,
    'Copy unavailable, request via Interlibrary Loan',
    href
  );
});

test('renders a link with no ISBN', async () => {
  $.get = jest.fn().mockImplementation(() => {
    return Promise.resolve({
      title_245ab_tsim: 'book title',
      author_tsim: 'author name',
      pub_date_illiad_ssm: 2021
    });
  });

  const {getByRole, container} = render(
    <IllLink holding={{locationID: 'BINDERY', callNumber: '123'}} />
  );

  const href = baseUrl +
    '&Form=30&isbn=&title=book%20title&callno=123' +
    '&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu&aulast=author%20name&date=2021';

  await testLink(
    getByRole,
    container,
    'Copy unavailable, request via Interlibrary Loan',
    href
  );
});

test.todo('renders a link when the response comes back with no data');
