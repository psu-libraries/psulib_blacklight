export default class CheckboxSubmitAll {
  constructor(forms) {
    this.forms = forms;
  }

  async clicked() {
    for (let i = 0; i < this.forms.length; i += 1) {
      if (!this.checked(i)) {
        this.forms[i].querySelector('span').innerHTML =
          this.forms[i].getAttribute('data-inprogress');
        this.forms[i]
          .querySelector('label')
          .setAttribute('disabled', 'disabled');
        this.forms[i]
          .querySelector("input[id^='toggle-bookmark_']")
          .setAttribute('disabled', 'disabled');
        /* eslint-disable no-await-in-loop */
        const response = await fetch(this.forms[i].getAttribute('action'), {
          body: new FormData(this.forms[i]),
          method: this.forms[i].getAttribute('method').toUpperCase(),
          headers: {
            Accept: 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': document.querySelector('meta[name=csrf-token]')
              ?.content,
          },
        });
        this.forms[i].querySelector('label').removeAttribute('disabled');
        this.forms[i]
          .querySelector("input[id^='toggle-bookmark_']")
          .removeAttribute('disabled');
        if (response.ok) {
          const json = await response.json();
          this.updateState(i);
          document.querySelector('[data-role=bookmark-counter]').innerHTML =
            json.bookmarks.count;
        } else {
          alert('Error');
        }
        /* eslint-disable no-await-in-loop */
      }
    }
  }

  checked(index) {
    return (
      this.forms[index].querySelectorAll('input[name=_method][value=delete]')
        .length !== 0
    );
  }

  updateState(index) {
    this.forms[index].querySelector('label').classList.add('checked');
    this.forms[index].querySelector('input[name=_method]').value = 'delete';
    this.forms[index].querySelector('span').innerHTML =
      this.forms[index].getAttribute('data-present');
  }
}
