# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#catalog_link' do
    let (:field_data) { ['{"catkey": "355035", '\
                          '"linktext": "The high-caste Hindu woman / With introduction by Rachel L. Bodley"}'] }
    let (:catalog_link_doc) { { value: field_data } }

    context 'when there is a single value for a link field' do
      it 'assembles a link' do
        link_text = '<a href="/catalog/355035">The high-caste Hindu woman / With introduction by Rachel L. Bodley</a>'
        link = catalog_link catalog_link_doc
        expect(link).to eql link_text
      end
    end
  end

  describe '#display_duration' do
    let (:field_data) { { value: ['221850'] } }

    context 'when there is a duration in NNNNNN' do
      it 'changes it to HH:MM:SS' do
        duration_values = display_duration field_data
        expect(duration_values).to eql ['22:18:50']
      end
    end
  end
end
