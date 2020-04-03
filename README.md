The Penn State University Libraries' catalog. Built on Blacklight, using Traject for ingesting binary marc.

# Software Dependencies 

| Software |  Version |
|----------|------|
| `ruby`    |  2.5.3 <br> (_ruby 2.5.3p105 (2018-10-18 revision 65156) [x86_64-darwin16]_) |
| `rails`   |  5.2.1 |
| `solr`   |  7.4.0 |

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

You can add an optional non-tracked (by git) yml file at `config/blackcat_admin.yml` to (1) modify the announcement bar (thin bar at top), (2) put the site in "readonly" (no availability data) with a message flashed as error, (3) to add an ad-hoc alert (flash error message) or (4) to put holds in readonly mode by hiding the I Want It button. 

The keys dictate the behavior:

```yml
readonly: 
announcement:
alert:
readonly_holds:
```

`readonly_holds` expects a truthy value. `true` or any text here would evaluate to true and hide the I Want It button globally. Not being present at all, having a blank value or `false` all evaluate to `false` and leave the I Want It button in place.

Add values in place to add alert messages like the following:

```yml 
announcement: Some big deal
alert: Your pants are on fire
```

The above would set the announcement bar as "Some big deal" and would flash an error message of "Your pants are on fire"

Note. If both readonly and alert are present in the yml, alert will be the message flashed as error and the availability will be turned off. Usually though you'd just set the flash error in a readonly mode by just setting a message in `readonly:`.

If one of the special keys isn't present, there is no ill-effect. It is just not there and the system operates as per usual. 

