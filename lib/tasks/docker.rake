# frozen_string_literal: true

BLACKLIGHT_CORE = 'psul_blacklight'

namespace :docker do
  task up: :environment do
    Rake::Task['docker:pull'].invoke
    container_status = `docker inspect felix`
    container_status.strip!

    if container_status == '[]'
      Rake::Task['docker:run'].invoke
    else
      Rake::Task['docker:start'].invoke
    end

    Rake::Task['docker:ps'].invoke
  end

  task reload: [:start, :up_zk_config] do
    Rake::Task['docker:down'].invoke
    Rake::Task['docker:up']
  end

  task clean: :environment do
    print `docker exec -it felix \
            post -c #{BLACKLIGHT_CORE} \
                 -d '<delete><query>*:*</query></delete>' -out 'yes'`
  end

  task up_zk_config: :environment do
    print `docker exec -it --user=solr felix bin/solr zk upconfig -n #{BLACKLIGHT_CORE} -d /myconfig -z localhost:9983`
  end

  task create_collection: :environment do
    print `docker exec -it --user=solr felix bin/solr create -c #{BLACKLIGHT_CORE} -d /myconfig`
  end

  task build: [:up_zk_config] do
    Rake::Task['docker:create_collection'].invoke
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
    print `docker run \
            -d=true \
            --name felix \
            -it \
            -e SOLR_HEAP=1G \
            -p 8983:8983 \
            -v "$(pwd)"/solr/conf:/myconfig \
            solr:7.4.0 \
            -DzkRun`
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
