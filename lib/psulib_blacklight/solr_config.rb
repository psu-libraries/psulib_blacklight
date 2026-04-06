# frozen_string_literal: true

require 'zip'

module PsulibBlacklight
  class SolrConfig
    CONFIG_PATH = '/solr/admin/configs'
    COLLECTION_PATH = '/solr/admin/collections'
    SOLR_DIR = 'solr/conf'

    attr_reader :namespace, :overrides

    def initialize(namespace: :solr, overrides: {})
      @namespace = namespace.to_sym
      @overrides = overrides.transform_keys(&:to_sym)
    end

    def url
      "#{protocol}://#{host}:#{port}"
    end

    def query_url
      query_url = "#{url}/solr/#{collection_name}"
      if solr_username && solr_password
        return query_url.gsub('://', "://#{solr_username}:#{CGI.escape(solr_password)}@")
      end

      query_url
    end

    def protocol
      overrides[:protocol].presence || settings&.protocol || 'http'
    end

    def host
      overrides[:host].presence || settings&.host
    end

    def port
      overrides[:port].presence || settings&.port
    end

    def solr_username
      overrides[:username].presence || settings&.username
    end

    def solr_password
      overrides[:password].presence || settings&.password
    end

    def collection_name
      overrides[:collection].presence || settings&.collection || 'blacklight-core'
    end

    def alias_name
      collection_name
    end

    def num_shards
      overrides[:num_shards] || settings&.num_shards || 1
    end

    def replication_factor
      overrides[:replication_factor] || settings&.replication_factor || 1
    end

    def max_shards_per_node
      overrides[:max_shards_per_node] || settings&.max_shards_per_node || 1
    end

    def configset_name
      "configset-#{solr_md5}"
    end

    private

      def settings
        @settings ||= if namespace == :solrcat
          solrcat_settings = Settings.respond_to?(:solrcat) ? Settings.solrcat : nil

          if missing_solrcat_settings?(solrcat_settings)
            Rails.logger.info('Settings.solrcat is missing or empty; falling back to Settings.solr')
            Settings.solr
          else
            solrcat_settings
          end
        else
          Settings.solr
        end
      end

      def missing_solrcat_settings?(settings)
        settings.nil? || settings.host.blank? || settings.port.blank?
      end

      # Returns a combined MD5 digest for all files in solr config directory
      def solr_md5
        digest = []
        Dir.glob("#{SOLR_DIR}/**/*").each do |f|
          digest.push(Digest::MD5.hexdigest(File.read(f))) if File.file?(f)
        end
        Digest::MD5.hexdigest(digest.join)
      end
  end
end
