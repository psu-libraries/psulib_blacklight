[![Maintainability](https://api.codeclimate.com/v1/badges/6d63cfd46af32f8d4bd1/maintainability)](https://codeclimate.com/github/psu-libraries/psulib_blacklight/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/6d63cfd46af32f8d4bd1/test_coverage)](https://codeclimate.com/github/psu-libraries/psulib_blacklight/test_coverage)

The Penn State University Libraries' catalog. Built on Blacklight, using Traject for ingesting binary marc.

# Software Dependencies 

| Software |  Version |
|----------|------|
| `ruby`    |  3.1.2 |
| `rails`   |  6.1.7 |
| `solr`   |  8.11.2 |

## When upgrading Blacklight

Because we use webpacker, when upgrading the Blacklight gem for this application, we should also update `package.json`
to the same version as the installed gem so as to keep these things in step from Blacklight.

## Development

See [Development Setup](https://github.com/psu-libraries/psulib_blacklight/wiki/Development-Setup)

# Application notes

## "Blackcat Admin" feature

The [config](https://rubygems.org/gems/config) gem provides a means for adding ad-hoc config as needed. The file
`config/settings.local.yml` is not tracked in git. So far 5 settings have been added:

1. Modify the announcement bar (thin bar at top)
1. Put the site in "readonly" (no availability data)
1. Put holds in readonly mode by hiding the I Want It button 
1. Put the site in HathiTrust ETAS enabled mode (ETAS items do not display availability data)
1. Modify the hold button url

Here is a sample of what the `settings.yml` file might look like:

```rb
# Strings
announcement:
  # See https://fontawesome.com/icons
  icon: fa-exclamation-circle
  message: All University Libraries locations are closed, but we're here to help! See <a href="https://libraries.psu.edu/covid19"> University Libraries COVID-19 (novel coronavirus) Updates and Resources</a> for more information.
  # See https://getbootstrap.com/docs/4.4/utilities/colors/
  html_class: bg-warning
my_account_url: https://myaccount.libraries.psu.edu/
hold_button_path: holds/new?catkey=
no_recall_button_path: ill/new?catkey=

# Booleans
readonly: false
hide_hold_button: false
hide_announcement: false
hathi_etas: false
```

If one of the special keys isn't present, there is no ill-effect. It is just not there and the system operates as per
usual. If the announcement array isn't present, then the default announcement in the translation file will show.
