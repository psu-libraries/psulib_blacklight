# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubjectifyService do
  let(:service) { described_class.new(subjects) }
  let(:subjects) { ['Renewable energy sources—Research—United States—Finance—History',
                    'Federal aid to research—United States—History'] }

  describe '#content' do
    context 'when subjects include subfields v, x, y, and z' do
      it 'provides links to subject facet search based on hierarchy that includes v, x, y and z' do
        expect(service.content).to eq('<ul><li><a class="search-subject" title="Search: Renewable energy sources" href'\
                                      '="/?f[subject_facet][]=Renewable+energy+sources">Renewable energy sources</a><s'\
                                      'pan class="subject-level">—</span><a class="search-subject" title="Search: Rene'\
                                      'wable energy sources—Research" href="/?f[subject_facet][]=Renewable+energy+sour'\
                                      'ces%E2%80%94Research">Research</a><span class="subject-level">—</span><a class='\
                                      '"search-subject" title="Search: Renewable energy sources—Research—United States'\
                                      '" href="/?f[subject_facet][]=Renewable+energy+sources%E2%80%94Research%E2%80%94'\
                                      'United+States">United States</a><span class="subject-level">—</span><a class="s'\
                                      'earch-subject" title="Search: Renewable energy sources—Research—United States—F'\
                                      'inance" href="/?f[subject_facet][]=Renewable+energy+sources%E2%80%94Research%E2'\
                                      '%80%94United+States%E2%80%94Finance">Finance</a><span class="subject-level">—</'\
                                      'span><a class="search-subject" title="Search: Renewable energy sources—Research'\
                                      '—United States—Finance—History" href="/?f[subject_facet][]=Renewable+energy+sou'\
                                      'rces%E2%80%94Research%E2%80%94United+States%E2%80%94Finance%E2%80%94History">Hi'\
                                      'story</a></li><li><a class="search-subject" title="Search: Federal aid to resea'\
                                      'rch" href="/?f[subject_facet][]=Federal+aid+to+research">Federal aid to researc'\
                                      'h</a><span class="subject-level">—</span><a class="search-subject" title="Searc'\
                                      'h: Federal aid to research—United States" href="/?f[subject_facet][]=Federal+ai'\
                                      'd+to+research%E2%80%94United+States">United States</a><span class="subject-leve'\
                                      'l">—</span><a class="search-subject" title="Search: Federal aid to research—Uni'\
                                      'ted States—History" href="/?f[subject_facet][]=Federal+aid+to+research%E2%80%94'\
                                      'United+States%E2%80%94History">History</a></li></ul>')
      end
    end
  end
end
