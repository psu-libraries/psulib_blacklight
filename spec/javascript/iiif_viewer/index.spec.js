const mockViewer = jest.fn();

jest.mock('mirador', () => ({ viewer: mockViewer }));

describe('IIIF viewer', () => {
  let originalFetch;

  const loadViewer = () => {
    jest.isolateModules(() => {
      require('../../../app/javascript/iiif_viewer');
    });
  };

  beforeEach(() => {
    originalFetch = window.fetch;
    mockViewer.mockClear();
    document.body.innerHTML =
      '<div id="iiif-viewer" data-manifest=' +
      '\'["https://example.org/manifest.json"]\'></div>';
  });

  afterEach(() => {
    window.fetch = originalFetch;
    document.body.innerHTML = '';
  });

  it('upgrades HTTP requests made after the viewer is initialized', () => {
    const fetch = jest.fn();
    const options = { headers: { Accept: 'application/json' } };
    window.fetch = fetch;

    loadViewer();
    window.fetch('http://example.org/manifest.json', options);

    expect(fetch).toHaveBeenCalledWith(
      'https://example.org/manifest.json',
      options,
    );
  });

  it('does not override HTTPS and non-string fetch inputs', () => {
    const fetch = jest.fn();
    const request = { url: 'http://example.org/manifest.json' };
    window.fetch = fetch;

    loadViewer();
    window.fetch('https://example.org/manifest.json');
    window.fetch(request);

    expect(fetch).toHaveBeenNthCalledWith(
      1,
      'https://example.org/manifest.json',
      undefined,
    );
    expect(fetch).toHaveBeenNthCalledWith(2, request, undefined);
  });

  it('does not override fetch when the viewer container is absent', () => {
    const fetch = jest.fn();
    window.fetch = fetch;
    document.body.innerHTML = '';

    loadViewer();

    expect(window.fetch).toBe(fetch);
    expect(mockViewer).not.toHaveBeenCalled();
  });
});
