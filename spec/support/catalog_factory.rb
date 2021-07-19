# frozen_string_literal: true

# @abstract Loads a pre-defined set of records into Solr for testing and development work.

class CatalogFactory
  def self.load_defaults
    Blacklight.default_index.connection.delete_by_query('*:*')

    docs = File.open('spec/fixtures/current_fixtures.json').each_line.map { |l| JSON.parse(l) }
    Blacklight.default_index.connection.add(docs)

    Blacklight.default_index.connection.commit
  end

  # @note Index a bunch of fake records with call numbers. This is only until we get call numbers indexed via Traject
  # and we can start testing against actual marc records.
  def self.load_call_numbers
    Blacklight.default_index.connection.delete_by_query('*:*')

    1000.times do
      Blacklight.default_index.connection.add RecordFactory.new.record
    end

    Blacklight.default_index.connection.commit
  end
end
