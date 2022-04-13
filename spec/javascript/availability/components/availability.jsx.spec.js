import { render, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import Availability from '../../../../app/javascript/availability/components/availability';

describe('when the record has less than 5 holdings', () => {
  const structuredHoldings = [
    {
      summary: {},
      holdings: [
        { catkey: '1', callNumber: 'CallNum1' },
        { catkey: '2', callNumber: 'CallNum2' },
        { catkey: '3', callNumber: 'CallNum3' },
        { catkey: '4', callNumber: 'CallNum4' },
      ],
    },
  ];

  test('does not show the view more button or accessibility controls', () => {
    const { queryByRole, queryByText } = render(
      <Availability structuredHoldings={structuredHoldings} />
    );

    expect(queryByRole('button')).toBeNull();
    expect(queryByText('Holdings 1 - 4')).toBeNull();
  });
});

describe('when the record has 5 or more holdings', () => {
  const structuredHoldings = [
    {
      summary: {},
      holdings: [
        { catkey: '1', callNumber: 'CallNum1' },
        { catkey: '2', callNumber: 'CallNum2' },
        { catkey: '3', callNumber: 'CallNum3' },
        { catkey: '4', callNumber: 'CallNum4' },
        { catkey: '5', callNumber: 'CallNum5' },
      ],
    },
  ];

  test('shows the view more button and accessibility controls', () => {
    const { getByRole, queryByText } = render(
      <Availability structuredHoldings={structuredHoldings} />
    );

    expect(getByRole('button')).toHaveTextContent('View More');
    expect(queryByText('Holdings 1 - 4')).toBeInTheDocument();
  });

  describe('when the view more button is clicked', () => {
    test('expands visible holdings + updates a11y elements', () => {
      const { getByRole, getAllByRole, queryByText, queryAllByRole } = render(
        <Availability structuredHoldings={structuredHoldings} />
      );

      expect(queryAllByRole('row')).toHaveLength(6);
      expect(queryByText('Holdings 5 - 5')).toBeNull();
      expect(queryByText('CallNum5')).toBeNull();

      fireEvent.click(getByRole('button'));

      expect(queryAllByRole('row')).toHaveLength(8);
      expect(queryByText('Holdings 5 - 5')).toBeInTheDocument();
      expect(queryByText('CallNum5')).toBeInTheDocument();

      const buttons = getAllByRole('button');
      expect(buttons).toHaveLength(2);
      expect(buttons[0]).toHaveTextContent('Next');
      expect(buttons[1]).toHaveTextContent('Previous');
    });
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
