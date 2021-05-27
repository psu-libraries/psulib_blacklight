# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PsulConstraintLayoutComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(**params))
  end

  describe 'for simple display' do
    let(:params) do
      { label: 'my label', value: 'my value' }
    end

    it 'renders label and value' do
      expect(rendered).to have_selector('span.applied-filter.constraint') do |s|
        expect(s).to have_css('span.constraint-value')
        expect(s).not_to have_css('a.constraint-value')
        expect(s).not_to have_css('span.btn.btn-outline-secondary.constraint-value')
        expect(s).to have_selector 'span.filter-name', text: 'my label'
        expect(s).to have_selector 'span.filter-value', text: 'my value'
      end
    end

    it 'not a button group' do
      expect(rendered).not_to have_selector('span.btn-group.applied-filter.constraint')
    end
  end

  describe 'with remove link' do
    let(:params) do
      { label: 'my label', value: 'my value', remove_path: 'http://remove' }
    end

    it 'includes remove link' do
      expect(rendered).to have_selector('span.applied-filter') do |s|
        expect(s).to have_selector(".remove[href='http://remove']")
      end
    end

    it 'has an accessible remove label' do
      expect(rendered).to have_selector('.remove') do |s|
        expect(s).to have_selector('.visually-hidden', text: 'Remove constraint my label: my value')
      end
    end

    it 'not a button group' do
      expect(rendered).to have_selector('span.applied-filter') do |s|
        expect(s).to have_css('a.remove')
        expect(s).not_to have_css('a.btn.btn-outline-secondary')
      end
    end
  end
end
