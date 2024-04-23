import googlePreview from './google_preview';
import hathiLink from './hathi_link';

async function hathiGoogleLinks() {
  // Wait for hathiLink function to finish before
  // determining if google should be checked
  hathiLink();
  if ($('#hathi-link:visible').length === 0) {
    googlePreview();
  }
}

$(document).ready(() => {
  hathiGoogleLinks();
});
