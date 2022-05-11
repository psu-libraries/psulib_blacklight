import { render } from '@testing-library/react';
import '@testing-library/jest-dom';
import Snippet from '../../../../app/javascript/availability/components/snippet';

describe('when there are no copies of the item available', () => {
  test('does not render the component', () => {
    const data = [
      {
        holdings: [
          {
            totalCopiesAvailable: 0,
          },
        ],
      },
    ];
    const { container } = render(<Snippet data={data} />);

    expect(container).toBeEmptyDOMElement();
  });
});

describe('when there are copies of the item available', () => {
  describe('when there are more than 2 locations', () => {
    test('renders the component with the correct text', () => {
      const data = [
        {
          holdings: [
            {
              totalCopiesAvailable: 1,
            },
          ],
        },
        {
          holdings: [
            {
              totalCopiesAvailable: 1,
            },
          ],
        },
        {
          holdings: [
            {
              totalCopiesAvailable: 1,
            },
          ],
        },
      ];

      const { getByText } = render(<Snippet data={data} />);

      expect(getByText('Multiple Locations')).toBeInTheDocument();
    });
  });

  describe('when there are 2 or fewer locations', () => {
    test('renders the component with the correct text', () => {
      const data = [
        {
          holdings: [
            {
              totalCopiesAvailable: 1,
            },
          ],
          summary: {
            library: 'Library 1',
          },
        },
        {
          holdings: [
            {
              totalCopiesAvailable: 1,
            },
          ],
          summary: {
            library: 'Library 2',
          },
        },
      ];

      const { getByText } = render(<Snippet data={data} />);

      expect(getByText('Library 1, Library 2')).toBeInTheDocument();
    });
  });

  describe('when one of the locations is ON-ORDER', () => {
    const data = [
      {
        holdings: [
          {
            totalCopiesAvailable: 1,
          },
        ],
        summary: {
          library: 'Library 1',
        },
      },
      {
        holdings: [
          {
            totalCopiesAvailable: 1,
          },
        ],
        summary: {
          library: 'ON-ORDER',
        },
      },
    ];

    const { getByText } = render(<Snippet data={data} />);

    expect(getByText('Library 1')).toBeInTheDocument();
  });
});
