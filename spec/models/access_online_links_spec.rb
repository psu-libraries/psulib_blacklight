# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks do
  describe '#access_online_links' do
    it 'returns nil for psu_digital_collections_links when there is no PSU data' do
      document = { 'full_links_struct': [
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73013"}',
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73014"}'
      ] }

      psu_digital_collections_links = SolrDocument.new(document).psu_digital_collections_links

      expect(psu_digital_collections_links).not_to be_present
    end

    it 'returns a list of psu_digital_collections_links when there is PSU data' do
      document = { 'full_links_struct': [
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73013"}',
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73014"}',
        '{"text":"digital.libraries.psu.edu","url":"https://digital.libraries.psu.edu/digital/collection/test"}',
        '{"text":"libraries.psu.edu/collections","url":"https://libraries.psu.edu/collections/test"}'
      ] }

      psu_digital_collections_links = SolrDocument.new(document).psu_digital_collections_links

      expect(psu_digital_collections_links).to match([{
        text: 'digital.libraries.psu.edu',
        url: 'https://digital.libraries.psu.edu/digital/collection/test'
      }.with_indifferent_access, {
        text: 'libraries.psu.edu/collections',
        url: 'https://libraries.psu.edu/collections/test'
      }.with_indifferent_access])
    end

    it 'returns nil for access_online_links when there is no external (non-PSU) access online data' do
      document = { 'full_links_struct': [
        '{"text":"digital.libraries.psu.edu","url":"https://digital.libraries.psu.edu/digital/collection/test"}'
      ] }
      access_online_links = SolrDocument.new(document).access_online_links

      expect(access_online_links).not_to be_present
    end

    it 'returns a list of access_online_links when there is external (non-PSU) data' do
      document = { 'full_links_struct': [
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73013"}',
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73014"}',
        '{"text":"digital.libraries.psu.edu","url":"https://digital.libraries.psu.edu/digital/collection/test"}',
        '{"text":"libraries.psu.edu/collections","url":"https://libraries.psu.edu/collections/test"}'
      ] }

      access_online_links = SolrDocument.new(document).access_online_links

      expect(access_online_links).to match([{
        'text': 'purl.access.gpo.gov',
        'url': 'http://purl.access.gpo.gov/GPO/LPS73013'
      }.with_indifferent_access, {
        'text': 'purl.access.gpo.gov',
        'url': 'http://purl.access.gpo.gov/GPO/LPS73014'
      }.with_indifferent_access])
    end
  end
end
