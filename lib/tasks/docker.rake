# frozen_string_literal: true

namespace :docker do
  task :up do
    container_status = `docker inspect felix`
    container_status.strip!

    if container_status == '[]'
      Rake::Task['docker:start'].invoke
    else
      print `docker start -a felix`
    end

    Rake::Task['docker:ps'].invoke
  end

  task :clean do
    print `docker exec -it felix \
            post -c blacklight-core \
                 -d '<delete><query>*:*</query></delete>' -out 'yes'`
  end

  task :start do
    print `docker pull solr:7.4.0`
    print `docker run \
            --name felix \
            -a \
            -p 8983:8983 \
            -v "$(pwd)"/solr/conf:/myconfig \
            solr:7.4.0 \
            solr-create -c blacklight-core -d /myconfig`
  end

  task :down do
    print `docker stop felix`
  end

  task :ps do
    print `docker ps`
  end
end
