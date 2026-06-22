import { viewer } from 'mirador';

const viewerContainer = document.getElementById('iiif-viewer');

if (viewerContainer) {
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
    windows: manifestURLs.map((url) => ({ manifestId: url })),
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
