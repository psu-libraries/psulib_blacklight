# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogHelper, type: :helper do
  describe '#bound_info' do
    let (:field_data) { ['{"bound_catkey": "355035", '\
                          '"bound_title": "The high-caste Hindu woman / With introduction by Rachel L. Bodley",'\
                          '"bound_format": "Microfilm, Microfiche, etc.", '\
                          '"bound_callnumber": "AY67.N5W7 1922-24"}'] }
    let (:just_title_data) { ['{"bound_title": "Bound in: The Tale of The Blah Blah Blah"}'] }
    let (:bound_info_doc) { { value: field_data } }
    let (:bound_info_lite_doc) { { value: just_title_data } }

    context 'when there is a full compliment of field data about bound with' do
      it 'assembles all the info correctly including a link' do
        link_text = '<span>AY67.N5W7 1922-24 (Microfilm, Microfiche, etc.) bound in <a href="/catalog/355035">The high'\
                    '-caste Hindu woman / With introduction by Rachel L. Bodley</a></span>'
        link = bound_info bound_info_doc
        expect(link).to eql link_text
      end
    end

    context 'when there is only a title (subfield a)' do
      it 'just prints that subfield' do
        expect(bound_info(bound_info_lite_doc)).to eql '<span>Bound in: The Tale of The Blah Blah Blah</span>'
      end
    end

    context 'when bound format is empty' do
      let (:field_data) { ['{"bound_catkey": "355035", '\
                            '"bound_title": "The high-caste Hindu woman / With introduction by Rachel L. Bodley",'\
                            '"bound_format": "", '\
                            '"bound_callnumber": "AY67.N5W7 1922-24"}'] }

      it 'does not display empty parentheses' do
        link_text = '<span>AY67.N5W7 1922-24 bound in <a href="/catalog/355035">The high'\
                    '-caste Hindu woman / With introduction by Rachel L. Bodley</a></span>'
        link = bound_info bound_info_doc
        expect(link).to eql link_text
      end
    end
  end

  describe '#subjectify' do
    let (:field_data) { ['Renewable energy sources—Research—United States—Finance—History',
                         'Federal aid to research—United States—History'] }
    let (:subjects_doc) { { value: field_data } }

    context 'when subjects include subfields v, x, y, and z' do
      it 'provides links to subject facet search based on hierarchy that includes v, x, y and z' do
        stub_const 'SEPARATOR', '—'
        full_subject = subjectify subjects_doc
        expect(full_subject).to include('<a class="search-subject" title="Search: Renewable energy sources—Research—Un'\
                                        'ited States—Finance—History" href="/?f[subject_facet][]=Renewable+energy+sour'\
                                        'ces%E2%80%94Research%E2%80%94United+States%E2%80%94Finance%E2%80%94History">H'\
                                        'istory</a></li>')
      end
    end
  end

  describe '#other_subjectify' do
    let (:field_data) { ['Power Amplifiers',
                         'Research',
                         'Fluid Mechanics and Thermodynamics'] }
    let (:other_subjects_doc) { { value: field_data } }

    it 'provides links to general subject search based on the given other subjects' do
      full_subject = other_subjectify other_subjects_doc
      expect(full_subject).to eq('<ul><li><a class="search-subject" title="Search: Power Amplifiers"'\
                                 ' href="/?search_field=subject&amp;q=Power+Amplifiers">Power Amplifiers'\
                                 '</a></li><li><a class="search-subject" title="Search: Research"'\
                                 ' href="/?search_field=subject&amp;q=Research">Research</a></li><li>'\
                                 '<a class="search-subject" title="Search: Fluid Mechanics and Thermodynamics"'\
                                 ' href="/?search_field=subject&amp;q=Fluid+Mechanics+and+Thermodynamics">'\
                                 'Fluid Mechanics and Thermodynamics</a></li></ul>')
    end
  end

  describe '#genre_links' do
    let (:field_data) { ['Film adaptations', 'Feature Films'] }
    let (:genre_doc) { { value: field_data } }

    it 'assembles an unordered list of links to genre search' do
      links = genre_links genre_doc
      expect(links).to eq '<ul><li><a href="/?f[genre_full_facet][]=Film+adaptations">Film adaptations</a></li><li><a '\
                          'href="/?f[genre_full_facet][]=Feature+Films">Feature Films</a></li></ul>'
    end
  end

  describe '#newline_format' do
    let (:note_doc) { { value: ['Note 1', 'Note 2'] } }

    it 'displays the notes separated by line breaks' do
      notes = newline_format note_doc
      expect(notes).to eq '<span>Note 1<br>Note 2</span>'
    end
  end

  describe '#display_duration' do
    let (:field_data) { { value: ['221850'] } }

    context 'when there is a duration in NNNNNN' do
      it 'changes it to HH:MM:SS' do
        duration_values = display_duration field_data
        expect(duration_values).to eql ['22:18:50']
      end
    end
  end

  describe '#generic_link' do
    let (:field_data) { ['{"text":"usacac.army.mil","url":"http://usacac.army.mil/CAC2/MilitaryReview/mrpast2.asp"}'] }
    let (:link_doc) { { value: field_data } }

    context 'when there is a single url and text pair' do
      it 'assembles all the link correctly' do
        link = generic_link link_doc
        expect(link).to eql '<span><a href="http://usacac.army.mil/CAC2/MilitaryReview/mrpast2.asp">usacac.arm'\
                            'y.mil</a></span>'
      end
    end
  end

  describe '#series_links' do
    let (:series_data) { ['Lecture Notes in Electrical Engineering, 1876-1100 ; 554'] }
    let (:series_title_strict_data) { ['Lecture Notes in Electrical Engineering'] }

    context 'when there is a series value and a strict version of the series title' do
      let (:link_doc) { { value: series_data, document: { series_title_strict_tsim: series_title_strict_data } } }

      it 'assembles the link correctly' do
        link = series_links link_doc
        expect(link).to eql '<ul><li><a class="search-series" title="Search: Lecture Notes in Electrical '\
                                     'Engineering" '\
                                     'href="/?search_field=series&amp;q=Lecture+Notes+in+Electrical+Engineering">'\
                                     'Lecture Notes in Electrical Engineering, 1876-1100 ; 554</a></li></ul>'
      end
    end

    context 'when there is a series value but no strict version of the series title' do
      let (:link_doc) { { value: series_data, document: {} } }

      it 'assembles the link correctly' do
        link = series_links link_doc
        link_expect = '<ul><li><a class="search-series" title="Search: Lecture Notes in Electrical Engineering, 1876-11'\
                      '00 ; 554" href="/?search_field=series&amp;q=Lecture+Notes+in+Electrical+Engineering%2C+1876-110'\
                      '0+%3B+554">Lecture Notes in Electrical Engineering, 1876-1100 ; 554</a></li></ul>'
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
        link_expect = '<ul><li><a class="search-series" title="Search: Lecture Notes in Electrical Engineering"'\
                      ' href="/?search_field=series&amp;q=Lecture+Notes+in+Electrical+Engineering">'\
                      'Lecture Notes in Electrical Engineering, 1876-1100 ; 554</a></li><li><a class="search-series"'\
                      ' title="Search: Series Title 2" href="/?search_field=series&amp;q=Series+Title+2">Series '\
                      'Title 2, 1999, abc123</a></li></ul>'
        expect(link).to eql link_expect
      end
    end
  end

  describe '#render_thumbnail' do
    let (:document) { { format: ['Book'] } }

    context 'when a record has no bibkeys present' do
      it 'format icon is the default thumbnail' do
        thumbnail = render_thumbnail document
        expect(thumbnail).to have_css '.faspsu-book'
      end
    end

    context 'when a record has bibkeys' do
      let (:document) { { format: ['Book'], isbn_valid_ssm: ['1818181818'] } }

      it 'markup sent back containing those bibkeys' do
        thumbnail = render_thumbnail document
        expect(thumbnail).to include 'data-isbn="[&quot;1818181818&quot;]"'
      end
    end
  end

  describe '#oclc_number' do
    let (:document) { { oclc_number_ssim: ['123456'] } }

    it 'returns the OCLC number' do
      oclc_num = oclc_number document

      expect(oclc_num).to be '123456'
    end
  end

  describe '#title_links' do
    let (:field_data) { ['Some Title', 'Another Title'] }
    let (:title_doc) { { value: field_data } }

    it 'assembles a link to title search and puts it in a list' do
      links = title_links title_doc
      expect(links).to match '<ul><li><a href="/?search_field=title&amp;q=Some+Title">Some Title</a></li><li><a href="'\
                             '/?search_field=title&amp;q=Another+Title">Another Title</a></li></ul>'
    end
  end

  describe '#marc_record_details' do
    let (:document) { { id: 12345 } }

    it 'adds a link to the marc record details (aka "librarian view")' do
      marc_record_details = marc_record_details document
      expect(marc_record_details).to include '<a id="marc_record_link" '\
                                              "href=\"/catalog/#{document[:id]}/marc_view\">View MARC record</a>"
      expect(marc_record_details).to include "catkey: #{document[:id]}"
    end
  end

  describe '#get_first_only' do
    let(:options) { { value: [{ hathidata_struct: [{ text: 'Check out digital copy through HathiTrust',
                                                     url: 'http://example.com',
                                                     additional_text: 'By blah blah blah.' }] }] }}

    it 'returns the first value of the value array' do
      expect(get_first_only(options)).not_to be_a_kind_of Array
    end
  end
end
