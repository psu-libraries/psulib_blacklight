# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'browse/index', type: :view do
  let(:shelf_list) { ShelfListPresenter.new }

  let(:doc1) {
    SolrDocument.new({
                       id: '123',
                       call_number_ssm: ['abc'],
                       title_display_ssm: ['book 1'],
                       library_facet: ['library 1'],
                       publication_display_ssm: ['pub info 1']
                     })
  }

  let(:doc2) {
    SolrDocument.new({
                       id: '456',
                       call_number_ssm: ['def'],
                       title_display_ssm: ['book 2'],
                       library_facet: ['library 2'],
                       publication_display_ssm: ['pub info 2']
                     })
  }

  let(:doc3) {
    SolrDocument.new({
                       id: '789',
                       call_number_ssm: ['ghi'],
                       title_display_ssm: ['book 3'],
                       library_facet: ['library 3'],
                       publication_display_ssm: ['pub info 3']
                     })
  }

  context 'when the user is not searching for a particular call number' do
    before do
      allow(ShelfList).to receive(:call).and_return({
                                                      before: [],
                                                      after: [doc1, doc2, doc3]
                                                    })

      assign(:shelf_list, shelf_list)
      render
    end

    it 'does not show an active row' do
      expect(rendered).not_to have_selector '.table-primary'
    end

    it 'renders the correct table data' do
      expect(rendered).to have_link('abc', href: '/catalog/123')
      expect(rendered).to have_selector 'tr:nth-child(1) td:nth-child(2)',
                                        exact_text: 'book 1'
      expect(rendered).to have_selector 'tr:nth-child(1) td:nth-child(3)',
                                        exact_text: 'library 1'
      expect(rendered).to have_selector 'tr:nth-child(1) td:nth-child(4)',
                                        exact_text: 'pub info 1'

      expect(rendered).to have_link('def', href: '/catalog/456')
      expect(rendered).to have_selector 'tr:nth-child(2) td:nth-child(2)',
                                        exact_text: 'book 2'
      expect(rendered).to have_selector 'tr:nth-child(2) td:nth-child(3)',
                                        exact_text: 'library 2'
      expect(rendered).to have_selector 'tr:nth-child(2) td:nth-child(4)',
                                        exact_text: 'pub info 2'

      expect(rendered).to have_link('ghi', href: '/catalog/789')
      expect(rendered).to have_selector 'tr:nth-child(3) td:nth-child(2)',
                                        exact_text: 'book 3'
      expect(rendered).to have_selector 'tr:nth-child(3) td:nth-child(3)',
                                        exact_text: 'library 3'
      expect(rendered).to have_selector 'tr:nth-child(3) td:nth-child(4)',
                                        exact_text: 'pub info 3'
    end
  end

  # TODO: implement these tests properly
  context 'when the user is searching for a particular call number' do
    before do
      allow(ShelfList).to receive(:call).and_return({
                                                      before: [],
                                                      after: [doc1, doc2, doc3]
                                                    })

      assign(:shelf_list, shelf_list)
      render
    end

    context 'when there is an exact match' do
      let(:shelf_list) { ShelfListPresenter.new(nearby: 'def') }

      xit 'shows an active row' do
        expect(rendered).to have_selector '.table-primary'
      end
    end

    context 'when there is not an exact match' do
      let(:shelf_list) { ShelfListPresenter.new(nearby: 'bbb') }

      xit 'shows an active row' do
        expect(rendered).to have_selector '.table-primary'
      end
    end

    xit 'renders the correct table data' do
      expect(rendered).to have_link('abc', href: '/catalog/123')
      expect(rendered).to have_selector 'tr:nth-child(1) td:nth-child(2)',
                                        exact_text: 'book 1'
      expect(rendered).to have_selector 'tr:nth-child(1) td:nth-child(3)',
                                        exact_text: 'library 1'
      expect(rendered).to have_selector 'tr:nth-child(1) td:nth-child(4)',
                                        exact_text: 'pub info 1'

      expect(rendered).to have_link('def', href: '/catalog/456')
      expect(rendered).to have_selector 'tr:nth-child(2) td:nth-child(2)',
                                        exact_text: 'book 2'
      expect(rendered).to have_selector 'tr:nth-child(2) td:nth-child(3)',
                                        exact_text: 'library 2'
      expect(rendered).to have_selector 'tr:nth-child(2) td:nth-child(4)',
                                        exact_text: 'pub info 2'

      expect(rendered).to have_link('ghi', href: '/catalog/789')
      expect(rendered).to have_selector 'tr:nth-child(3) td:nth-child(2)',
                                        exact_text: 'book 3'
      expect(rendered).to have_selector 'tr:nth-child(3) td:nth-child(3)',
                                        exact_text: 'library 3'
      expect(rendered).to have_selector 'tr:nth-child(3) td:nth-child(4)',
                                        exact_text: 'pub info 3'
    end
  end
end
