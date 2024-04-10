import { googlePreview } from "./google_preview";
import { hathilink } from "./hathilink";

$(document).ready(() => {
  if (hathilink()) {
    return 'Hathilink Shown'
  } else {
    googlePreview();
  }
});