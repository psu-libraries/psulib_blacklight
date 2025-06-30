import 'bootstrap/dist/js/bootstrap.bundle';
import * as bootstrap from 'bootstrap';

document.addEventListener('DOMContentLoaded', () => {
  initBootstrapDropdowns();

  if (typeof Blacklight !== 'undefined') {
    Blacklight.onLoad();
  }
});

function initBootstrapDropdowns() {
  const dropdowns = [].slice.call(
    document.querySelectorAll('.dropdown-toggle'),
  );
  dropdowns.forEach((toggle) => {
    toggle.DropdownInstance = bootstrap.Dropdown(toggle, {
      autoClose: true,
    });
  });

  document.addEventListener('shown.bs.modal', (event) => {
    const modal = event.target;
    const dropdownsQuery = modal.querySelectorAll('.dropdown-toggle');
    dropdownsQuery.forEach((toggle) => {
      toggle.DropdownInstance = bootstrap.Dropdown(toggle);
    });
  });
}
