# frozen_string_literal: true

require Rails.root.join('spec/support/catalog_factory.rb')
require Rails.root.join('spec/support/record_factory.rb')
require Rails.root.join('spec/support/catalog_cleaner.rb')

namespace :blackcat do
  namespace :solr do
    desc 'Posts fixtures to Solr'
    task index: :environment do
      CatalogFactory.load_defaults
    end

    desc 'Delete fixtures from Solr'
    task deindex: :environment do
      CatalogCleaner.clean_solr
    end

    desc 'Add call number fixtures'
    task call_numbers: :environment do
      CatalogFactory.load_call_numbers
    end

    desc 'Add call numbers from file'
    task call_file: :environment do
      fixture = Rails.root.join('tmp/ba-bf.json')

      Blacklight.default_index.connection.delete_by_query('*:*')
      JSON.parse(fixture.read).dig('response', 'docs').map do |doc|
        doc.delete('score')
        doc['forward_lc_shelfkey'] = ShelfList.generate_forward_shelfkey(doc['call_number_ssm'].first)
        doc['reverse_lc_shelfkey'] = ShelfList.generate_reverse_shelfkey(doc['call_number_ssm'].first)
        Blacklight.default_index.connection.add(doc)
      end
      Blacklight.default_index.connection.commit
    end
  end

  namespace :traject do
    desc 'Generate fixtures using Traject'
    task create_fixtures: :environment do
      # Note: updates to the sample_psucat.mrc file are produced by Maryam. We can request a new version of the file
      # with examples that we are seeking and she will produce it and place it on the symphony server.
      traject_path = Rails.root.join('../psulib_traject')
      fixtures = Rails.root.join('spec/fixtures/current_fixtures.json')
      marc_file = Rails.root.join('solr/sample_data/*.mrc')
      args = "-c lib/traject/psulib_config.rb -w Traject::JsonWriter -o #{fixtures}"
      version = 'RBENV_VERSION=jruby-9.2.11.1'
      Bundler.with_clean_env do
        system("cd #{traject_path} && /bin/bash -l -c '#{version} bundle exec traject #{args} #{marc_file}'")
      end
    end
  end
end
