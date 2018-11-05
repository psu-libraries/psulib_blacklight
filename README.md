# Setup Your Environment 

## Mac

* Get `homebrew` installed and configured using [these instructions from DSRD until step 12](https://github.com/psu-stewardship/scholarsphere/wiki/How-to-Install-on-a-fresh-Mac)
* `ruby` via `rbenv` ([Upgrading Ruby Version Using rbenv](https://github.com/psu-libraries/psulib_blacklight/wiki/Upgrading-Ruby-Version-Using-rbenv))

# Dependencies 

| Software |  Version |
|----------|------|
| `ruby`    |  2.5.3 <br> (_ruby 2.5.3p105 (2018-10-18 revision 65156) [x86_64-darwin16]_) |
| `rails`   |  5.2.1 |
| `solr`   |  7.4.0 |

# Development Setup
1.  [Make sure you have ssh keys established on your machine](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#generating-a-new-ssh-key)
1.  [Make sure you have docker installed and running](https://docs.docker.com/install/)
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

1.  Start the application
    ```
    bundle exec rails docker:up
    ```
    
    Note: on a Mac you may be asked by the OS if you want to allow incoming connections to Ruby. Because this is a local dev instance, you can choose to deny incoming connections. This configuration can be found in the Security & Privacy section of the Systems Preferences. 

# Indexing

Use [Traject](https://github.com/psu-libraries/psulib_traject#build-an-index)


To clean out data that is being preserved explicitly run:
```
bundle exec rails docker:clean
```

Go to http://localhost:3000/catalog.

# Building and Using Javascript

Follow the instructions for [How To Use Webpacker](https://github.com/psu-libraries/psulib_blacklight/wiki/How-To-Use-Webpacker) to compile javascript assets.