import $ from 'jquery';
import 'select2';
import 'select2/dist/css/select2.min.css';

$(document).ready(() => {
  const advancedSearchPage = document.getElementsByClassName(
    'advanced-search-form',
  );
  // Check to see if we are in the advanced search page
  if (advancedSearchPage.length > 0) {
    // Set ARIA attribute for "op" dropdown
    const opSelect = document.getElementById('op');
    opSelect.setAttribute('aria-haspopup', 'listbox');
    // Set ARIA attribute for "sort" dropdown
    const sortSelect = document.getElementById('sort');
    sortSelect.setAttribute('role', 'listbox');
    // Set ARIA label and multiselect for multiselect drop downs
    const multiDropDowns = document.querySelectorAll('[multiple="multiple"]');
    for (let i = 0; i < multiDropDowns.length; i += 1) {
      const label = multiDropDowns[i].parentElement.parentElement
        .querySelectorAll('label')[0]
        .textContent.trim();
      multiDropDowns[i].setAttribute('aria-label', label);
      multiDropDowns[i].setAttribute('aria-multiselectable', 'true');
    }
  }
});

$(document).ready(() => {
  $('.js-example-basic-multiple').select2();
});

$('.js-example-basic-multiple').select2({
  placeholder: 'Select options...',
  width: '100%', // Important!
});

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.select2-search__field').forEach((el) => {
    el.style.width = '8em';
    el.style.minWidth = '8em';
    el.style.lineHeight = '1.5';
  });
});
