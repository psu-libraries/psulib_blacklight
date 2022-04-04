import { render, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import Availability from '../../../../app/javascript/availability/components/availability';

describe('when the record has less than 5 holdings', () => {
  const structuredHoldings = [
    {
      summary: {},
      holdings: [
        { catkey: 1, callNumber: 'CallNum1' },
        { catkey: 2, callNumber: 'CallNum2' },
        { catkey: 3, callNumber: 'CallNum3' },
        { catkey: 4, callNumber: 'CallNum4' },
      ],
    },
  ];

  test('does not show the view more button', () => {
    const { queryByRole } = render(
      <Availability structuredHoldings={structuredHoldings} />
    );

    expect(queryByRole('button')).toBeNull();
  });
});

describe('when the record has 5 or more holdings', () => {
  const structuredHoldings = [
    {
      summary: {},
      holdings: [
        { catkey: 1, callNumber: 'CallNum1' },
        { catkey: 2, callNumber: 'CallNum2' },
        { catkey: 3, callNumber: 'CallNum3' },
        { catkey: 4, callNumber: 'CallNum4' },
        { catkey: 5, callNumber: 'CallNum5' },
      ],
    },
  ];

  test('shows the view more button', () => {
    const { getByRole } = render(
      <Availability structuredHoldings={structuredHoldings} />
    );

    expect(getByRole('button')).toHaveTextContent('View More');
  });

  test('expands the visible holdings + hides the View More button when it is clicked', () => {
    const { getByRole, getByText, queryByText, queryByRole, queryAllByRole } =
      render(<Availability structuredHoldings={structuredHoldings} />);

    expect(queryAllByRole('row')).toHaveLength(5);
    expect(queryByText('More Holdings')).toBeNull();
    expect(queryByText('CallNum5')).toBeNull();

    fireEvent.click(getByRole('button'));

    expect(queryByRole('button')).toBeNull();
    expect(queryAllByRole('row')).toHaveLength(7);
    expect(getByText('More Holdings')).toBeInTheDocument();
    expect(getByText('CallNum5')).toBeInTheDocument();
  });
});

describe('when the record has summary holdings', () => {
  test('shows the summmary holdings info', () => {
    const structuredHoldings = [
      {
        summary: { libraryID: 'UP-PAT' },
        holdings: [
          { catkey: 1, callNumber: 'CallNum1' },
          { catkey: 2, callNumber: 'CallNum2' },
          { catkey: 3, callNumber: 'CallNum3' },
          { catkey: 4, callNumber: 'CallNum4' },
        ],
      },
    ];

    const summaryHoldings = {
      'UP-PAT': {
        'PATTEE-3': [
          {
            call_number: 'PR9400 .M43',
            summary: ['v.67:no.3(2008)-To Date.'],
            supplement: ['supplemental info'],
            index: ['index info'],
          },
        ],
      },
    };

    const { getAllByRole } = render(
      <Availability
        structuredHoldings={structuredHoldings}
        summaryHoldings={summaryHoldings}
      />
    );

    const headings = getAllByRole('heading', { level: 6 });
    expect(headings[0]).toHaveTextContent(
      'Pattee - Stacks 3: Holdings Summary'
    );
  });
});
