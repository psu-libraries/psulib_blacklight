// This override forces Blacklight to use Bootstrap 5's modal.
// Future upgrades of Blacklight or Bootstrap may affect this.
import Modal from 'bootstrap/js/dist/modal';

Blacklight.modal.hide = function (el) {
  Modal.getOrCreateInstance(
    el || document.querySelector(Blacklight.modal.modalSelector),
  ).hide();
};

Blacklight.modal.show = function (el) {
  Modal.getOrCreateInstance(
    el || document.querySelector(Blacklight.modal.modalSelector),
  ).show();
};
