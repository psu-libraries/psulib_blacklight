# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#catalog_link' do
    let (:field_data) { ['{"catkey": "355035", '\
                          '"linktext": "The high-caste Hindu woman / With introduction by Rachel L. Bodley"}'] }
    let (:catalog_link_doc) { { value: field_data } }

    context 'when there is a single value for a link field' do
      it 'assembles a link' do
        link_text = '<a href="/catalog/355035">The high-caste Hindu woman / With introduction by Rachel L. Bodley</a>'
        link = catalog_link catalog_link_doc
        expect(link).to eql link_text
      end
    end
  end

  SEPARATOR = '—'
  describe '#subjectify' do
    let (:field_data) { ['Renewable energy sources—Research—United States—Finance—History',
                         'Federal aid to research—United States—History'] }
    let (:subjects_document) do
      {
        subject_display_ssm: field_data
      }
    end
    let(:field_config) do
      {
        field: :subject_display_ssm,
        document: subjects_document
      }.with_indifferent_access
    end

    context 'when subjects include subfields v, x, y, and z' do
      it 'provides links to subject facet search based on hierarchy' do
        full_subject = subjectify field_config
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
end
