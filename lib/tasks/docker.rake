# frozen_string_literal: true

namespace :docker do
  task :up do
    Rake::Task['docker:pull'].invoke
    container_status = `docker inspect felix`
    container_status.strip!

    if container_status == '[]'
      Rake::Task['docker:first_start'].invoke
    else
      Rake::Task['docker:start'].invoke
      Rake::Task['docker:conf'].invoke
      Rake::Task['docker::down'].invoke
      Rake::Task['docker:start'].invoke
    end

    Rake::Task['docker:ps'].invoke
  end

  task :clean do
    print `docker exec -it felix \
            post -c blacklight-core \
                 -d '<delete><query>*:*</query></delete>' -out 'yes'`
  end

  task :first_start do
    print `docker run \
            --name felix \
            -a STDOUT \
            -p 8983:8983 \
            -v "$(pwd)"/solr/conf:/myconfig \
            solr:7.4.0 \
            solr-create -c blacklight-core -d /myconfig`
  end

  task :pull do
    print `docker pull solr:7.4.0`
  end

  task :start do
    print `docker start -a felix`
  end

  task :conf do
    print `docker exec -it felix \
            cp -R /myconfig/. /opt/solr/server/solr/blacklight-core/conf/`
  end

  task :down do
    print `docker stop felix`
  end

  task :ps do
    print `docker ps`
  end
end
