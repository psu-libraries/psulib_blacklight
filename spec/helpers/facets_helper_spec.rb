# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FacetsHelper do
  let(:basic_facet) { Blacklight::Solr::Response::Facets::FacetItem.new(value: 'some value', field: 'basic_facet') }
  let(:child_item) do
    Blacklight::Solr::Response::Facets::FacetItem.new(value: 'child value', field: 'child_item', items: [])
  end
  let(:parent_item) do
    Blacklight::Solr::Response::Facets::FacetItem.new(value: 'parent value', field: 'parent_item', items: [child_item])
  end
  let(:pivot_facet) { Blacklight::Solr::Response::Facets::FacetField.new('pivot_facet', [parent_item]) }

  describe 'initial_collapse' do
    it 'returns \'facet-values\' which is added as a class to the pivot facet parent element' do
      expect(helper.initial_collapse('pivot_facet', pivot_facet)).to eq('facet-values')
    end

    it 'returns \'collapse\' for unselected pivot facet' do
      expect(helper.initial_collapse('pivot_facet', child_item)).to eq('collapse')
    end

    it 'returns \'collapse show\' for selected pivot facet' do
      allow(helper).to receive_messages(params: { f: { 'child_item' => ['child value'] } })
      expect(helper.initial_collapse('pivot_facet', child_item)).to eq('collapse show')
    end
  end

  describe 'facet_value_id' do
    it 'generates an id for pivot facet child items but not for pivot facet root' do
      expect(helper.facet_value_id(pivot_facet)).to eq ''
      expect(helper.facet_value_id(child_item)).to eq 'id=child_item-child-value'
      expect(helper.facet_value_id(parent_item)).to eq 'id=parent_item-parent-value'
    end
  end

  describe 'pivot_facet_child_in_params?' do
    it 'checks if pivot facet child items are not selected' do
      expect(helper.pivot_facet_child_in_params?('pivot_facet', child_item)).to be false
      expect(helper.pivot_facet_child_in_params?('pivot_facet', parent_item)).to be false
      expect(helper.pivot_facet_child_in_params?('pivot_facet', pivot_facet)).to be false
    end

    it 'checks if pivot facet child items are selected' do
      allow(helper).to receive_messages(params: { f: { 'child_item' => ['child value'] } })
      expect(helper.pivot_facet_child_in_params?('pivot_facet', child_item)).to be true
      expect(helper.pivot_facet_child_in_params?('pivot_facet', parent_item)).to be true
      expect(helper.pivot_facet_child_in_params?('pivot_facet', pivot_facet)).to be true
    end

    it 'checks if child item is selected on parent item' do
      allow(helper).to receive_messages(params: { f: { 'child_item' => ['child value'] } })
      expect(helper.pivot_facet_in_params?('parent_item', child_item)).to be true
    end
  end

  describe 'pivot_facet_in_params?' do
    it 'checks if pivot facet parent item is not selected' do
      expect(helper.pivot_facet_in_params?('pivot_facet', parent_item)).not_to be true
    end

    it 'checks if pivot facet parent item is selected' do
      allow(helper).to receive_messages(params: { f: { 'parent_item' => ['parent value'] } })
      expect(helper.pivot_facet_in_params?('pivot_facet', parent_item)).to be true
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

    it 'checks if the facet field is selected in the request params' do
      allow(helper).to receive_messages(params: { f: { 'basic-field' => ['x'] } })
      expect(helper).to be_facet_field_in_params('basic-field')
      expect(helper).not_to be_facet_field_in_params('other-field')
    end

    it 'checks if the pivot facet field is selected in the request params' do
      allow(helper).to receive_messages(params: { f: { 'pivot_a' => ['x'] } })
      expect(helper).to be_facet_field_in_params('pivot_a')
      expect(helper).not_to be_facet_field_in_params('pivot_b')
    end

    describe 'pivot_facet_field_in_params?' do
      it 'checks if pivot is not selected' do
        expect(helper).not_to be_pivot_facet_field_in_params(pivot)
      end

      it 'checks if pivot is selected' do
        allow(helper).to receive_messages(params: { f: { 'pivot_a' => ['x'] } })
        expect(helper).to be_pivot_facet_field_in_params(pivot)
      end
    end
  end

  describe 'campus_facet_all_online_links?' do
    context 'when params[:f] is nil' do
      before do
        allow(helper).to receive_messages(params: {})
      end

      it 'returns nothing' do
        expect(helper.campus_facet_all_online_links).to be_nil
      end
    end

    context 'when params[:f] is not filtering on only campus_facet' do
      before do
        allow(helper).to receive_messages(params: { f: { 'campus_facet' => ['Penn State Great Valley'],
                                                         'format' => ['Book'] } })
      end

      it 'returns nothing' do
        expect(helper.campus_facet_all_online_links).to be_nil
      end
    end

    context 'when params[:f] is filtering on only campus_facet' do
      context "when params[:add_all_online] is not 'true'" do
        before do
          allow(helper).to receive_messages(params: { f: { 'campus_facet' => ['Penn State Great Valley'] } })
        end

        it 'returns a link to "Include all online results"' do
          expect(helper.campus_facet_all_online_links).to eq '<a class="btn btn-outline-primary btn-sm mt-2" href="' \
                                                             '?f%5Bcampus_facet%5D%5B%5D=Penn+State+Great+Valley&am' \
                                                             'p;add_all_online=true">Include all online results</a>'
        end
      end

      context "when params[:add_all_online] is 'true'" do
        before do
          allow(helper).to receive_messages(params: { f: { 'campus_facet' => ['Penn State Great Valley'] },
                                                      add_all_online: 'true' })
        end

        it 'returns a link to "Remove online results"' do
          expect(helper.campus_facet_all_online_links).to eq '<a class="btn btn-outline-secondary btn-sm mt-2" hre' \
                                                             'f="?f%5Bcampus_facet%5D%5B%5D=Penn+State+Great+Valley' \
                                                             '">Remove online results</a>'
        end
      end
    end
  end
end
