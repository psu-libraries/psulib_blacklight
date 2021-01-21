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
    when 'CREATEALIAS'
      json_response 200, 'collections_createalias.json'
    when 'MODIFYCOLLECTION'
      json_response 200, 'collections_modifycollection.json'
    else
      raise Sinatra::NotFound
    end
  end

  get '/solr/admin/configs' do
    case params['action']
    when 'LIST'
      json_response 200, 'configset_list.json'
    when 'DELETE'
      json_response 200, 'configset_delete.json'
    else
      raise Sinatra::NotFound
    end
  end

  post '/solr/admin/configs' do
    case params['action']
    when 'UPLOAD'
      json_response 200, 'configset_upload.json'
    else
      raise Sinatra::NotFound
    end
  end

  private

    def json_response(response_code, file_name)
      content_type :json
      status response_code
      File.open(File.dirname(__FILE__) + '/../fixtures/solr/' + file_name, 'rb').read
    end
end
