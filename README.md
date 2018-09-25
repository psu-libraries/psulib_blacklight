# Set up your environment 
(Mac users) Use these instructions (from DSRD) until step 12: https://github.com/psu-stewardship/scholarsphere/wiki/How-to-Install-on-a-fresh-Mac

# Dependencies 

## Ruby
```
$ ruby --version
  ruby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-darwin16]
```
If you need to upgrade your ruby version, follow the steps for [Upgrading Ruby Version Using rbenv](Upgrading-Ruby-Version-Using-rbenv).

## Rails
``` 
$ rails -v
  Rails 5.2.1
```

## Java

```
$ java --version
  java 9
  Java(TM) SE Runtime Environment (build 9+181)
  Java HotSpot(TM) 64-Bit Server VM (build 9+181, mixed mode)
```

# Development setup
1.  Make sure you have ssh keys established on your machine https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#generating-a-new-ssh-key
1.  Clone the application and install:
    ``` 
    git clone git@github.com:psu-libraries/psulib_blacklight.git
    cd psulib_blacklight
    bundle install --without production test
    ```

1.  Create the database and run the migrations
    ```
    rake db:create db:migrate
    ```

1.  Start up solr
    ```
    bundle exec solr_wrapper
    ```

1.  Start up your application
    ```
    rails s
    ```
    
    Note: on a Mac you may be asked by the OS if you want to allow incoming connections to Ruby. Because this is a local dev instance, you can choose to deny incoming connections. This configuration can be found in the Security & Privacy section of the Systems Preferences. 

# Sample records
Index sample marc records from CAT (if you haven't done yet). You can download a sample file from https://psu.app.box.com/folder/53004724072.
```
rake solr:marc:index MARC_FILE=path_to_file/sample_psucat.mrc 
```
This should index 522 documents. Check here: http://localhost:8983/solr/#/blacklight-core/query

Note: To clean out data that is being preserved explicitly run:
```
solr_wrapper -d .solr_wrapper.yml clean
```

Go to http://localhost:3000/catalog.

# Building and Using the javascript

Follow the instructions for [How To Use Webpacker](How-To-Use-Webpacker) to compile javascript assets.

# Bootsnap -- LoadError

Bootsnap is a gem used to speed up local development. We have experienced a problem where clearing the cache that bootsnap builds is necessary. Here's how:

* go to the project home, then cd into tmp/cache
* delete bootsnap-load-path-cache and bootsnap-compile-cache
