# frozen_string_literal: true

require 'rails_helper'

RSpec::Matchers.define_negated_matcher :be_not_nil, :be_nil

RSpec.describe PsulIndexPresenter do
  subject(:presenter) { described_class.new(document, request_context, config) }

  let(:document) { SolrDocument.new }
  let(:request_context) { instance_double(ActionView::Base, document_index_view_type: 'list') }
  let(:config) { Blacklight::Configuration.new }

  describe '#label' do
    context 'when a document has a publication statement' do
      let(:document) do
        SolrDocument.new(id: 1,
                         format: 'Book',
                         publication_display_ssm: 'This is the publication statement of the document',
                         url_fulltext_display_ssm: 'some url')
      end

      let(:config) do
        Blacklight::Configuration.new.configure do |config|
          config.add_index_field 'publication_display_ssm'
          config.add_index_field 'format'
          config.add_index_field 'url_fulltext_display_ssm'
        end
      end

      it 'has no label for publication statement and format but still has a label for URL' do
        expect(presenter.fields['publication_display_ssm'].label).to be_nil
        expect(presenter.fields['format'].label).to be_nil
        expect(presenter.fields['url_fulltext_display_ssm'].label).to be_not_nil
      end
    end
  end
end
