# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#bound_link' do

    let (:field_data) { ['{"catkey": "355035", "linktext": '\
        '"The high-caste Hindu woman / With introduction by Rachel L. Bodley", "format": '\
        '"Microfilm, Microfiche, etc.", "callnumber": "AY67.N5W7 1922-24"}'] }
    let (:bound_link_doc) { { value: field_data } }

    context 'when there is a single value for a link field' do
      it 'assembles a link' do
        link_text = '<span>AY67.N5W7 1922-24 (Microfilm, Microfiche, etc.) bound in <a href="/catalog/355035">The high'\
                    '-caste Hindu woman / With introduction by Rachel L. Bodley</a></span>'
        link = bound_link bound_link_doc
        expect(link).to eql link_text
      end
    end
  end

  SEPARATOR = '—'
  describe '#subjectify' do
    let (:field_data) { ['Renewable energy sources—Research—United States—Finance—History',
                         'Federal aid to research—United States—History'] }
    let (:subjects_doc) { { value: field_data } }

    context 'when subjects include subfields v, x, y, and z' do
      it 'provides links to subject facet search based on hierarchy' do
        full_subject = subjectify subjects_doc
        sub_subjects = []
        field_data.each do |subject|
          sub_subjects << subject.split(SEPARATOR)
        end
        field_data.each_with_index do |subject, i|
          sub_subjects[i].each do |component|
            c = Regexp.escape(component)
            expect(full_subject[i].include?('class="search-subject" '\
                                        "title=\"Search: #{subject[/.*#{c}/]}\" "\
                                        "href=\"/?f%5Bsubject_facet%5D%5B%5D=#{CGI.escape subject[/.*#{c}/]}\">"\
                                        "#{component}</a>")).to eq true
          end
        end
      end
    end
  end

  describe '#genre_links' do
    let (:field_data) { ['Film adaptations', 'Feature Films'] }
    let (:genre_doc) { { value: field_data } }

    it 'assembles a link to genre search' do
      links = genre_links genre_doc
      expect(links).to include '<a href="/?f%5Bgenre_full_facet_ssim%5D%5B%5D=Film+adaptations">Film adaptations</a>'
      expect(links).to include '<a href="/?f%5Bgenre_full_facet_ssim%5D%5B%5D=Feature+Films">Feature Films</a>'
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
end
