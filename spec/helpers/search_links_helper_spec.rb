# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchLinksHelper, type: :helper do
  describe '#other_subjectify' do
    let (:field_data) { ['Power Amplifiers',
                         'Research',
                         'Fluid Mechanics and Thermodynamics'] }
    let (:other_subjects_doc) { { value: field_data } }

    it 'provides links to general subject search based on the given other subjects' do
      full_subject = other_subjectify other_subjects_doc
      expect(full_subject).to eq('<ul><li><a class="search-subject" title="Search: Power Amplifiers" ' \
                                 'href="/?search_field=subject&amp;q=Power+Amplifiers">Power Amplifiers' \
                                 '</a></li><li><a class="search-subject" title="Search: Research" ' \
                                 'href="/?search_field=subject&amp;q=Research">Research</a></li><li>' \
                                 '<a class="search-subject" title="Search: Fluid Mechanics and Thermodynamics" ' \
                                 'href="/?search_field=subject&amp;q=Fluid+Mechanics+and+Thermodynamics">' \
                                 'Fluid Mechanics and Thermodynamics</a></li></ul>')
    end
  end

  describe '#genre_links' do
    let (:field_data) { ['Film adaptations', 'Feature Films'] }
    let (:genre_doc) { { value: field_data } }

    it 'assembles an unordered list of links to genre search' do
      links = genre_links genre_doc
      expect(links).to eq '<ul><li><a href="/?f[genre_full_facet][]=Film+adaptations">Film adaptations</a>' \
                          '</li><li><a href="/?f[genre_full_facet][]=Feature+Films">Feature Films</a></li></ul>'
    end
  end

  describe '#series_links' do
    let (:series_data) { ['Lecture Notes in Electrical Engineering, 1876-1100 ; 554'] }
    let (:series_title_strict_data) { ['Lecture Notes in Electrical Engineering'] }

    context 'when there is a series value and a strict version of the series title' do
      let (:link_doc) { { value: series_data, document: { series_title_strict_tsim: series_title_strict_data } } }

      it 'assembles the link correctly' do
        link = series_links link_doc
        expect(link).to eql '<ul><li><a class="search-series" title="Search: Lecture Notes in ' \
                            'Electrical Engineering" ' \
                            'href="/?search_field=series&amp;q=Lecture+Notes+in+Electrical+Engineering">' \
                            'Lecture Notes in Electrical Engineering, 1876-1100 ; 554</a></li></ul>'
      end
    end

    context 'when there is a series value but no strict version of the series title' do
      let (:link_doc) { { value: series_data, document: {} } }

      it 'assembles the link correctly' do
        link = series_links link_doc
        link_expect = '<ul><li><a class="search-series" title="Search: Lecture Notes in Electrical Engineering, ' \
                      '1876-1100 ; 554" href="/?search_field=series&amp;q=Lecture+Notes+in+Electrical+Engineering' \
                      '%2C+1876-1100+%3B+554">Lecture Notes in Electrical Engineering, 1876-1100 ; 554</a></li></ul>'
        expect(link).to eql link_expect
      end
    end

    context 'when there are multiple series values and strict versions of the series title' do
      let (:link_doc) { { value: series_data, document: { series_title_strict_tsim: series_title_strict_data } } }

      before do
        series_data << 'Series Title 2, 1999, abc123'
        series_title_strict_data << 'Series Title 2'
      end

      it 'assembles the link correctly' do
        link = series_links link_doc
        link_expect = '<ul><li><a class="search-series" title="Search: Lecture Notes in Electrical Engineering" ' \
                      'href="/?search_field=series&amp;q=Lecture+Notes+in+Electrical+Engineering">' \
                      'Lecture Notes in Electrical Engineering, 1876-1100 ; 554</a></li><li><a class="search-series" ' \
                      'title="Search: Series Title 2" href="/?search_field=series&amp;q=Series+Title+2">Series ' \
                      'Title 2, 1999, abc123</a></li></ul>'
        expect(link).to eql link_expect
      end
    end
  end

  describe '#title_links' do
    let (:field_data) { ['Some Title', 'Another Title'] }
    let (:title_doc) { { value: field_data } }

    it 'assembles a link to title search and puts it in a list' do
      links = title_links title_doc
      expect(links).to match '<ul><li><a href="/?search_field=title&amp;q=Some+Title">Some Title</a></li><li>' \
                             '<a href="/?search_field=title&amp;q=Another+Title">Another Title</a></li></ul>'
    end
  end
end
