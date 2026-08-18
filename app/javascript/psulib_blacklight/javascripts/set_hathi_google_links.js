import setGooglePreview from './set_google_preview_link';
import setHathiLink from './set_hathi_link';

async function setHathiGoogleLinks() {
  // Wait for hathiLink function to finish before
  // determining if google should be checked
  setHathiLink();
  if ($('#hathi-link:visible').length === 0) {
    setGooglePreview();
  }
}

$(document).ready(() => {
  setHathiGoogleLinks();
});
