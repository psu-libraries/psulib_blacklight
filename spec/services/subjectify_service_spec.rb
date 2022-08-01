# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubjectifyService do
  let(:service) { described_class.new(subjects) }
  let(:subjects) { ['Renewable energy sources—Research—United States—Finance—History',
                    'Federal aid to research—United States—History'] }

  describe '#content' do
    context 'when subjects include subfields v, x, y, and z' do
      it 'provides links to subject facet search based on hierarchy that includes v, x, y and z' do
        expect(service.content).to eq('<ul><li><a class="search-subject" ' \
                                      'title="Search: Renewable energy sources" href' \
                                      '="/?f[subject_facet][]=Renewable+energy+sources">Renewable energy sources</a><' \
                                      'span class="subject-level">—</span><a class="search-subject" title="Search: Re' \
                                      'newable energy sources—Research" href="/?f[subject_facet][]=Renewable+energy+s' \
                                      'ources%E2%80%94Research">Research</a><span class="subject-level">—</span><a cl' \
                                      'ass="search-subject" title="Search: Renewable energy sources—Research—United S' \
                                      'tates" href="/?f[subject_facet][]=Renewable+energy+sources%E2%80%94Research%E2' \
                                      '%80%94United+States">United States</a><span class="subject-level">—</span><a c' \
                                      'lass="search-subject" title="Search: Renewable energy sources—Research—United ' \
                                      'States—Finance" href="/?f[subject_facet][]=Renewable+energy+sources%E2%80%94Re' \
                                      'search%E2%80%94United+States%E2%80%94Finance">Finance</a><span class="subject-' \
                                      'level">—</span><a class="search-subject" title="Search: Renewable energy sourc' \
                                      'es—Research—United States—Finance—History" href="/?f[subject_facet][]=Renewabl' \
                                      'e+energy+sources%E2%80%94Research%E2%80%94United+States%E2%80%94Finance%E2%80%' \
                                      '94History">History</a></li><li><a class="search-subject" title="Search: Federa' \
                                      'l aid to research" href="/?f[subject_facet][]=Federal+aid+to+research">Federa' \
                                      'l aid to research</a><span class="subject-level">—</span><a class="search-subj' \
                                      'ect" title="Search: Federal aid to research—United States" href="/?f[subject_f' \
                                      'acet][]=Federal+aid+to+research%E2%80%94United+States">United States</a><spa' \
                                      'n class="subject-level">—</span><a class="search-subject" title="Search: Feder' \
                                      'al aid to research—United States—History" href="/?f[subject_facet][]=Federal+a' \
                                      'id+to+research%E2%80%94United+States%E2%80%94History">History</a></li></ul>')
      end
    end
  end
end
