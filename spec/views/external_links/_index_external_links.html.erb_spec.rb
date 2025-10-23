# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'external_links/index_external_links' do
  context 'when PSU Digital Collectionslinks present' do
    let(:document) { SolrDocument.new(
      {
        full_links_struct: ['{"prefix":"This is a prefix","text":"digital.libraries.psu.edu",' \
                            '"url":"http://digital.libraries.psu.edu","notes":"This is a note"}']
      }
    )}

    it 'renders PSU Digital Collections links correctly' do
      render 'external_links/index_external_links', document: document

      expect(rendered).to have_link('digital.libraries.psu.edu', href: 'http://digital.libraries.psu.edu')
        .and have_text('This is a prefix')
        .and have_text('This is a note')
    end
  end

  context 'when Access Online links present' do
    let(:document) { SolrDocument.new(
      {
        full_links_struct: ['{"prefix":"Pt.1, text version:","text":"purl.access.gpo.gov",' \
                            '"url":"http://purl.access.gpo.gov/GPO/LPS73013","notes":"This is a note"}',
                            '{"prefix":"Pt.1, PDF version:","text":"purl.access.gpo.gov",' \
                            '"url":"http://purl.access.gpo.gov/GPO/LPS73014","notes":""}']
      }
    )}

    it 'renders Access Online links correctly' do
      render 'external_links/index_external_links', document: document

      expect(rendered).to have_link('purl.access.gpo.gov', href: 'http://purl.access.gpo.gov/GPO/LPS73013')
        .and have_link('purl.access.gpo.gov', href: 'http://purl.access.gpo.gov/GPO/LPS73014')
        .and have_text('Pt.1, text version:')
        .and have_text('This is a note')
        .and have_text('Pt.1, PDF version:')
    end
  end

  context 'when Online Version links present' do
    let(:document) { SolrDocument.new(
      {
        partial_links_struct: ['{"prefix":"Pt.1, text version:","text":"purl.access.gpo.gov",' \
                               '"url":"http://purl.access.gpo.gov/GPO/LPS73013","notes":"This is a note"}',
                               '{"prefix":"Pt.1, PDF version:","text":"purl.access.gpo.gov",' \
                               '"url":"http://purl.access.gpo.gov/GPO/LPS73014","notes":""}']
      }
    )}

    it 'does not renders Online Version links' do
      render 'external_links/index_external_links', document: document
      expect(rendered).to have_no_link('purl.access.gpo.gov', href: 'http://purl.access.gpo.gov/GPO/LPS73013')
      expect(rendered).to have_no_link('purl.access.gpo.gov', href: 'http://purl.access.gpo.gov/GPO/LPS73014')
      expect(rendered).not_to include('Pt.1, text version:')
      expect(rendered).not_to include('This is a note')
      expect(rendered).not_to include('Pt.1, PDF version:')
    end
  end

  context 'when Related Resources links present' do
    let(:document) { SolrDocument.new(
      {
        suppl_links_struct: ['{"prefix":"This is a prefix:","text":"related.resource",' \
                             '"url":"http://related.resource","notes":"This is a note"}']
      }
    )}

    it 'does not renders Related Resources links' do
      render 'external_links/index_external_links', document: document
      expect(rendered).to have_no_link('related.resource', href: 'http://related.resource')
      expect(rendered).not_to include('This is a prefix:')
      expect(rendered).not_to include('This is a note')
    end
  end
end
