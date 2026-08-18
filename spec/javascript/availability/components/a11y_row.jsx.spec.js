import { render, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import A11yRow from '../../../../app/javascript/availability/components/a11y_row';

describe('when the A11yRow is at index 0 and only the initial set of holdings are visible', () => {
  test('does not render navigation buttons', () => {
    const { queryByRole } = render(
      <table>
        <tbody>
          <A11yRow
            lastA11yIndex={0}
            holdingIndex={0}
            initialVisibleCount={4}
            pageSize={100}
            uniqueID="1"
            visibleHoldingsCount={4}
          />
        </tbody>
      </table>,
    );

    expect(queryByRole('button')).toBeNull();
  });
});

describe('when the A11yRow is at index 0 and there are more pages of holdings', () => {
  test('renders a next button but no previous button', () => {
    const { getByRole } = render(
      <table>
        <tbody>
          <A11yRow
            lastA11yIndex={0}
            holdingIndex={0}
            initialVisibleCount={4}
            pageSize={100}
            uniqueID="1"
            visibleHoldingsCount={75}
          />
        </tbody>
      </table>,
    );

    expect(getByRole('button')).toHaveTextContent('Next');
  });
});

describe('when the A11yRow is at index === initialVisibleCount and there are no more pages of holdings', () => {
  test('renders a previous button but no next button', () => {
    const { getByRole } = render(
      <table>
        <tbody>
          <A11yRow
            lastA11yIndex={4}
            holdingIndex={4}
            initialVisibleCount={4}
            pageSize={100}
            uniqueID="1"
            visibleHoldingsCount={75}
          />
        </tbody>
      </table>,
    );

    expect(getByRole('button')).toHaveTextContent('Previous');
  });
});

describe('when the A11yRow is at index === initialVisibleCount and there are more pages of holdings', () => {
  test('renders a previous button and a next button', () => {
    const { queryAllByRole } = render(
      <table>
        <tbody>
          <A11yRow
            lastA11yIndex={4}
            holdingIndex={4}
            initialVisibleCount={4}
            pageSize={100}
            uniqueID="1"
            visibleHoldingsCount={125}
          />
        </tbody>
      </table>,
    );

    const buttons = queryAllByRole('button');
    expect(buttons).toHaveLength(2);
    expect(buttons[0]).toHaveTextContent('Previous');
    expect(buttons[1]).toHaveTextContent('Next');
  });
});

describe('when the A11yRow is at the 3rd page of results', () => {
  test('renders a previous button', () => {
    const { getByRole } = render(
      <table>
        <tbody>
          <A11yRow
            lastA11yIndex={104}
            holdingIndex={104}
            initialVisibleCount={4}
            pageSize={100}
            uniqueID="1"
            visibleHoldingsCount={125}
          />
        </tbody>
      </table>,
    );

    expect(getByRole('button')).toHaveTextContent('Previous');
  });
});

describe('when the previous button is clicked', () => {
  test('focus moves to the previous A11yRow', () => {
    const { getByRole, getAllByRole } = render(
      <table>
        <tbody>
          <tr>
            <td id="a11y-1-0" tabIndex={-1}>
              A11yRow 0
            </td>
          </tr>
          <A11yRow
            lastA11yIndex={4}
            holdingIndex={4}
            initialVisibleCount={4}
            pageSize={100}
            uniqueID="1"
            visibleHoldingsCount={75}
          />
        </tbody>
      </table>,
    );

    const tableCells = getAllByRole('cell');

    expect(tableCells).toHaveLength(2);
    expect(tableCells[1]).toHaveFocus();

    fireEvent.click(getByRole('button'));

    expect(tableCells[0]).toHaveFocus();
  });
});

describe('when the next button is clicked', () => {
  test('focus moves to the next A11yRow', () => {
    const { getByRole, getAllByRole } = render(
      <table>
        <tbody>
          <A11yRow
            lastA11yIndex={0}
            holdingIndex={0}
            initialVisibleCount={4}
            pageSize={100}
            uniqueID="1"
            visibleHoldingsCount={75}
          />
          <tr>
            <td id="a11y-1-4" tabIndex={-1}>
              A11yRow 4
            </td>
          </tr>
        </tbody>
      </table>,
    );

    const tableCells = getAllByRole('cell');

    expect(tableCells).toHaveLength(2);
    expect(tableCells[1]).not.toHaveFocus();

    fireEvent.click(getByRole('button'));

    expect(tableCells[1]).toHaveFocus();
  });
});
