export default class CheckboxSubmitAll {
  constructor(forms) {
    this.forms = forms
  }

  async clicked() {
    for (var i = 0; i < this.forms.length; i++) {
      if (!this.checked(this.forms[i])) {
        this.forms[i].querySelector('span').innerHTML = this.forms[i].getAttribute('data-inprogress')
        this.forms[i].querySelector('label').setAttribute('disabled', 'disabled');
        this.forms[i].querySelector("input[id^='toggle-bookmark_']").setAttribute('disabled', 'disabled');
        const response = await fetch(this.forms[i].getAttribute('action'), {
          body: new FormData(this.forms[i]),
          method: this.forms[i].getAttribute('method').toUpperCase(),
          headers: {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': document.querySelector('meta[name=csrf-token]')?.content
          }
        })
        this.forms[i].querySelector('label').removeAttribute('disabled')
        this.forms[i].querySelector("input[id^='toggle-bookmark_']").removeAttribute('disabled')
        if (response.ok) {
          const json = await response.json()
          this.updateState(this.forms[i])
          document.querySelector('[data-role=bookmark-counter]').innerHTML = json.bookmarks.count
        } else {
          alert('Error')
        }
      }
    }
  }

  checked(form) {
    return (form.querySelectorAll('input[name=_method][value=delete]').length != 0)
  }

  updateState(form) {
    form.querySelector('label').classList.add('checked')
    form.querySelector('input[name=_method]').value = 'delete'
    form.querySelector('span').innerHTML = form.getAttribute('data-present')
  }
}
