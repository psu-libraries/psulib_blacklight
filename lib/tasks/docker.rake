# frozen_string_literal: true

require 'psulib_blacklight/solr_manager'

namespace :solr do
  task up: :environment do
    Rake::Task['solr:pull'].invoke
    container_status = `docker inspect felix`
    container_status.strip!

    if container_status == '[]'
      Rake::Task['solr:run'].invoke
    else
      Rake::Task['solr:start'].invoke
    end

    Rake::Task['solr:ps'].invoke
  end

  task clean: :environment do
    solr_manager = PsulibBlacklight::SolrManager.new
    print `docker exec -it felix \
            post -c #{solr_manager.config.alias_name} \
                 -d '<delete><query>*:*</query></delete>' -out 'yes'`
  end

  # create a new collection with a configset that is up to date.
  task new_collection: :environment do
    solr_manager = PsulibBlacklight::SolrManager.new
    solr_manager.create_collection
    solr_manager.create_alias
  end

  task update_config: :environment do
    solr_manager = PsulibBlacklight::SolrManager.new
    solr_manager.modify_collection
  end

  task run: :environment do
    trap('SIGINT') do
      print `docker stop felix`
      exit
    end
    print `docker run \
            --name felix \
            -it \
            -a STDOUT \
            -e SOLR_HEAP=1G \
            -p 8983:8983 \
            -v "$(pwd)"/solr/conf:/myconfig \
            solr:7.4.0 \
            -DzkRun`
  end

  task run_ci: :environment do
    print `docker run -d -p 8983:8983 solr:7.4.0 -DzkRun`
  end

  task pull: :environment do
    print `docker pull solr:7.4.0`
  end

  task start: :environment do
    trap('SIGINT') do
      print `docker stop felix`
      exit
    end
    print `docker start -a felix`
  end

  # Doesn't actually get called, can't call it in the trap call under the start task. Rake::Task can't be used there.
  task down: :environment do
    print `docker stop felix`
  end

  task ps: :environment do
    print `docker ps`
  end
end
