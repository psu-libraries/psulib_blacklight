# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PsulFacetItemComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(psul_facet_item: facet_item)) }
  let(:selected_span) { rendered.css('span.selected').first }
  let(:link) { rendered.css('a.facet-select').first }

  context 'when the facet item has a tooltip' do
    context 'when the facet item is selected' do
      let(:facet_item) do
        instance_double(
          Blacklight::FacetItemPresenter,
          facet_config: Blacklight::Configuration::FacetField.new,
          facet_field: 'access_facet',
          label: 'Online',
          hits: 10,
          href: '/catalog?f=x',
          selected?: true
        )
      end

      specify do
        expect(link).to be_nil
        expect(selected_span.text).to eq('Online')
        expect(selected_span.attributes['title'].value).to eq(I18n.t('blackcat.facet_tooltips.access_facet.online'))
      end
    end

    context 'when the facet item is unselected' do
      let(:facet_item) do
        instance_double(
          Blacklight::FacetItemPresenter,
          facet_config: Blacklight::Configuration::FacetField.new,
          facet_field: 'access_facet',
          label: 'Online',
          hits: 10,
          href: '/catalog?f=x',
          selected?: false
        )
      end

      specify do
        expect(selected_span).to be_nil
        expect(link.text).to eq('Online')
        expect(link.attributes['title'].value).to eq(I18n.t('blackcat.facet_tooltips.access_facet.online'))
      end
    end
  end

  context 'when the facet item does not have a tooltip' do
    context 'when the facet item is selected' do
      let(:facet_item) do
        instance_double(
          Blacklight::FacetItemPresenter,
          facet_config: Blacklight::Configuration::FacetField.new,
          facet_field: 'access_facet',
          label: 'In the Library',
          hits: 10,
          href: '/catalog?f=x',
          selected?: true
        )
      end

      specify do
        expect(link).to be_nil
        expect(selected_span.text).to eq('In the Library')
        expect(selected_span.attributes['title']).to be_nil
      end
    end

    context 'when the facet item is unselected' do
      let(:facet_item) do
        instance_double(
          Blacklight::FacetItemPresenter,
          facet_config: Blacklight::Configuration::FacetField.new,
          facet_field: 'access_facet',
          label: 'In the Library',
          hits: 10,
          href: '/catalog?f=x',
          selected?: false
        )
      end

      specify do
        expect(selected_span).to be_nil
        expect(link.text).to eq('In the Library')
        expect(link.attributes['title']).to be_nil
      end
    end
  end
end
