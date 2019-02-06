# frozen_string_literal: true

require 'rails_helper'

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
                         publication_display_ssm: 'This is the publication statement of the document')
      end

      let(:config) do
        Blacklight::Configuration.new.configure do |config|
          config.add_index_field 'publication_display_ssm'
          config.add_index_field 'format'
        end
      end

      it 'publication statement has an empty label' do
        expect(presenter.fields['publication_display_ssm'].label).to be_nil
        expect(presenter.fields['format'].label).to eq('Format')
      end
    end
  end
end
