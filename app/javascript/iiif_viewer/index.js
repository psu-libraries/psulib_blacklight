import Mirador from 'mirador/dist/es/src/index';

const viewerContainer = document.getElementById('iiif-viewer');

if (viewerContainer) {
  const config = {
    id: 'iiif-viewer',
    window: {
      allowClose: false,
      allowMaximize: false,
      allowFullscreen: true,
    },
    windows: [
      {
        manifestId: viewerContainer.getAttribute('data-manifest'),
      },
    ],
    workspace: {
      showZoomControls: true,
      type: 'mosiac',
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

  Mirador.viewer(config);
}
