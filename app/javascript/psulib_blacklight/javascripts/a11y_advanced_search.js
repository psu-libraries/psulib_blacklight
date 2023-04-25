$(document).ready(() => {
  const advancedSearchPage = document.getElementsByClassName(
    'advanced-search-form'
  );
  // Check to see if we are in the advanced search page
  if (advancedSearchPage.length > 0) {
    // Set ARIA attribute for "op" dropdown
    const opSelect = document.getElementById('op');
    opSelect.setAttribute('aria-haspopup', 'listbox');
    // Set ARIA attribute for "sort" dropdown
    const sortSelect = document.getElementById('sort');
    sortSelect.setAttribute('role', 'listbox');
  }
});
