import { googlePreview } from "./google_preview";
import { hathilink } from "./hathilink";

async function hathi_google_links() {
  // Wait for hathilink function to finish before 
  // determining if google should be checked
  await hathilink()
  if ($("#hathilink:visible").length == 0) {
    googlePreview()
  }
}

$(document).ready(() => {
  hathi_google_links();
});
