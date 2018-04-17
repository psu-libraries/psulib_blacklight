# Set up your environment 
(Mac users) Use these instructions (from DSRD) until step 12: https://github.com/psu-stewardship/scholarsphere/wiki/How-to-Install-on-a-fresh-Mac

# Dependencies 

## Ruby
```
$ ruby --version
  ruby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-darwin16]
```
If you need to upgrade your ruby version, follow these steps to upgrade using rbenv: https://psu.app.box.com/notes/288380781861

## Rails
``` 
$ rails -v
  Rails 5.1.6
```

## Java

```
$ java --version
  java 9
  Java(TM) SE Runtime Environment (build 9+181)
  Java HotSpot(TM) 64-Bit Server VM (build 9+181, mixed mode)
```

# Development setup
1.  Make sure you have ssh keys established on your machine and make sure your public key is stored on git.psu.edu: https://docs.gitlab.com/ee/gitlab-basics/create-your-ssh-keys.html
1.  Clone the application and install:
    ``` 
    git clone git@git.psu.edu:i-tech/psulib_blacklight.git ~/projects/psulib_blacklight
    cd psulib_blacklight
    bundle install
    ```

1. If you prefer to use SQLite in your development then follow these steps:
    1.  Make sure that your Gemfile has the following *uncommented*:    
        ```
        gem 'sqlite3'
        ```
        
        and *comment out* 
        
        ```
        gem 'mysql2'
        ```
    1. Replace your database.yml file 
        ```
        cp config/sample_database.yml config/database.yml
        ```
        
1.  If you prefer to use MySQL in your development then follow these steps:
      1.  Use the sample.env as a reference to generate an .env file
          ```
          cp sample.env .env
          ```
      1.  Edit .env file to replace your local mysql username, password and path to your socket file. *Note: this information is not saved in git.*
      1.  If MYSQL is not already installed, follow these instructions: https://psu.app.box.com/notes/288370435578 
      1.  To find the path to your MYSQL socket file:
          ```
          mysql -u root
          show variables like 'socket';
          ```
          
          or
          
          ```
          mysql --socket
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

# Sample records
Index sample marc records from CAT (if you haven't done yet). You can download a sample file from https://psu.app.box.com/file/287669838155.
```
rake solr:marc:index MARC_FILE=path_to_file/sample_psucat_marc.mrc 
```
This should index 112 documents. Check here: http://localhost:8983/solr/#/blacklight-core/query

Note: To clean out data that is being preserved explicitly run:
```
solr_wrapper -d .solr_wrapper.yml clean
```

Go to http://localhost:3000/catalog.
