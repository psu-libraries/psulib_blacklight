document.addEventListener('DOMContentLoaded', () => {
  const inputGroup = document.querySelector('.input-group');
  const searchFieldSelect = inputGroup?.querySelector('#search_field');

  if (inputGroup && searchFieldSelect) {
    // Check if the header already exists to avoid duplicates
    if (!inputGroup.querySelector('h2.sr-only')) {
      const header = document.createElement('h2');
      header.className = 'sr-only';
      header.textContent = 'Search Bar';

      // Insert the header before the search_field tag
      inputGroup.insertBefore(header, searchFieldSelect);
    }
  }
});
