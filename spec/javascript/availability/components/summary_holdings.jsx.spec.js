import {render} from '@testing-library/react';
import '@testing-library/jest-dom'
import SummaryHoldings from '../../../../app/javascript/availability/components/summary_holdings';

describe('when no summary holdings data is provided', () => {
  test('does not render the component', () => {
    const {container} = render(
      <SummaryHoldings summaryHoldings={null} />
    );

    expect(container).toBeEmptyDOMElement();
  });
});

describe('when all summary holdings arrays are populated', () => {
  test('renders summaries, indexes, and supplements', () => {
    const data = {
      'PATTEE-3': [
        {
          'call_number': 'PR9400 .M43',
          'summary': [
            'v.67:no.3(2008)-To Date.'
          ],
          'supplement': [
            'supplemental info'
          ],
          'index': [
            'index info'
          ]
        }
      ]
    };

    const {getAllByRole} = render(
      <SummaryHoldings summaryHoldings={data} />, {
        container: document.body.appendChild(document.createElement('tbody'))
      }
    );

    const items = getAllByRole('listitem');
    expect(items.length).toBe(5);
    expect(items[0]).toHaveTextContent('v.67:no.3(2008)-To Date.');
    expect(items[2]).toHaveTextContent('index info');
    expect(items[4]).toHaveTextContent('supplemental info');

    const headings = getAllByRole('heading', { level: 6 });
    expect(headings.length).toBe(3);
    expect(headings[0]).toHaveTextContent('Pattee - Stacks 3: Holdings Summary');
    expect(headings[1]).toHaveTextContent('Indexes');
    expect(headings[2]).toHaveTextContent('Supplements');
  });
});

describe('when some summary holdings data is not present', () => {
  test('renders only the applicable headers and list items', () => {
    const data = {
      'PATTEE-3': [
        {
          'call_number': 'PR9400 .M43',
          'summary': [
            'v.67:no.3(2008)-To Date.'
          ],
          'supplement': [],
          'index': []
        }
      ]
    };

    const {getAllByRole} = render(
      <SummaryHoldings summaryHoldings={data} />, {
        container: document.body.appendChild(document.createElement('tbody'))
      }
    );

    const items = getAllByRole('listitem');
    expect(items.length).toBe(1);
    expect(items[0]).toHaveTextContent('v.67:no.3(2008)-To Date.');

    const headings = getAllByRole('heading', { level: 6 });
    expect(headings.length).toBe(1);
    expect(headings[0]).toHaveTextContent('Pattee - Stacks 3: Holdings Summary');
  });
});
