# frozen_string_literal: true

require 'psulib_blacklight/solr_config'
require 'psulib_blacklight/exceptions'
require 'zip'

module PsulibBlacklight
  class SolrManager
    ALLOWED_TIME_TO_RESPOND = 30

    attr_reader :config

    def initialize(config = SolrConfig.new)
      @config = config
      raise 'Cannot find Solr' unless solr_up?

      upload_config unless configset_exists?
    end

    def create_collection
      resp = connection.get(SolrConfig::COLLECTION_PATH,
                            action: 'CREATE',
                            name: collection_name_with_version,
                            numShards: config.num_shards,
                            replicationFactor: config.replication_factor,
                            maxShardsPerNode: config.max_shards_per_node,
                            "collection.configName": config.configset_name)

      check_resp(resp)
    end

    def create_alias
      raise SolrCollectionsNotFoundError unless collections_with_prefix.any?

      resp = connection.get(SolrConfig::COLLECTION_PATH,
                            action: 'CREATEALIAS',
                            name: config.alias_name,
                            collections: last_incremented_collection)

      check_resp(resp)
    end

    def modify_collection
      raise SolrCollectionsNotFoundError unless collections_with_prefix.any?

      resp = connection.get(SolrConfig::COLLECTION_PATH,
                            action: 'MODIFYCOLLECTION',
                            collection: last_incremented_collection,
                            "collection.configName": config.configset_name)

      check_resp(resp)
    end

    def last_incremented_collection
      collections_with_prefix.last
    end

    private

      def collections_with_prefix
        collections.grep /#{config.collection_name}/
      end

      def collection_name_with_version
        @collection_name_with_version ||= "#{config.collection_name}_v#{next_collection_version}"
      end

      def next_collection_version
        return 1 if collections&.grep(/#{config.collection_name}/)&.empty?

        collections.map { |version| version.scan(/\d+/).first.to_i }.flatten.max + 1
      end

      # Gets a response object, if it's status code is not 200, we emit the body and bail
      def check_resp(resp)
        raise resp.body unless resp.status == 200

        resp.status
      end

      def configset_exists?
        config_sets.include?(config.configset_name)
      end

      def connection
        @connection ||= Faraday.new(config.url) do |faraday|
          if config.solr_username && config.solr_password
            faraday.request :basic_auth, config.solr_username, config.solr_password
          end
          faraday.request :multipart
          faraday.adapter :net_http
        end
      end

      def config_sets
        list = connection.get(PsulibBlacklight::SolrConfig::CONFIG_PATH, action: 'LIST')
        JSON.parse(list.body)['configSets']
      end

      def collections
        resp = connection.get(PsulibBlacklight::SolrConfig::COLLECTION_PATH, action: 'LIST')
        JSON.parse(resp.body)['collections']
      end

      def zipped_configset
        tmp = Tempfile.new('configset')
        Zip::File.open(tmp, Zip::File::CREATE) do |zipfile|
          Dir["#{PsulibBlacklight::SolrConfig::SOLR_DIR}/**/**"].each do |file|
            zipfile.add(file.sub("#{PsulibBlacklight::SolrConfig::SOLR_DIR}/", ''), file)
          end
        end
        tmp
      end

      def opened_zipped_configset
        File.open zipped_configset
      end

      def upload_config
        resp = connection.post(PsulibBlacklight::SolrConfig::CONFIG_PATH) do |req|
          req.params = { "action": 'UPLOAD', "name": config.configset_name }
          req.headers['Content-Type'] = 'octect/stream'
          req.body = opened_zipped_configset.read
        end

        check_resp(resp)
      end

      def solr_up?
        time = Time.now

        begin
          return false if time + ALLOWED_TIME_TO_RESPOND.seconds < Time.now

          resp = connection.get('/solr/')
          resp.status == 200
        rescue Faraday::ConnectionFailed
          sleep 1
          retry
        end
      end
  end
end
