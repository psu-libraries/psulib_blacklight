# frozen_string_literal: true

require 'rsolr'
require 'json'

namespace :blackcat do
  namespace :solr do
    desc 'Posts fixtures to Solr'
    task :index do
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      docs = JSON.parse(File.read('spec/fixtures/current_fixtures.json'))
      solr.add docs
      solr.update data: '<commit/>', headers: { 'Content-Type' => 'text/xml' }
    end

    desc 'Delete fixtures from Solr'
    task :deindex do
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      solr.update data: '<delete><query>*:*</query></delete>', headers: { 'Content-Type' => 'text/xml' }
      solr.update data: '<commit/>', headers: { 'Content-Type' => 'text/xml' }
    end

    desc 'Generate fixtures from Solr'
    task :create_fixtures do
      Rake::Task['blackcat:traject:index'].invoke
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      response = solr.get 'select', params: {
        fq: 'id:6056346 OR id:2431513 OR id:1350394 OR id:12957804 OR id:1839879 OR id:1739750 OR
             id:2101414 OR id:15000267 OR id:1742385 OR id:1742314 OR id:12761636 OR id:1719185 OR
             id:14651607 OR id:16621095 OR id:1836205 OR id:16621187 OR id:12744851 OR id:15196486 OR
             id:12761233 OR id:22077781 OR id:11338033 OR id:22092979 OR id:21841437 OR id:22090542 OR
             id:22076459 OR id:21837282 OR id:21841438 OR id:21841435 OR id:2045016 OR id:21837545 OR
             id:5334461 OR id:286971 OR id:6434209 OR id:1954857 OR id:316074 OR id:361299 OR id:1618709 OR
             id:458856 OR id:4508585 OR id:3696293 OR id:15200946 OR id:21835545 OR id:13217672 OR id:13217692 OR
             id:3696252 OR id:3199219 OR id:14991763 OR id:3201012 OR id:3199220 OR id:21322961 OR id:14993654 OR
             id:22082958 OR id:22083276 OR id:21588551 OR id:3626147 OR id:3559984 OR id:21833256 OR id:22087836 OR
             id:13597912 OR id:22083281 OR id:22081919 OR id:22083306 OR id:20049333 OR id:17280642 OR id:5112336 OR
             id:3626135 OR id:2293245 OR id:21276123 OR id:11954839 OR id:19142604 OR id:10016724 OR id:22091400 OR
             id:11954990 OR id:10728954 OR id:20044789 OR id:19525926 OR id:22090269 OR id:18647510 OR id:19446664 OR
             id:22088949 OR id:472159 OR id:71224 OR id:470399 OR id:71529 OR id:834640 OR id:1793712 OR id:21601671 OR
             id:2080485 OR id:2080339 OR id:2069311 OR id:2010881 OR id:2003672 OR id:2788022 OR id:593070 OR
             id:14423715 OR id:15422566 OR id:17531126 OR id:22077448 OR id:114189 OR id:103934',
        fl: 'id, marc_display_ss, all_text_timv, language_facet_ssim, format, isbn_ssim, material_type_display_ssm,
             title_tsim, title_245ab_tsim, title_addl_tsim, title_added_entry_tsim, title_related_tsim,
             title_latin_display_ssm, title_display_ssm, uniform_title_display_ssm, additional_title_display_ssm,
             related_title_display_ssm, title_ssort, author_tsim, author_addl_tsim, all_authors_facet_sim,
             author_person_display_ssm, author_corp_display_ssm, author_meeting_display_ssm, addl_author_display_ssm,
             author_person_vern_display_ssm, author_corp_vern_display_ssm, author_meeting_vern_display_ssm,
             addl_author_vern_display_ssm, author_ssort, subject_tsim, subject_addl_tsim, subject_topic_facet_ssim,
             published_display_ssm, published_vern_display_ssm, pub_date_ssim, series_title_tsim,
             series_title_display_ssm, lc_callnum_display_ssm, lc_1letter_facet_sim, lc_alpha_facet_sim,
             lc_b4cutter_facet_sim, url_fulltext_display_ssm, url_suppl_display_ssm, all_authors_facet_ssim',
        sort: 'id desc',
        rows: 100,
        wt: :json
      }
      File.open('spec/fixtures/current_fixtures.json', 'wb') do |f|
        f.write(JSON.pretty_generate(response['response']['docs']))
      end
    end
  end

  namespace :traject do
    desc 'Index sample marc records using Traject'
    task :index do
      Rake::Task['blackcat:solr:deindex'].invoke
      traject_path = Rails.root.join('..', 'psulib_traject')
      Bundler.with_clean_env do
        system("cd #{traject_path} && /bin/bash -l -c 'RBENV_VERSION=jruby-9.2.0.0
                bundle exec traject -c psulib_config.rb solr/sample_data/demo_psucat.mrc'")
      end
    end
  end
end
