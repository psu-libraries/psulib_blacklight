import { render, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import ViewMoreButton from '../../../../app/javascript/availability/components/view_more_button';

test('calls the onClick handler when the button is clicked', () => {
  const onClickSpy = jest.fn();
  const { getByRole } = render(<ViewMoreButton onClick={onClickSpy} />);

  fireEvent.click(getByRole('button'));

  expect(onClickSpy).toHaveBeenCalled();
});
