# frozen_string_literal: true

module PsulibBlacklight
  class DataManager
    def self.clean_solr
      Blacklight.default_index.connection.delete_by_query('*:*')
      Blacklight.default_index.connection.commit
    end

    # @note Loads fixtures for our development and testing environments
    def self.load_fixtures
      docs = []
      Dir.glob('spec/fixtures/current_fixtures/*.json').each do |file|
        doc = File.open(file).each_line.map { |l| JSON.parse(l) }
        docs += doc
      end
      Blacklight.default_index.connection.add(docs)
      Blacklight.default_index.connection.commit
    end

    # @note We'd usually use a gem like DatabaseCleaner to do this, but since our database usage is so small, this
    # seems like a simpler approach. These are SQLite commands only.
    def self.clean_database
      ['users', 'bookmarks'].map do |table_name|
        ActiveRecord::Base.connection.execute("DELETE FROM #{table_name}")
      end
      ActiveRecord::Base.connection.execute('VACUUM')
    end
  end
end
