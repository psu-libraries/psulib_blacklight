# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FacetsHelper do
  let(:basic_facet) { Blacklight::Solr::Response::Facets::FacetItem.new(value: 'some value', field: 'basic_facet') }
  let(:child_item) do
    Blacklight::Solr::Response::Facets::FacetItem.new(value: 'child value', field: 'child_item', items: [])
  end
  let(:pivot_items) do
    Blacklight::Solr::Response::Facets::FacetItem.new(value: 'parent value', field: 'parent_item', items: [child_item])
  end
  let(:pivot_facet) { Blacklight::Solr::Response::Facets::FacetField.new('pivot_facet', [pivot_items]) }

  describe 'initial_collapse' do
    it 'returns \'facet-values\' for to be added as a class to pivot facet parent element' do
      expect(helper.initial_collapse('pivot_facet', pivot_facet)).to eq('facet-values')
    end

    it 'returns \'collapse\' for unselected pivot facet child items' do
      expect(helper.initial_collapse('pivot_facet', child_item)).to eq('collapse')
    end

    it 'returns \'collapse show\' for selected pivot facet child items' do
      allow(helper).to receive_messages(params: { f: { 'child_item' => ['child value'] } })
      expect(helper.initial_collapse('pivot_facet', child_item)).to eq('collapse show')
    end
  end

  describe 'facet_value_id' do
    it 'generates an id for pivot facet child items but not for parent items' do
      expect(helper.facet_value_id(pivot_facet)).to eq ''
      expect(helper.facet_value_id(child_item)).to eq 'id=child_item-child-value'
    end
  end

  describe 'pivot_facet_child_in_params?' do
    it 'checks if pivot facet child items are not selected' do
      expect(helper.pivot_facet_child_in_params?('pivot_facet', child_item)).to be false
      expect(helper.pivot_facet_child_in_params?('pivot_facet', pivot_items)).to be false
      expect(helper.pivot_facet_child_in_params?('pivot_facet', pivot_facet)).to be false
    end

    it 'checks if pivot facet child items are selected' do
      allow(helper).to receive_messages(params: { f: { 'child_item' => ['child value'] } })
      expect(helper.pivot_facet_child_in_params?('pivot_facet', child_item)).to be true
      expect(helper.pivot_facet_child_in_params?('pivot_facet', pivot_items)).to be true
      expect(helper.pivot_facet_child_in_params?('pivot_facet', pivot_facet)).to be true
    end
  end

  describe 'pivot_facet_in_params?' do
    it 'checks if pivot facet parent item is not selected' do
      expect(helper.pivot_facet_in_params?('pivot_facet', pivot_items)).not_to be true
    end

    it 'checks if pivot facet parent item is selected' do
      allow(helper).to receive_messages(params: { f: { 'parent_item' => ['parent value'] } })
      expect(helper.pivot_facet_in_params?('pivot_facet', pivot_items)).to be true
    end
  end

  describe 'facet_field_in_params?' do
    let(:pivot) { ['pivot_a', 'pivot_b'] }

    let(:blacklight_config) do
      Blacklight::Configuration.new do |config|
        config.add_facet_field 'basic_field'
        config.add_facet_field 'other_field'
        config.add_facet_field 'pivot_facet_field', pivot: ['pivot_a', 'pivot_b']
      end
    end

    before do
      without_partial_double_verification do
        allow(helper).to receive(:blacklight_config).and_return blacklight_config
      end
    end

    it 'checks if the facet field is selected in the user params' do
      allow(helper).to receive_messages(params: { f: { 'basic-field' => ['x'] } })
      expect(helper).to be_facet_field_in_params('basic-field')
      expect(helper.facet_field_in_params?('other-field')).not_to be true
    end

    it 'checks if the pivot facet field is selected in the user params' do
      allow(helper).to receive_messages(params: { f: { 'pivot_a' => ['x'] } })
      expect(helper).to be_facet_field_in_params('pivot_a')
      expect(helper.facet_field_in_params?('pivot_b')).not_to be true
    end

    describe 'pivot_facet_field_in_params?' do
      it 'checks if pivot is not selected' do
        expect(helper.pivot_facet_field_in_params?(pivot)).not_to be true
      end

      it 'checks if pivot is selected' do
        allow(helper).to receive_messages(params: { f: { 'pivot_a' => ['x'] } })
        expect(helper.pivot_facet_field_in_params?(pivot)).to be true
      end
    end
  end
end
