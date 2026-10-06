import { viewer } from 'mirador';

const viewerContainer = document.getElementById('iiif-viewer');

if (viewerContainer) {
  const originalFetch = window.fetch.bind(window);

  // This affects all later string-based fetches on this page, not just Mirador requests.
  // It handles HTTP URLs returned by multi-manifest requests until those URLs can be
  // corrected at the source; remove this override when that becomes possible.
  window.fetch = (input, options) => {
    if (typeof input !== 'string' || !input.startsWith('http:')) {
      return originalFetch(input, options);
    }

    return originalFetch(input.replace(/^http:/, 'https:'), options);
  };

  const manifestURLs = JSON.parse(
    viewerContainer.getAttribute('data-manifest'),
  );
  const multipleManifests = manifestURLs.length > 1;

  const config = {
    id: 'iiif-viewer',
    window: {
      allowClose: false,
      allowMaximize: multipleManifests,
      allowFullscreen: true,
    },
    windows: manifestURLs.map((url) => ({
      manifestId: url,
    })),
    workspace: {
      showZoomControls: true,
      type: multipleManifests ? 'mosaic' : 'single',
    },
    workspaceControlPanel: {
      enabled: false,
    },
    theme: {
      palette: {
        primary: {
          main: '#428bca',
        },
      },
    },
  };

  viewer(config);
}
