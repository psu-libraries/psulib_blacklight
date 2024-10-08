# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogHelper do
  describe '#bound_info' do
    let (:field_data) { ['{"bound_catkey": "355035", ' \
                         '"bound_title": "The high-caste Hindu woman / With introduction by Rachel L. Bodley",' \
                         '"bound_format": "Microfilm, Microfiche, etc.", ' \
                         '"bound_callnumber": "AY67.N5W7 1922-24"}'] }
    let (:just_title_data) { ['{"bound_title": "Bound in: The Tale of The Blah Blah Blah"}'] }
    let (:bound_info_doc) { { value: field_data } }
    let (:bound_info_lite_doc) { { value: just_title_data } }

    context 'when there is a full compliment of field data about bound with' do
      it 'assembles all the info correctly including a link' do
        link_text = '<span>AY67.N5W7 1922-24 (Microfilm, Microfiche, etc.) bound in <a href="/catalog/355035">The ' \
                    'high-caste Hindu woman / With introduction by Rachel L. Bodley</a></span>'
        link = bound_info bound_info_doc
        expect(link).to eql link_text
      end
    end

    context 'when there is only a title (subfield a)' do
      it 'just prints that subfield' do
        expect(bound_info(bound_info_lite_doc)).to eql '<span>Bound in: The Tale of The Blah Blah Blah' \
                                                       '</span>'
      end
    end

    context 'when bound format is empty' do
      let (:field_data) { ['{"bound_catkey": "355035", ' \
                           '"bound_title": "The high-caste Hindu woman / With introduction by Rachel L. Bodley",' \
                           '"bound_format": "", ' \
                           '"bound_callnumber": "AY67.N5W7 1922-24"}'] }

      it 'does not display empty parentheses' do
        link_text = '<span>AY67.N5W7 1922-24 bound in <a href="/catalog/355035">The high' \
                    '-caste Hindu woman / With introduction by Rachel L. Bodley</a></span>'
        link = bound_info bound_info_doc
        expect(link).to eql link_text
      end
    end
  end

  describe '#subjectify' do
    let (:field_data) { ['Civilization'] }
    let (:subjects_doc) { { value: field_data } }

    it 'provides links generated by SubjectifyService' do
      full_subject = subjectify subjects_doc
      expect(full_subject).to eq('<ul><li><a class="search-subject" title="Search: Civilization" ' \
                                 'href="/?f[subject_facet][]=Civilization">Civilization</a></li></ul>')
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
        expect(link).to eql '<span><a href="http://usacac.army.mil/CAC2/MilitaryReview/mrpast2.asp">' \
                            'usacac.army.mil</a></span>'
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

  describe '#marc_record_details' do
    let (:document) { { id: 12345 } }

    it 'adds a link to the marc record details (aka "librarian view")' do
      marc_record_details = marc_record_details document
      expect(marc_record_details).to include '<a id="marc_record_link" ' \
                                             "href=\"/catalog/#{document[:id]}/marc_view\">View MARC record</a>"
      expect(marc_record_details).to include "catkey: #{document[:id]}"
    end
  end
end
