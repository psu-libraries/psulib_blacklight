import { render } from '@testing-library/react';
import '@testing-library/jest-dom';
import MapScanLink from '../../../../app/javascript/availability/components/map_scan_link';
import availability from '../../../../app/javascript/availability/index';

describe('when the item is not at an eligible library', () => {
  test('does not render the component', () => {
    const holdingData = { libraryID: 'GREATVLY', itemTypeID: 'MAP' };
    const { container } = render(<MapScanLink holding={holdingData} />);

    expect(container).toBeEmptyDOMElement();
  });
});

describe('when the item is not an eligible map type', () => {
  test('does not render the component', () => {
    const holdingData = { libraryID: 'UP-MAPS', itemTypeID: 'BOOK' };
    const { container } = render(<MapScanLink holding={holdingData} />);

    expect(container).toBeEmptyDOMElement();
  });
});

describe('when the item is an eligible map type and at an eligible library', () => {
  test('renders the component with the correct link', () => {
    const holdingData = { libraryID: 'UP-MAPS', itemTypeID: 'MAP' };
    const { getByRole } = render(<MapScanLink holding={holdingData} />);
    const link = getByRole('link');

    expect(link).toHaveTextContent('Request scan');
    expect(link).toHaveAttribute('href', availability.mapScanUrl);
  });
});
