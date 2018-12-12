# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe '#catalog_link' do
    let (:catalog_link_field_data) { ["{\"catkey\": \"355035\", \"linktext\": \"The high-caste Hindu woman / With introduction by Rachel L. Bodley\"}"] }
    let (:catalog_link_doc) { {value: catalog_link_field_data } }

    context 'has a single value for a link field' do
      it 'assembles a link' do
        link = catalog_link(catalog_link_doc)
        expect(link).to eql('<a href="/catalog/355035">The high-caste Hindu woman / With introduction by Rachel L. Bodley</a>')
      end
    end
  end
end