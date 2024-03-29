# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks do
  describe '#psu_digital_collections_links' do
    it 'returns nil for psu_digital_collections_links when there is no PSU Digital Collections data' do
      document = { full_links_struct: [
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73013"}',
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73014"}',
        '{"text":"resources.libraries.psu.edu","url":"http://resources.libraries.psu.edu/findingaids/2789.htm"}'
      ] }

      psu_digital_collections_links = SolrDocument.new(document).psu_digital_collections_links

      expect(psu_digital_collections_links).not_to be_present
    end

    it 'returns a list of psu_digital_collections_links when there is PSU Digital Collections data' do
      document = { full_links_struct: [
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73013"}',
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73014"}',
        '{"text":"digital.libraries.psu.edu","url":"https://digital.libraries.psu.edu/digital/collection/test"}',
        '{"text":"libraries.psu.edu/collections","url":"https://libraries.psu.edu/collections/test"}',
        '{"text":"libraries.psu.edu/about/collections","url":"https://libraries.psu.edu/about/collections/x"}',
        '{"text":"libraries.psu.edu/test/collections","url":"https://libraries.psu.edu/test/collections/x"}',
        '{"text":"collection1.libraries.psu.edu","url":"https://collection1.libraries.psu.edu/test"}'
      ] }

      psu_digital_collections_links = SolrDocument.new(document).psu_digital_collections_links

      expect(psu_digital_collections_links).to match([{
        prefix: nil,
        text: 'digital.libraries.psu.edu',
        url: 'https://digital.libraries.psu.edu/digital/collection/test',
        notes: nil
      }.with_indifferent_access, {
        prefix: nil,
        text: 'libraries.psu.edu/collections',
        url: 'https://libraries.psu.edu/collections/test',
        notes: nil
      }.with_indifferent_access, {
        prefix: nil,
        text: 'libraries.psu.edu/about/collections',
        url: 'https://libraries.psu.edu/about/collections/x',
        notes: nil
      }.with_indifferent_access, {
        prefix: nil,
        text: 'collection1.libraries.psu.edu',
        url: 'https://collection1.libraries.psu.edu/test',
        notes: nil
      }.with_indifferent_access])
    end

    it 'returns a link with prefix and notes' do
      document = { full_links_struct: [
        '{"prefix":"This is a prefix","text":"digital.libraries.psu.edu",
          "url":"https://digital.libraries.psu.edu/digital/collection/test","notes":"This is a note"}',
        '{"text":"libraries.psu.edu/collections","url":"https://libraries.psu.edu/collections/test"}'
      ] }

      psu_digital_collections_links = SolrDocument.new(document).psu_digital_collections_links

      expect(psu_digital_collections_links).to match([{
        prefix: 'This is a prefix: ',
        text: 'digital.libraries.psu.edu',
        url: 'https://digital.libraries.psu.edu/digital/collection/test',
        notes: ', This is a note'
      }.with_indifferent_access, {
        prefix: nil,
        text: 'libraries.psu.edu/collections',
        url: 'https://libraries.psu.edu/collections/test',
        notes: nil
      }.with_indifferent_access])
    end
  end

  it 'can trim the trailing colon from the prefix and notes if present' do
    document = { full_links_struct: [
      '{
        "prefix":"Prefix:",
        "text":"digital.libraries.psu.edu",
        "url":"https://digital.libraries.psu.edu/digital/collection/test",
        "notes":"Note:"
      }',
      '{
        "prefix":"Prefix",
        "text":"digital.libraries.psu.edu",
        "url":"https://digital.libraries.psu.edu/digital/collection/test",
        "notes":"Note"
      }'
    ] }

    psu_digital_collections_links = SolrDocument.new(document).psu_digital_collections_links

    expect(psu_digital_collections_links).to match([{
      prefix: 'Prefix: ',
      text: 'digital.libraries.psu.edu',
      url: 'https://digital.libraries.psu.edu/digital/collection/test',
      notes: ', Note'
    }.with_indifferent_access, {
      prefix: 'Prefix: ',
      text: 'digital.libraries.psu.edu',
      url: 'https://digital.libraries.psu.edu/digital/collection/test',
      notes: ', Note'
    }.with_indifferent_access])
  end

  describe '#access_online_links' do
    it 'returns nil for access_online_links when there is no external (non-PSU) access online data' do
      document = { full_links_struct: [
        '{"text":"digital.libraries.psu.edu","url":"https://digital.libraries.psu.edu/digital/collection/test"}'
      ] }
      access_online_links = SolrDocument.new(document).access_online_links

      expect(access_online_links).not_to be_present
    end

    it 'returns a list of access_online_links when there is external (non-PSU) data' do
      document = { full_links_struct: [
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73013"}',
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73014"}',
        '{"text":"digital.libraries.psu.edu","url":"https://digital.libraries.psu.edu/digital/collection/test"}',
        '{"text":"libraries.psu.edu/collections","url":"https://libraries.psu.edu/collections/test"}'
      ] }

      access_online_links = SolrDocument.new(document).access_online_links

      expect(access_online_links).to match([{
        prefix: nil,
        text: 'purl.access.gpo.gov',
        url: 'http://purl.access.gpo.gov/GPO/LPS73013',
        notes: nil
      }.with_indifferent_access, {
        prefix: nil,
        text: 'purl.access.gpo.gov',
        url: 'http://purl.access.gpo.gov/GPO/LPS73014',
        notes: nil
      }.with_indifferent_access])
    end

    it 'returns a link with prefix and notes' do
      document = { full_links_struct: [
        '{"prefix":"this is a prefix:","text":"purl.access.gpo.gov",
          "url":"http://purl.access.gpo.gov/GPO/LPS73013","notes":"this is a note"}',
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73014"}'
      ] }

      access_online_links = SolrDocument.new(document).access_online_links

      expect(access_online_links).to match([{
        prefix: 'this is a prefix: ',
        text: 'purl.access.gpo.gov',
        url: 'http://purl.access.gpo.gov/GPO/LPS73013',
        notes: ', this is a note'
      }.with_indifferent_access, {
        prefix: nil,
        text: 'purl.access.gpo.gov',
        url: 'http://purl.access.gpo.gov/GPO/LPS73014',
        notes: nil
      }.with_indifferent_access])
    end
  end

  describe '#psu_special_collections_links' do
    it 'returns nil for psu_special_collections_links when there is no suppl_link data' do
      document = { full_links_struct: [
        '{"text":"View Finding Aid","url":"http://n2t.net/ark:/42409/fa812345"}'
      ] }

      psu_special_collections_links = SolrDocument.new(document).psu_special_collections_links

      expect(psu_special_collections_links).not_to be_present
    end

    it 'returns a list of psu_special_collections_links when there is PSU Special Collections data (ARK urls)' do
      document = { suppl_links_struct: [
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73013"}',
        '{"text":"View Finding Aid","url":"n2t.net/ark:/42409/fa815432"}',
        '{"text":"digital.libraries.psu.edu","url":"https://digital.libraries.psu.edu/digital/collection/test"}',
        '{"text":"libraries.psu.edu/collections","url":"https://libraries.psu.edu/collections/test"}',
        '{"text":"libraries.psu.edu/about/collections","url":"https://libraries.psu.edu/about/collections/x"}',
        '{"text":"libraries.psu.edu/test/collections","url":"https://libraries.psu.edu/test/collections/x"}',
        '{"text":"View Finding Aid","url":"http://n2t.net/ark:/42409/fa812345"}'
      ] }

      psu_special_collections_links = SolrDocument.new(document).psu_special_collections_links

      expect(psu_special_collections_links).to eq([{
        prefix: nil,
        text: 'View Finding Aid',
        url: 'n2t.net/ark:/42409/fa815432',
        notes: nil
      }.with_indifferent_access, {
        prefix: nil,
        text: 'View Finding Aid',
        url: 'http://n2t.net/ark:/42409/fa812345',
        notes: nil
      }.with_indifferent_access])
    end
  end

  describe '#related_resources_links' do
    it 'returns nil for related_resources_links when there is no suppl_link data' do
      document = { full_links_struct: [
        '{"text":"resources.libraries.psu.edu","url":"http://resources.libraries.psu.edu/findingaids/2789.htm"}'
      ] }

      related_resources_links = SolrDocument.new(document).related_resources_links

      expect(related_resources_links).not_to be_present
    end

    it 'returns a list of related_resources_links that disregards PSU Special Collections data (ARK urls)' do
      document = { suppl_links_struct: [
        '{"text":"purl.access.gpo.gov","url":"http://purl.access.gpo.gov/GPO/LPS73013"}',
        '{"text":"View Finding Aid","url":"n2t.net/ark:/42409/fa815432"}',
        '{"text":"libraries.psu.edu/test/collections","url":"https://libraries.psu.edu/test/collections/x"}',
        '{"text":"View Finding Aid","url":"http://n2t.net/ark:/42409/fa812345"}'
      ] }

      related_resources_links = SolrDocument.new(document).related_resources_links

      expect(related_resources_links).to eq([{
        prefix: nil,
        text: 'purl.access.gpo.gov',
        url: 'http://purl.access.gpo.gov/GPO/LPS73013',
        notes: nil
      }.with_indifferent_access, {
        prefix: nil,
        text: 'libraries.psu.edu/test/collections',
        url: 'https://libraries.psu.edu/test/collections/x',
        notes: nil
      }.with_indifferent_access])
    end
  end

  describe '#online_version_links' do
    let(:document) { { partial_links_struct: partial_links_struct } }
    let(:online_version_links) { SolrDocument.new(document).online_version_links }
    let(:partial_links_struct) {
      [
        '{"prefix":"Digitized copy:","text":"libraries.psu.edu","url":"https://libraries.psu.edu/the-digitized-thing","notes":""}',
        '{"prefix":"","text":"IIIF manifest","url":"https://arks.libraries.psu.edu/ark:/42409/ii34w27","notes":"Note:"}'
      ]
    }

    context "when the document's partial_links_struct is nil" do
      let(:partial_links_struct) { nil }

      it 'returns nil' do
        expect(online_version_links).to be_nil
      end
    end

    context "when the document's partial_links_struct is empty" do
      let(:partial_links_struct) { [] }

      it 'returns nil' do
        expect(online_version_links).to be_nil
      end
    end

    context "when the document's partial_links_struct is not empty" do
      it 'returns the parsed links' do
        expect(online_version_links).to eq(
          [
            {
              prefix: 'Digitized copy: ',
              text: 'libraries.psu.edu',
              url: 'https://libraries.psu.edu/the-digitized-thing',
              notes: nil
            }.with_indifferent_access,
            {
              prefix: nil,
              text: 'IIIF manifest',
              url: 'https://arks.libraries.psu.edu/ark:/42409/ii34w27',
              notes: ', Note'
            }.with_indifferent_access
          ]
        )
      end

      context 'when the document has a iiif_manifest_ssim value' do
        let(:document) {
          {
            partial_links_struct: partial_links_struct,
            iiif_manifest_ssim: 'https://arks.libraries.psu.edu/ark:/42409/ii34w27'
          }
        }

        it 'returns the parsed links excluding any IIIF manifest links' do
          expect(online_version_links).to eq(
            [
              {
                prefix: 'Digitized copy: ',
                text: 'libraries.psu.edu',
                url: 'https://libraries.psu.edu/the-digitized-thing',
                notes: nil
              }.with_indifferent_access
            ]
          )
        end
      end
    end
  end
end
