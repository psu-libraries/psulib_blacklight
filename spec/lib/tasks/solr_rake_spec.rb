# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'solr tasks' do
  before do
    Rake::Task.define_task(:environment)
    load Rails.root.join('lib/tasks/solr.rake')
  end

  after do
    Rake::Task.clear
    ENV.delete('SOLR_NAMESPACE')
  end

  it 'builds a solr manager for the solrcat namespace when SOLR_NAMESPACE is set' do
    ENV['SOLR_NAMESPACE'] = 'solrcat'

    expect(PsulibBlacklight::SolrManager).to receive(:new) do |config|
      expect(config.namespace).to eq(:solrcat)
      instance_double(PsulibBlacklight::SolrManager)
    end

    send(:solr_manager)
  end
end
