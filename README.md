# Set up your environment 
Use these instructions (from DSRD) until step 12: https://github.com/psu-stewardship/scholarsphere/wiki/How-to-Install-on-a-fresh-Mac

# Dependencies 
Verify dependencies listed in the Quickstart: https://github.com/projectblacklight/blacklight/wiki/Quickstart

# Development Setup
Clone the application and install:

``` 
git clone git@git.psu.edu:i-tech/psulib_blacklight.git ~/projects/psulib_blacklight
cd psulib_blacklight
bundle install
```

Use the sample.env as a reference to generate an .env file
```
cp sample.env .env
```
Edit .env file to replace your local mysql username, password and path to your socket file.
*Note: this information is not saved in git.*

If MYSQL is not already installed, follow these instructions: https://psu.app.box.com/notes/288370435578 

To find the path to your MYSQL socket file:

```
mysql -u root
show variables like 'socket';
```

or 

```
mysql --socket
```

Create the database and run the migrations
```
rake db:create db:migrate
```

Start up solr
```
bundle exec solr_wrapper
```

Start up your application
```
rails s
```

Index sample marc records from CAT (if you haven't done yet)
```
rake solr:marc:index MARC_FILE=path_to_file/sample_psucat_marc.mrc 
```
This should index 112 documents. Check here: http://localhost:8983/solr/#/blacklight-core/query

Note: To clean out data that is being preserved explicitly run:
```
solr_wrapper -d .solr_wrapper.yml clean
```

Go to http://localhost:3000/catalog.
