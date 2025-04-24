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
      <Availability structuredHoldings={structuredHoldings} />,
    );

    expect(queryByRole('button')).toBeNull();
    expect(queryByText('Holdings 1 - 4')).toBeNull();
  });
});

describe('when the record has more than 5 but less than 1000 holdings', () => {
  const holdings = [];
  for (let i = 0; i < 200; i += 1) {
    holdings[i] = { catkey: `${i}`, callNumber: `CallNum${i}` };
  }
  const structuredHoldings = [
    {
      summary: {},
      holdings,
    },
  ];

  test('shows the view more button and accessibility controls', () => {
    const { getByRole, queryByText } = render(
      <Availability structuredHoldings={structuredHoldings} />,
    );

    expect(getByRole('button')).toHaveTextContent('View More');
    expect(queryByText('Holdings 1 - 4')).toBeInTheDocument();
  });

  describe('when the view more button is clicked', () => {
    test('expands visible holdings by 100 + updates a11y elements', () => {
      const { getByRole, getAllByRole, queryByText, queryAllByRole } = render(
        <Availability structuredHoldings={structuredHoldings} />,
      );

      expect(queryAllByRole('row')).toHaveLength(6);
      expect(queryByText('Holdings 5 - 104')).toBeNull();
      expect(queryByText('CallNum5')).toBeNull();

      fireEvent.click(getByRole('button'));

      expect(queryAllByRole('row')).toHaveLength(107);
      expect(queryByText('Holdings 5 - 104')).toBeInTheDocument();
      expect(queryByText('CallNum5')).toBeInTheDocument();

      const buttons = getAllByRole('button');
      expect(buttons).toHaveLength(3);
      expect(buttons[0]).toHaveTextContent('Next');
      expect(buttons[1]).toHaveTextContent('Previous');
      expect(buttons[2]).toHaveTextContent('View More');
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

    const { getByText } = render(
      <Availability
        structuredHoldings={structuredHoldings}
        summaryHoldings={summaryHoldings}
      />,
    );

    expect(
      getByText('Pattee - Stacks 3: Holdings Summary'),
    ).toBeInTheDocument();
  });

  describe('when the record has more than 1000 holdings', () => {
    const holdings = [];
    for (let i = 0; i < 1002; i += 1) {
      holdings[i] = { catkey: `${i}`, callNumber: `CallNum${i}` };
    }
    const structuredHoldings = [
      {
        summary: {},
        holdings,
      },
    ];

    describe('when the view more button is clicked', () => {
      test('expands visible holdings by 500 + updates a11y elements', () => {
        const { getByRole, getAllByRole, queryByText, queryAllByRole } = render(
          <Availability structuredHoldings={structuredHoldings} />,
        );

        expect(queryAllByRole('row')).toHaveLength(6);
        expect(queryByText('Holdings 5 - 504')).toBeNull();
        expect(queryByText('CallNum503')).toBeNull();

        fireEvent.click(getByRole('button'));

        expect(queryAllByRole('row')).toHaveLength(507);
        expect(queryByText('Holdings 5 - 504')).toBeInTheDocument();
        expect(queryByText('CallNum503')).toBeInTheDocument();

        const buttons = getAllByRole('button');
        expect(buttons).toHaveLength(3);
        expect(buttons[0]).toHaveTextContent('Next');
        expect(buttons[1]).toHaveTextContent('Previous');
        expect(buttons[2]).toHaveTextContent('View More');
      });
    });
  });
});
