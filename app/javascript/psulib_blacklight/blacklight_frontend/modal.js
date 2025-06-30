// We keep all our data in Blacklight.modal object.
// Create lazily if someone else created first.
import Modal from 'bootstrap/js/dist/modal';

if (Blacklight.modal === undefined) {
  Blacklight.modal = {};
}

// a Bootstrap modal div that should be already on the page hidden
Blacklight.modal.modalSelector = '#blacklight-modal';

// Trigger selectors identify forms or hyperlinks that should open
// inside a modal dialog.
Blacklight.modal.triggerLinkSelector = 'a[data-blacklight-modal~=trigger]';
Blacklight.modal.triggerFormSelector = 'form[data-blacklight-modal~=trigger]';

// preserve selectors identify forms or hyperlinks that, if activated already
// inside a modal dialog, should have destinations remain inside the modal -- but
// won't trigger a modal if not already in one.
//
// No need to repeat selectors from trigger selectors, those will already
// be preserved. MUST be manually prefixed with the modal selector,
// so they only apply to things inside a modal.
Blacklight.modal.preserveLinkSelector = `${Blacklight.modal.modalSelector} a[data-blacklight-modal~=preserve]`;

Blacklight.modal.containerSelector = '[data-blacklight-modal~=container]';

Blacklight.modal.modalCloseSelector = '[data-blacklight-modal~=close]';

// Called on fatal failure of ajax load, function returns content
// to show to user in modal.  Right now called only for extreme
// network errors.
Blacklight.modal.onFailure = function (jqXHR, textStatus, errorThrown) {
  console.error('Server error:', this.url, jqXHR.status, errorThrown);

  const contents =
    `<div class="modal-header">` +
    `<div class="modal-title">There was a problem with your request.</div>` +
    `<button type="button" class="blacklight-modal-close btn-close close" data-dismiss="modal" aria-label="Close">` +
    `  <span aria-hidden="true">&times;</span>` +
    `</button></div>` +
    ` <div class="modal-body"><p>Expected a successful response from the server, but got an error</p>` +
    `<pre>${this.type} ${this.url}\n${jqXHR.status}: ${
      errorThrown
    }</pre></div>`;
  $(Blacklight.modal.modalSelector).find('.modal-content').html(contents);
  Blacklight.modal.show();
};

Blacklight.modal.receiveAjax = function (contents) {
  // does it have a data- selector for container?
  // important we don't execute script tags, we shouldn't.
  // code modelled off of JQuery ajax.load. https://github.com/jquery/jquery/blob/main/src/ajax/load.js?source=c#L62
  const container = $('<div>')
    .append(jQuery.parseHTML(contents))
    .find(Blacklight.modal.containerSelector)
    .first();
  if (container.length !== 0) {
    contents = container.html();
  }

  $(Blacklight.modal.modalSelector).find('.modal-content').html(contents);

  // send custom event with the modal dialog div as the target
  const e = $.Event('loaded.blacklight.blacklight-modal');
  $(Blacklight.modal.modalSelector).trigger(e);
  // if they did preventDefault, don't show the dialog
  if (e.isDefaultPrevented()) return;

  Blacklight.modal.show();
};

Blacklight.modal.modalAjaxLinkClick = function (e) {
  e.preventDefault();

  $.ajax({
    url: $(this).attr('href'),
  })
    .fail(Blacklight.modal.onFailure)
    .done(Blacklight.modal.receiveAjax);
};

Blacklight.modal.modalAjaxFormSubmit = function (e) {
  e.preventDefault();

  $.ajax({
    url: $(this).attr('action'),
    data: $(this).serialize(),
    type: $(this).attr('method'), // POST
  })
    .fail(Blacklight.modal.onFailure)
    .done(Blacklight.modal.receiveAjax);
};

Blacklight.modal.setupModal = function () {
  // Event indicating blacklight is setting up a modal link,
  // you can catch it and call e.preventDefault() to abort
  // setup.
  const e = $.Event('setup.blacklight.blacklight-modal');
  $('body').trigger(e);
  if (e.isDefaultPrevented()) return;

  // Register both trigger and preserve selectors in ONE event handler, combining
  // into one selector with a comma, so if something matches BOTH selectors, it
  // still only gets the event handler called once.
  $('body').on(
    'click',
    `${Blacklight.modal.triggerLinkSelector}, ${
      Blacklight.modal.preserveLinkSelector
    }`,
    Blacklight.modal.modalAjaxLinkClick,
  );
  $('body').on(
    'submit',
    `${Blacklight.modal.triggerFormSelector}, ${
      Blacklight.modal.preserveFormSelector
    }`,
    Blacklight.modal.modalAjaxFormSubmit,
  );

  // Catch our own custom loaded event to implement data-blacklight-modal=closed
  $('body').on(
    'loaded.blacklight.blacklight-modal',
    Blacklight.modal.checkCloseModal,
  );

  // we support doing data-dismiss=modal on a <a> with a href for non-ajax
  // use, we need to suppress following the a's href that's there for
  // non-JS contexts.
  $('body').on(
    'click',
    `${Blacklight.modal.modalSelector} a[data-dismiss~=modal]`,
    (el) => {
      el.preventDefault();
    },
  );
};

// A function used as an event handler on loaded.blacklight.blacklight-modal
// to catch contained data-blacklight-modal=closed directions
Blacklight.modal.checkCloseModal = function (event) {
  if ($(event.target).find(Blacklight.modal.modalCloseSelector).length) {
    const modalFlashes = $(this).find('.flash_messages');

    Blacklight.modal.hide(event.target);
    event.preventDefault();

    const mainFlashes = $('#main-flashes');
    mainFlashes.append(modalFlashes);
    modalFlashes.fadeIn(500);
  }
};

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

Blacklight.onLoad(() => {
  Blacklight.modal.setupModal();
});
