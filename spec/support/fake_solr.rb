# frozen_string_literal: true

require 'sinatra/base'

class FakeSolr < Sinatra::Base
  get '/solr/' do
    'ok'
  end

  get '/solr/admin/collections' do
    case params['action']
    when 'LIST'
      json_response 200, 'collections_list.json'
    when 'CREATE'
      json_response 200, 'collections_create.json'
    end
  end

  get '/solr/admin/configs' do
    case params['action']
    when 'LIST'
      json_response 200, 'configset_list.json'
    when 'DELETE'
      json_response 200, 'configset_delete.json'
    end
  end

  post '/solr/admin/configs' do
    case params['action']
    when 'UPLOAD'
      json_response 200, 'configset_upload.json'
    end
  end

  private

    def json_response(response_code, file_name)
      content_type :json
      status response_code
      File.open(File.dirname(__FILE__) + '/../fixtures/solr/' + file_name, 'rb').read
    end
end
