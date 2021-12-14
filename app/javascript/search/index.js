const search = {
  /**
     * Updates the placeholder text in the main search form on initial page load
     * and whenever the search type dropdown changes
     */
  autoPlaceholder: () => {
    const searchType = document.getElementById('search_field');

    const updatePlaceholder = () => {
      if (!searchType || !searchType.options) {
        return;
      }

      const { placeholder } = searchType.options[searchType.selectedIndex].dataset;
      const q = document.getElementById('q');

      q.setAttribute('placeholder', placeholder);
    };

    $(() => {
      updatePlaceholder();
    });

    searchType.addEventListener('change', () => {
      updatePlaceholder();
    });
  },
};

export default search;
