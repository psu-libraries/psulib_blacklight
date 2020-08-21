[![Maintainability](https://api.codeclimate.com/v1/badges/6d63cfd46af32f8d4bd1/maintainability)](https://codeclimate.com/github/psu-libraries/psulib_blacklight/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/6d63cfd46af32f8d4bd1/test_coverage)](https://codeclimate.com/github/psu-libraries/psulib_blacklight/test_coverage)

The Penn State University Libraries' catalog. Built on Blacklight, using Traject for ingesting binary marc.

# Software Dependencies 

| Software |  Version |
|----------|------|
| `ruby`    |  2.5.3 <br> (_ruby 2.5.3p105 (2018-10-18 revision 65156) [x86_64-darwin16]_) |
| `rails`   |  5.2.1 |
| `solr`   |  7.4.0 |

## When upgrading Blacklight

Because we use webpacker, when upgrading the Blacklight gem for this application, we should also update `package.json` to the same version as the installed gem so as to keep these things in step from Blacklight.

# Development 

## For Macs

Note: we have only developed on Macs thus far.

* Get `homebrew` installed and configured using [these instructions from DSRD until step 12](https://github.com/psu-stewardship/scholarsphere/wiki/How-to-Install-on-a-fresh-Mac)
* `ruby` via `rbenv` ([Upgrading Ruby Version Using rbenv](https://github.com/psu-libraries/psulib_blacklight/wiki/Upgrading-Ruby-Version-Using-rbenv))
* Get docker desktop installed. See https://www.docker.com/products/docker-desktop

## Development Setup
1.  [Make sure you have ssh keys established on your machine](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#generating-a-new-ssh-key)
1.  Make sure you have docker desktop running
1.  Clone the application and install:
    ``` 
    git clone git@github.com:psu-libraries/psulib_blacklight.git
    cd psulib_blacklight
    bundle install --without production test
    ```

1.  Create the database and run the migrations
    ```
    bundle exec rake db:create db:migrate
    ```

1.  Start the application (showing `foreman` method, but just look at `Procfile.dev` to see what that is running if you'd rather some other method like `tmux`)
    ```
    bundle exec foreman start -f Procfile.dev
    ```
    
    Note: on a Mac you may be asked by the OS if you want to allow incoming connections to Ruby. Because this is a local dev instance, you can choose to deny incoming connections. This configuration can be found in the Security & Privacy section of the Systems Preferences. 

## Indexing

Use [Traject](https://github.com/psu-libraries/psulib_traject#build-an-index)


To clean out data that is being preserved explicitly run:
```
bundle exec rails docker:clean
```

## Building and Using Javascript

Follow the instructions for [How To Use Webpacker](https://github.com/psu-libraries/psulib_blacklight/wiki/How-To-Use-Webpacker) to compile javascript assets.

# Application notes

## "Blackcat Admin" feature

The [config](https://rubygems.org/gems/config) gem provides a means for adding ad-hoc config as needed. The file `config/settings.local.yml` is not tracked in git. So far 5 settings have been added:

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
hold_button_url: https://myaccount01qa.libraries.psu.edu/holds/new?catkey=

# Booleans
readonly: false
hide_hold_button: false
hathi_etas: false
```

If one of the special keys isn't present, there is no ill-effect. It is just not there and the system operates as per usual. If the announcement array isn't present, then the default announcement in the translation file will show.
