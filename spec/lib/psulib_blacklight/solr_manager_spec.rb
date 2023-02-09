# frozen_string_literal: true

require 'rails_helper'
require 'psulib_blacklight/solr_manager'
require 'psulib_blacklight/solr_config'

RSpec.describe PsulibBlacklight::SolrManager do
  subject(:solr_manager) { described_class.new(config_obj) }

  let(:config_obj) { PsulibBlacklight::SolrConfig.new }

  before do
    stub_request(:any, /:#{Settings.solr.port}/).to_rack(FakeSolr)
    stub_const('PsulibBlacklight::SolrManager::ALLOWED_TIME_TO_RESPOND', 1)
  end

  describe '#delete_unused_collections' do
    context 'when there are collections to delete' do
      before do
        stub_request(:get, "#{config_obj.url}/solr/admin/collections?action=LIST")
          .to_return(status: 200, body: '{"responseHeader":{"status":0, "QTime":11},
                    "collections":["psul_catalog_v1", "psul_catalog_v2"]}')
        stub_request(:get, "#{config_obj.url}/solr/admin/collections?action=LISTALIASES")
          .to_return(status: 200, body: '{"responseHeader":{"status":0,"QTime":1},
                    "aliases":{"psul_catalog":"psul_catalog_v1"},"properties":{}}')
        stub_request(:post, "#{config_obj.url}/solr/admin/collections?action=DELETE")
          .with(query: { name: 'psul_catalog_v2' })
          .to_return(status: 200, body: '{"responseHeader":{"status":0,"QTime":318},
                    "success":{"host":{"responseHeader":{"status":0,"QTime":45}}}}')
      end

      it 'deletes unused collections' do
        expect(solr_manager.delete_unused_collections).to eq(['psul_catalog_v2'])
      end
    end
  end

  describe '#initialize_collection' do
    context 'when collection does not exist' do
      before do
        stub_request(:get, "#{config_obj.url}/solr/admin/collections?action=LIST")
          .to_return(status: 200, body: '{"responseHeader":{"status":0, "QTime":11}, "collections":[""]}').then
          .to_return(status: 200, body: '{"responseHeader":{"status":0, "QTime":11},
                    "collections":["psul_catalog_v1"]}')
        stub_request(:get, "#{config_obj.url}/solr/admin/collections?action=MODIFY")
          .to_return(status: 200)
      end

      it 'does add a new collection' do
        expect(solr_manager.initialize_collection).to equal(200)
      end
    end

    context 'when collection does exist' do
      before do
        stub_request(:get, "#{config_obj.url}/solr/admin/collections?action=LIST")
          .to_return(status: 200, body: '{"responseHeader":{"status":0, "QTime":11},
                    "collections":["psul_catalog_v1"]}')
      end

      it 'does not add a new collection' do
        expect(solr_manager.initialize_collection).to equal(nil)
      end
    end
  end

  describe '#initialize' do
    context 'when solr does not respond for the allowed time to wait' do
      before do
        stub_request(:get, "#{config_obj.url}/solr/").to_raise(Faraday::ConnectionFailed)
      end

      it 'raises an exception' do
        expect { solr_manager }.to raise_error 'Cannot find Solr'
      end
    end

    context 'when solr is up and the current configset is not present in solr' do
      before do
        stub_request(:get, "#{config_obj.url}/solr/admin/configs?action=LIST")
          .to_return(status: 200, body: '{"responseHeader":{"status":0, "QTime":11}, "configSets":["_default"]}',
                     headers: {}).then
          .to_return({ body: File.read('spec/fixtures/solr/configset_list.json') })
      end

      it 'attempts to upload configset' do
        expect(solr_manager.send(:config_sets)).to include('configset-eae0a4a2696affb9748c2d2b2ac44cdf')
      end
    end

    context 'when solr is up and no configset exists in solr' do
      before do
        stub_request(:get, "#{config_obj.url}/solr/admin/configs?action=LIST")
          .to_return(status: 200, body: '{"responseHeader":{"status":0, "QTime":11}}',
                     headers: {}).then
          .to_return({ body: File.read('spec/fixtures/solr/configset_list.json') })
      end

      it 'attempts to upload configset' do
        expect(solr_manager.send(:config_sets)).to include('configset-eae0a4a2696affb9748c2d2b2ac44cdf')
      end
    end

    context 'when solr is up and the current configset is present in solr' do
      let(:spy_solr_manager) { instance_spy(described_class) }

      before do
        allow(described_class).to receive(:new).and_return(spy_solr_manager)
      end

      it 'a new config is not uploaded' do
        expect(spy_solr_manager).not_to have_received(:upload_config)
      end
    end
  end

  describe '#create_alias' do
    it 'creates OR updates an alias to the current collection with version name' do
      expect(solr_manager.create_alias).to equal 200
    end

    context 'when there are not collections with prefixes matching our collection name scheme' do
      before do
        stub_request(:get, "#{config_obj.url}/solr/admin/collections?action=LIST")
          .to_return(status: 200, body: '{"responseHeader":{"status":0, "QTime":11}, "collections":["not_match"]}',
                     headers: {}).then
      end

      it 'raises SolrCollectionsNotFoundError' do
        expect { solr_manager.create_alias }.to raise_error SolrCollectionsNotFoundError
      end
    end
  end

  describe '#create_collection' do
    it 'creates a collection' do
      expect(solr_manager.create_collection).to equal 200
    end
  end

  describe '#delete_collection' do
    context 'when there is a collection to delete' do
      before do
        stub_request(:get, "#{config_obj.url}/solr/admin/collections?action=LIST")
          .to_return(status: 200,
                     body: '{"responseHeader":{"status":0, "QTime":11}, "collections":["psulib_blacklight_v2"]}',
                     headers: {}).then
        stub_request(:post, "#{config_obj.url}/solr/admin/collections?action=DELETE").with(
          query: { name: 'psulib_blacklight_v2' }
        )
      end

      it 'deletes the collection' do
        expect(solr_manager.delete_collection('psulib_blacklight_v2')).to equal 200
      end
    end

    context 'when there is no collection to delete' do
      before do
        stub_request(:get, "#{config_obj.url}/solr/admin/collections?action=LIST")
          .to_return(status: 200,
                     body: '{"responseHeader":{"status":0, "QTime":11}, "collections":["psulib_blacklight_v2"]}',
                     headers: {}).then
      end

      it 'does not delete any collection' do
        expect(solr_manager.delete_collection('foo')).to be_nil
      end
    end
  end

  describe '#modify_collection' do
    it 'updates the current collection\'s config set to the latest' do
      expect(solr_manager.modify_collection).to equal 200
    end

    context 'when there are not collections with prefixes matching our collection name scheme' do
      before do
        stub_request(:get, "#{config_obj.url}/solr/admin/collections?action=LIST")
          .to_return(status: 200, body: '{"responseHeader":{"status":0, "QTime":11}, "collections":["not_match"]}',
                     headers: {}).then
      end

      it 'raises SolrCollectionsNotFoundError' do
        expect { solr_manager.modify_collection }.to raise_error SolrCollectionsNotFoundError
      end
    end
  end

  describe '#last_incremented_collection' do
    it 'emits the last incremented collection' do
      expect(solr_manager.last_incremented_collection).to eq 'psul_catalog_v1'
    end
  end
end
