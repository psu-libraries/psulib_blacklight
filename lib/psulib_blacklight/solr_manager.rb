# frozen_string_literal: true

require 'psulib_blacklight/solr_config'

module PsulibBlacklight
  class SolrManager

    attr_reader :config

    def initialize(config = SolrConfig.new)
      @config = config
      raise 'Cannot find Solr' unless solr_is_up?
      upload_config unless configset_exists?
    end

    def solr_is_up?
      time = Time.now

      begin
        return false if time + 30.seconds < Time.now
        resp = connection.get('/solr/')
        if resp.status == 200
          return true
        else
          sleep 1
        end
      rescue Faraday::ConnectionFailed
        sleep 1
        retry
      end
    end

    def create_alias
      resp = connection.get(SolrConfig::COLLECTION_PATH,
                            action: 'CREATEALIAS',
                            name: config.collection_name,
                            collections: collection_name_with_version)
      check_resp(resp)
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


    def modify_collection
      resp = connection.get(SolrConfig::COLLECTION_PATH,
                            action: 'MODIFYCOLLECTION',
                            collection: config.collection_name,
                            "collection.configName": config.configset_name)
      check_resp(resp)
    end

    def delete_configset(set = config.configset_name)
      resp = connection.get(SolrConfig::CONFIG_PATH, action: 'DELETE', name: set)
      check_resp(resp)
    end

    def delete_all_configsets
      config_sets
          .reject { |set| set == '_default' }
          .map { |set| delete_configset(set) }
    end

    def delete_collection(collection = config.collection_name)
      resp = connection.get(SolrConfig::COLLECTION_PATH, action: 'DELETE', name: collection)
      check_resp(resp)
    end

    def delete_all_collections
      collections.map { |collection| delete_collection(collection) }
    end

    def reset
      delete_all_collections
      delete_all_configsets
    end

    private

    def collection_name_with_version
      @collection_name_with_version ||= "#{config.collection_name}_v#{next_collection_version}"
    end

    def next_collection_version
      return 1 if collections&.grep(/#{config.collection_name}/).empty?

      (collections.collect { |version| version.scan(/\d/).first.to_i }.flatten.sort.last) + 1
    end

    # Gets a response object, if it's status code is not 200, we emit the body and bail
    def check_resp(resp)
      raise resp.body unless resp.status == 200
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
  end
end
