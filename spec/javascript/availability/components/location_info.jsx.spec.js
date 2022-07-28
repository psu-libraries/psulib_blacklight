import { render } from '@testing-library/react';
import '@testing-library/jest-dom';
import LocationInfo from '../../../../app/javascript/availability/components/location_info';

describe('when the item is not related to ILL or AEON', () => {
  test('renders an ILL link', () => {
    const holdingData = { libraryID: 'BEAVER', locationID: 'DISPLAY-BR' };
    const { getByText } = render(<LocationInfo holding={holdingData} />);

    expect(getByText('Beaver - Display')).toBeInTheDocument();
  });
});
