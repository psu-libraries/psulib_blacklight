import { render } from '@testing-library/react';
import '@testing-library/jest-dom';
import CourseReserveDueDate from '../../../../app/javascript/availability/components/course_reserve_due_date';

describe('when the item does not have a reserve circulation rule', () => {
  test('does not render the component', () => {
    const holdingData = { dueDate: '2019-06-11T12:34' };
    const { container } = render(
      <CourseReserveDueDate holding={holdingData} />
    );

    expect(container).toBeEmptyDOMElement();
  });
});

describe('when the item does not have a due date', () => {
  test('does not render the component', () => {
    const holdingData = { reserveCirculationRule: '4WKRESIDNT' };
    const { container } = render(
      <CourseReserveDueDate holding={holdingData} />
    );

    expect(container).toBeEmptyDOMElement();
  });
});

describe('when the item is on course reserve', () => {
  test('renders the component with the correct due date and circulation rule', () => {
    const holdingData = {
      dueDate: '2019-06-11T12:34Z',
      reserveCirculationRule: '4WKRESIDNT',
    };
    const { getByText } = render(
      <CourseReserveDueDate holding={holdingData} />
    );

    expect(getByText('Due back at:')).toBeInTheDocument();
    expect(getByText('8:34 AM on 6/11/2019')).toBeInTheDocument();
    expect(
      getByText('Circulates for 28 days, Resident PA users')
    ).toBeInTheDocument();
  });
});
