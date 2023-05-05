# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentRis do
  let(:service) { described_class.new(document) }
  let(:document) { [{ 'response' =>
    { 'numFound' => 1,
      'start' => 0,
      'numFoundExact' => true,
      'docs' =>
      [{ 'id' => '24053587',
         'isbn_valid_ssm' => ['9781524763138', '1524763136'],
         'title_245ab_tsim' => ['Becoming'],
         'author_tsim' => ['Obama, Michelle, 1964-'],
         'author_addl_tsim' => ['Additional Author'],
         'publication_display_ssm' => ['New York : Crown, [2018]'],
         'edition_display_ssm' => ['First edition.'],
         'pub_date_illiad_ssm' => ['2018'],
         'publisher_name_ssm' => ['Crown'],
         'publication_place_ssm' => ['New York'],
         'format' => ['Book'] }] } }]}
  let(:ris) { "TY  - BOOK\r\n" \
    "TI  - Becoming\r\n" \
    "A1  - Obama, Michelle, 1964-\r\n" \
    "A2  - Additional Author\r\n" \
    "PY  - 2018\r\n" \
    "PP  - New York\r\n" \
    "PB  - Crown\r\n" \
    "SN  - 9781524763138\r\n" \
    "ET  - First edition.\r\n" \
    "Y2  - #{Time.now.strftime('%Y-%m-%d')}\r\n" \
    "UR  - https://catalog.libraries.psu.edu/catalog/24053587\r\n" \
    "ER  -\r\n" }

  it 'formats the solr document into an RIS file' do
    expect(service.ris_to_string).to eq ris
  end
end
