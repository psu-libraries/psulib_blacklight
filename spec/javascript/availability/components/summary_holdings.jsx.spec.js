import { render } from '@testing-library/react';
import '@testing-library/jest-dom';
import SummaryHoldings from '../../../../app/javascript/availability/components/summary_holdings';

describe('when no summary holdings data is provided', () => {
  test('does not render the component', () => {
    const { container } = render(<SummaryHoldings summaryHoldings={null} />);

    expect(container).toBeEmptyDOMElement();
  });
});

describe('when all summary holdings arrays are populated', () => {
  test('renders summaries, indexes, and supplements', () => {
    const data = {
      'PATTEE-3': [
        {
          call_number: 'PR9400 .M43',
          summary: ['v.67:no.3(2008)-To Date.'],
          supplement: ['supplemental info'],
          index: ['index info'],
        },
      ],
    };

    const { getAllByRole, getByText } = render(
      <SummaryHoldings summaryHoldings={data} />,
      {
        container: document.body.appendChild(document.createElement('tbody')),
      }
    );

    const items = getAllByRole('listitem');
    expect(items.length).toBe(5);
    expect(items[0]).toHaveTextContent('v.67:no.3(2008)-To Date.');
    expect(items[2]).toHaveTextContent('index info');
    expect(items[4]).toHaveTextContent('supplemental info');

    expect(
      getByText('Pattee - Stacks 3: Holdings Summary')
    ).toBeInTheDocument();
    expect(getByText('Indexes')).toBeInTheDocument();
    expect(getByText('Supplements')).toBeInTheDocument();
  });
});

describe('when some summary holdings data is not present', () => {
  test('renders only the applicable headers and list items', () => {
    const data = {
      'PATTEE-3': [
        {
          call_number: 'PR9400 .M43',
          summary: ['v.67:no.3(2008)-To Date.'],
          supplement: [],
          index: [],
        },
      ],
    };

    const { getAllByRole, getByText, queryByText } = render(
      <SummaryHoldings summaryHoldings={data} />,
      {
        container: document.body.appendChild(document.createElement('tbody')),
      }
    );

    const items = getAllByRole('listitem');
    expect(items.length).toBe(1);
    expect(items[0]).toHaveTextContent('v.67:no.3(2008)-To Date.');

    expect(
      getByText('Pattee - Stacks 3: Holdings Summary')
    ).toBeInTheDocument();
    expect(queryByText('Indexes')).toBeNull();
    expect(queryByText('Supplements')).toBeNull();
  });
});

describe('when multiple holding statements are present', () => {
  test('renders summaries, indexes, and supplements', () => {
    const data = {
      'PATTEE-3': [
        {
          call_number: 'PR9400 .M43',
          summary: ['summary1'],
          supplement: [],
          index: [],
        },
        {
          call_number: 'PR9400 .M44',
          summary: ['summary2'],
          supplement: ['supplemental info'],
          index: ['index info'],
        },
      ],
    };

    const { getAllByRole, getByText } = render(
      <SummaryHoldings summaryHoldings={data} />,
      {
        container: document.body.appendChild(document.createElement('tbody')),
      }
    );

    const items = getAllByRole('listitem');
    expect(items.length).toBe(8);
    expect(items[0]).toHaveTextContent('PR9400 .M43');
    expect(items[1]).toHaveTextContent('summary1');
    expect(items[2]).toHaveTextContent('PR9400 .M44');
    expect(items[3]).toHaveTextContent('summary2');
    expect(items[5]).toHaveTextContent('Indexes: index info');
    expect(items[7]).toHaveTextContent('Supplements: supplemental info');

    expect(
      getByText('Pattee - Stacks 3: Holdings Summary')
    ).toBeInTheDocument();
  });
});
