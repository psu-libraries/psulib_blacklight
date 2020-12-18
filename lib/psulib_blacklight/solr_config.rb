# frozen_string_literal: true

require 'zip'

module PsulibBlacklight
  class SolrConfig
    CONFIG_PATH = '/solr/admin/configs'
    COLLECTION_PATH = '/solr/admin/collections'
    SOLR_DIR = '/solr/conf'

    def url
      Settings&.solr&.url || 'localhost'
    end

    def collection_name
      Settings&.solr&.collection || 'blacklight-core'
    end

    def config_url
      "#{url}#{CONFIG_PATH}"
    end

    def collection_url
      "#{url}#{COLLECTION_PATH}"
    end

    def num_shards
      Settings&.solr&.num_shards || 1
    end

    def replication_factor
      Settings&.solr&.replication_factor || 1
    end

    def max_shards_per_node
      Settings&.solr&.max_shards_per_node || 1
    end

    def configset_name
      "configset-#{solr_md5}"
    end

    private

    # Returns a combined MD5 digest for all files in solr config directory
    def solr_md5
      digest = []
      Dir.glob("#{SOLR_DIR}/**/*").each do |f|
        digest.push(Digest::MD5.hexdigest(File.open(f).read)) if File.file?(f)
      end
      Digest::MD5.hexdigest(digest.join(''))
    end

  end
end
