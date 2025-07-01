/* A JQuery plugin (should this be implemented as a widget instead? not sure)
   that will convert a "toggle" form, with single submit button to add/remove
   something, like used for Bookmarks, into an AJAXy checkbox instead.

   Apply to a form. Does require certain assumption about the form:
    1) The same form 'action' href must be used for both ADD and REMOVE
       actions, with the different being the hidden input name="_method"
       being set to "put" or "delete" -- that's the Rails method to pretend
       to be doing a certain HTTP verb. So same URL, PUT to add, DELETE
       to remove. This plugin assumes that.

       Plus, the form this is applied to should provide a data-doc-id
       attribute (HTML5-style doc-*) that contains the id/primary key
       of the object in question -- used by plugin for a unique value for
       DOM id's.

  Uses HTML for a checkbox compatible with Bootstrap 3.

   Pass in options for your class name and labels:
   $("form.something").blCheckboxSubmit({
        //cssClass is added to elements added, plus used for id base
        cssClass: "toggle_my_kinda_form",
        error: function() {
          #optional callback
        },
        success: function(after_success_check_state) {
          #optional callback
        }
   });
*/
(function ($) {
  $.fn.blCheckboxSubmit = function (argOpts) {
    this.each(function () {
      const options = $.extend({}, $.fn.blCheckboxSubmit.defaults, argOpts);

      const form = $(this);
      form.children().hide();
      // We're going to use the existing form to actually send our add/removes
      // This works conveniently because the exact same action href is used
      // for both bookmarks/$doc_id.  But let's take out the irrelevant parts
      // of the form to avoid any future confusion.
      form.find('input[type=submit]').remove();

      // View needs to set data-doc-id so we know a unique value
      // for making DOM id
      const uniqueId = form.attr('data-doc-id') || Math.random();
      // if form is currently using method delete to change state,
      // then checkbox is currently checked
      const checked =
        form.find('input[name=_method][value=delete]').length !== 0;

      const checkbox = $('<input type="checkbox">')
        .addClass(options.cssClass)
        .attr('id', `${options.cssClass}_${uniqueId}`);
      const label = $('<label>')
        .addClass(options.cssClass)
        .attr('for', `${options.cssClass}_${uniqueId}`)
        .attr('title', form.attr('title') || '');
      const span = $('<span>').addClass('btn btn-info btn-sm'); // The only piece that was changed
      label.append(checkbox);
      label.append(' ');
      label.append(span);

      const checkboxDiv = $('<div class="checkbox" />')
        .addClass(options.cssClass)
        .append(label);

      const title = form.attr('aria-label');
      function updateStateFor(state) {
        checkbox.prop('checked', state);
        label.toggleClass('checked', state);

        if (state) {
          // Set the Rails hidden field that fakes an HTTP verb
          // properly for current state action.
          form.attr('aria-label', `In bookmarks: ${title}`);
          form.find('input[name=_method]').val('delete');
          span.text(form.attr('data-present'));
        } else {
          form.attr('aria-label', `Bookmark: ${title}`);
          form.find('input[name=_method]').val('put');
          span.text(form.attr('data-absent'));
        }
      }

      form.append(checkboxDiv);
      updateStateFor(checked);

      checkbox.click(() => {
        span.text(form.attr('data-inprogress'));
        label.attr('disabled', 'disabled');
        checkbox.attr('disabled', 'disabled');

        $.ajax({
          url: form.attr('action'),
          dataType: 'json',
          type: form.attr('method').toUpperCase(),
          data: form.serialize(),
          error() {
            label.removeAttr('disabled');
            checkbox.removeAttr('disabled');
            options.error.call();
          },
          success(data, status, xhr) {
            // if app isn't running at all, xhr annoyingly
            // reports success with status 0.
            if (xhr.status !== 0) {
              // Re-evaluate checked since it could have changed from BookmarkAll code
              const toggledChecked =
                form.find('input[name=_method][value=delete]').length === 0;
              updateStateFor(toggledChecked);
              label.removeAttr('disabled');
              checkbox.removeAttr('disabled');
              options.success.call(form, checked, xhr.responseJSON);
            } else {
              label.removeAttr('disabled');
              checkbox.removeAttr('disabled');
              options.error.call();
            }
          },
        });

        return false;
      }); // checkbox.click
    }); // this.each
    return this;
  };

  $.fn.blCheckboxSubmit.defaults = {
    // cssClass is added to elements added, plus used for id base
    cssClass: 'blCheckboxSubmit',
    error() {
      alert('Error');
    },
    success() {}, // callback
  };
})(jQuery);
