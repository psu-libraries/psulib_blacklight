# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe Rake::Task do
  before do
    described_class.define_task(:environment)
    load Rails.root.join('lib/tasks/solr.rake')
  end

  after do
    described_class.clear
    ENV.delete('SOLR_NAMESPACE')
  end

  it 'builds a solr manager for the solrcat namespace when SOLR_NAMESPACE is set' do
    ENV['SOLR_NAMESPACE'] = 'solrcat'
    solr_manager_spy = instance_spy(PsulibBlacklight::SolrManager)

    allow(PsulibBlacklight::SolrManager).to receive(:new).and_return(solr_manager_spy)

    send(:solr_manager)

    expect(PsulibBlacklight::SolrManager)
      .to have_received(:new)
      .with(have_attributes(namespace: :solrcat))
  end
end
