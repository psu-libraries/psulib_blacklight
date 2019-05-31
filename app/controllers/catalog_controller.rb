# frozen_string_literal: true

class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller
  include BlacklightRangeLimit::ControllerOverride
  include Blacklight::Catalog
  include Blacklight::Marc::Catalog

  rescue_from Blacklight::Exceptions::RecordNotFound do
    redirect_to '/404'
  end

  configure_blacklight do |config|
    config.index.document_presenter_class = PsulIndexPresenter
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'edismax'
    config.advanced_search[:form_solr_parameters] ||= {
      'facet.field' => %w[access_facet format language_facet media_type_facet library_facet lc_1letter_facet],
      'facet.pivot' => '',
      'facet.limit' => -1,
      'f.language_facet.facet.limit' => -1,
      'f.format.facet.limit' => -1,
      'facet.sort' => 'index'
    }
    config.advanced_search[:form_facet_partial] ||= 'advanced_search_facets_as_select'

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)

    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      rows: 10
    }

    # solr path which will be added to solr base url before the other solr params.
    # config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    # config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see
    ## SearchHelper#solr_doc_params) or parameters included in the Blacklight-jetty document requestHandler.
    #
    # config.default_document_solr_params = {
    #  qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1,
    #  # q: '{!term f=id v=$id}'
    # }

    # solr field configuration for search results/index views
    config.index.title_field = 'title_display_ssm'
    config.index.display_type_field = 'format'
    config.index.thumbnail_method = :render_thumbnail

    # solr field configuration for document/show views
    config.show.partials = [:show]
    # config.show.display_type_field = 'format'
    # config.show.thumbnail_field = :render_thumbnail

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    config.add_facet_field 'access_facet', label: 'Access'
    config.add_facet_field 'format', label: 'Format'
    config.add_facet_field 'campus_facet', label: 'Campus', sort: 'index', limit: -1, single: true
    config.add_facet_field 'library_facet', label: 'Library', sort: 'index', show: false, limit: -1, single: true # just advanced search
    config.add_facet_field 'up_library_facet', label: 'University Park Libraries', sort: 'index', limit: -1, single: true
    config.add_facet_field 'pub_date_itsi', label: 'Publication Year', range: { segments: false }
    config.add_facet_field 'language_facet', label: 'Language', limit: true
    config.add_facet_field 'subject_topic_facet', label: 'Subject', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'genre_facet', label: 'Genre', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'media_type_facet', label: 'Media Type', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'lc_1letter_facet', label: 'Classification', show: false, sort: 'index'
    config.add_facet_field 'lc_rest_facet', label: 'Full call number code', show: false, sort: 'index'
    config.add_facet_field 'classification_pivot_field', label: 'Call Number', pivot: %w[lc_1letter_facet lc_rest_facet]

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'title_latin_display_ssm', label: 'Title'
    config.add_index_field 'author_person_display_ssm', label: 'Author', link_to_facet: :all_authors_facet
    config.add_index_field 'author_corp_display_ssm', label: 'Corporate Author', link_to_facet: :all_authors_facet
    config.add_index_field 'author_meeting_display_ssm', label: 'Conference Author', link_to_facet: :all_authors_facet
    config.add_index_field 'format', label: 'Format'
    config.add_index_field 'publication_display_ssm', label: 'Publication Statement'
    config.add_index_field 'edition_display_ssm', label: 'Edition'
    config.add_index_field 'full_links_struct', label: 'Access Online', helper_method: :generic_link

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'title_latin_display_ssm', label: 'Title', if: false
    config.add_show_field 'author_person_display_ssm', label: 'Author', link_to_facet: :all_authors_facet, if: false
    config.add_show_field 'author_corp_display_ssm', label: 'Corporate Author', link_to_facet: :all_authors_facet, if: false
    config.add_show_field 'author_meeting_display_ssm', label: 'Conference Author', link_to_facet: :all_authors_facet, if: false
    config.add_show_field 'uniform_title_display_ssm', label: 'Uniform Title', if: false
    config.add_show_field 'additional_title_display_ssm', label: 'Additional Titles', if: false
    config.add_show_field 'overall_imprint_display_ssm', label: 'Published', if: false
    config.add_show_field 'copyright_display_ssm', label: 'Copyright Date', if: false
    config.add_show_field 'edition_display_ssm', label: 'Edition', if: false
    config.add_show_field 'format', label: 'Format', if: false
    config.add_show_field 'phys_desc_ssm', label: 'Physical Description', if: false
    config.add_show_field 'addl_author_display_ssm', label: 'Additional Creators', link_to_facet: :all_authors_facet, if: false
    config.add_show_field 'series_title_display_ssm', label: 'Series'
    config.add_show_field 'language_ssim', label: 'Language'
    config.add_show_field 'language_note_ssm', label: 'Language Note'
    config.add_show_field 'restrictions_access_note_ssm', label: 'Restrictions on Access'
    config.add_show_field 'toc_ssim', label: 'Contents'
    config.add_show_field 'notes_summary_ssim', label: 'Summary'
    config.add_show_field 'serials_continues_display_ssim', label: 'Continues', helper_method: :title_links
    config.add_show_field 'serials_continued_by_display_ssim', label: 'Continued By', helper_method: :title_links
    config.add_show_field 'serials_continues_in_part_display_ssim', label: 'Continues in Part', helper_method: :title_links
    config.add_show_field 'serials_continued_in_part_by_display_ssim', label: 'Continued in Part By', helper_method: :title_links
    config.add_show_field 'serials_formed_from_display_ssim', label: 'Formed From', helper_method: :title_links
    config.add_show_field 'serials_absorbs_display_ssim', label: 'Asborbs', helper_method: :title_links
    config.add_show_field 'serials_absorbed_by_display_ssim', label: 'Asborbed By', helper_method: :title_links
    config.add_show_field 'serials_absorbs_in_part_display_ssim', label: 'Asborbs in Part', helper_method: :title_links
    config.add_show_field 'serials_absorbed_in_part_by_display_ssim', label: 'Asborbed in Part By', helper_method: :title_links
    config.add_show_field 'serials_separated_from_display_ssim', label: 'Separated From', helper_method: :title_links
    config.add_show_field 'serials_split_into_display_ssim', label: 'Split Into', helper_method: :title_links
    config.add_show_field 'serials_merged_to_form_display_ssim', label: 'Merged to Form', helper_method: :title_links
    config.add_show_field 'serials_changed_back_to_display_ssim', label: 'Changed Back To', helper_method: :title_links
    config.add_show_field 'dates_of_pub_ssim', label: 'Dates of Publication and/or Sequential Designation'
    config.add_show_field 'subject_display_ssm', label: 'Subject(s)', helper_method: :subjectify
    config.add_show_field 'genre_display_ssm', label: 'Genre(s)', helper_method: :genre_links
    config.add_show_field 'isbn_ssm', label: 'ISBN'
    config.add_show_field 'issn_ssm', label: 'ISSN'
    config.add_show_field 'related_title_display_ssm', label: 'Related Titles'
    config.add_show_field 'duration_ssm', label: 'Duration', helper_method: :display_duration
    config.add_show_field 'frequency_ssm', label: 'Publication Frequency'
    config.add_show_field 'finding_aid_note_ssm', label: 'Finding Aid Note'
    config.add_show_field 'provenance_note_ssm', label: 'Provenance'
    config.add_show_field 'dissertation_note_ssm', label: 'Dissertation Note'
    config.add_show_field 'audience_ssm', label: 'Audience'
    config.add_show_field 'reading_grade_ssm', label: 'Reading Grade'
    config.add_show_field 'interest_age_ssm', label: 'Interest Age'
    config.add_show_field 'interest_grade_ssm', label: 'Interest Grade'
    config.add_show_field 'sound_ssm', label: 'Sound Characteristics'
    config.add_show_field 'music_numerical_ssm', label: 'Musical Work Number'
    config.add_show_field 'music_format_ssm', label: 'Format of Notated Music'
    config.add_show_field 'music_key_ssm', label: 'Musical key'
    config.add_show_field 'performance_ssm', label: 'Medium of Performance'
    config.add_show_field 'video_file_ssm', label: 'Video File Characteristics'
    config.add_show_field 'scale_graphic_material_note_ssm', label: 'Scale Note for Graphic Material'
    config.add_show_field 'digital_file_ssm', label: 'Digital File Characteristics'
    config.add_show_field 'form_work_ssm', label: 'Form of work'
    config.add_show_field 'audience_notes_ssm', label: 'Audience Notes'
    config.add_show_field 'general_note_ssm', label: 'Note'
    config.add_show_field 'bibliography_note_ssm', label: 'Bibliography Note'
    config.add_show_field 'with_note_ssm', label: 'With'
    config.add_show_field 'creation_production_credits_ssm', label: 'Creation/Production Credits Note'
    config.add_show_field 'citation_references_note_ssm', label: 'Citation/References Note'
    config.add_show_field 'participant_performer_ssm', label: 'Participant/Performer Note'
    config.add_show_field 'type_report_period_note_ssm', label: 'Type of Report and Period Covered Note'
    config.add_show_field 'special_numbering_ssm', label: 'Special Numbering'
    config.add_show_field 'file_data_type_ssm', label: 'Type of File/Data'
    config.add_show_field 'date_place_event_note_ssm', label: 'Data/Place of Event'
    config.add_show_field 'geographic_coverage_ssm', label: 'Geographic Coverage'
    config.add_show_field 'preferred_citation_ssm', label: 'Preferred Citation'
    config.add_show_field 'supplement_ssm', label: 'Supplement Note'
    config.add_show_field 'other_forms_ssm', label: 'Other Forms'
    config.add_show_field 'reproduction_note_ssm', label: 'Reproduction Note'
    config.add_show_field 'original_version_note_ssm', label: 'Original Version'
    config.add_show_field 'originals_loc_ssm', label: 'Location of Originals'
    config.add_show_field 'dup_loc_ssm', label: 'Location of Duplicates'
    config.add_show_field 'funding_information_ssm', label: 'Funding Information'
    config.add_show_field 'technical_details_ssm', label: 'Technical Details'
    config.add_show_field 'terms_use_reproduction_ssm', label: 'Terms of Use and Reproduction'
    config.add_show_field 'source_aquisition_ssm', label: 'Source of Acquisition'
    config.add_show_field 'related_materials_ssm', label: 'Related Materials'
    config.add_show_field 'copyright_status_ssm', label: 'Copyright Note'
    config.add_show_field 'associated_materials_ssm', label: 'Associated Materials'
    config.add_show_field 'administrative_history_note_ssm', label: 'Administrative History'
    config.add_show_field 'biographical_sketch_note_ssm', label: 'Biographical Note'
    config.add_show_field 'former_title_ssm', label: 'Title Varies'
    config.add_show_field 'issuing_ssm', label: 'Issuing Body'
    config.add_show_field 'index_note_ssm', label: 'Index Note'
    config.add_show_field 'documentation_info_note_ssm', label: 'Documentation Information'
    config.add_show_field 'version_copy_id_note_ssm', label: 'Version/Copy ID'
    config.add_show_field 'methodology_ssm', label: 'Methodology Note'
    config.add_show_field 'complexity_ssm', label: 'Complexity Note'
    config.add_show_field 'action_note_ssm', label: 'Action Note'
    config.add_show_field 'exhibitions_ssm', label: 'Exhibitions'
    config.add_show_field 'awards_ssm', label: 'Awards'
    config.add_show_field 'bound_with_struct', label: 'Binding notes', helper_method: :bound_info
    config.add_show_field 'indexed_by_note_ssm', label: 'Indexed By'
    config.add_show_field 'selectively_indexed_by_note_ssm', label: 'Selectively Indexed By'
    config.add_show_field 'references_note_ssm', label: 'Reviewed/Cited In'

    # Order not yet specified
    config.add_show_field 'full_links_struct', label: 'Access Online', helper_method: :generic_link
    config.add_show_field 'partial_links_struct', label: 'Access Online', helper_method: :generic_link
    config.add_show_field 'suppl_links_struct', label: 'View More Online', helper_method: :generic_link
    # config.add_show_field 'lc_callnum_display_ssm', label: 'Call number'
    # config.add_show_field 'id', label: 'Catkey'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', label: 'Keyword'

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      field.solr_parameters = {
        qf: '${title_qf}',
        pf: '${title_pf}'
      }
      field.solr_adv_parameters = {
        qf:  '$title_qf',
        pf:  '$title_pf'
      }
    end

    config.add_search_field('author') do |field|
      field.label = 'Author/Creator'
      field.solr_parameters = {
        qf: "'${author_qf}'",
        pf: "'${author_pf}'"
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually necessary.
    config.add_search_field('subject') do |field|
      field.qt = 'search'
      field.solr_parameters = {
        qf: "'${subject_qf}'",
        pf: "'${subject_pf}'"
      }
    end

    config.add_search_field('identifiers') do |field|
      field.include_in_simple_select = false
      field.label = 'ISBN/ISSN'
      field.solr_parameters = {
        qf:  '$number_qf'
      }
    end

    config.add_search_field('series') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = { qf: 'series_title_tsim' }
    end

    config.add_search_field('publisher') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = { qf: 'publisher_manufacturer_tsim' }
    end
    # config.add_search_field('Publisher')
    # config.add_search_field('Publication date')

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_itsi desc, title_sort asc', label: 'relevance'
    config.add_sort_field 'pub_date_itsi desc, title_sort asc', label: 'year'
    config.add_sort_field 'title_sort asc, pub_date_itsi desc', label: 'title'

    # Configuration for autocomplete suggestor
    # Disable until https://github.com/projectblacklight/blacklight/issues/1972 resolved
    config.autocomplete_enabled = false
    config.autocomplete_path = 'suggest'

    config.raw_endpoint.enabled = true
  end
end
