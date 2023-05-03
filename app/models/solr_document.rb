# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document
  include HathiLinks
  include ExternalLinks
  include PreferredCallNumber

  # self.unique_key = 'id'
  field_semantics.merge!(
    title: 'title_display_ssm',
    latin_title: 'title_latin_display_ssm',
    author: 'author_person_display_ssm',
    corporate_author: 'author_corp_display_ssm',
    conference_author: 'author_meeting_display_ssm',
    published: 'overall_imprint_display_ssm',
    edition: 'edition_display_ssm',
    format: 'format',
    # language: 'language_facet_ssim',
    # addl_author: 'author_addl_tsim',
    # publication_year: 'pub_date_illiad_ssm',
    # place_of_publication: 'publication_place_ssm',
    # publisher_name: 'publisher_name_ssm',
    # issn: 'issn_ssm'
  )

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  #SolrDocument.use_extension(Blacklight::Document::DocumentRis)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # below can be deleted?
  # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :marc_display_ss
  extension_parameters[:marc_format_type] = :marcxml
  use_extension(Blacklight::Marc::DocumentExtension) do |document|
    document.key?(SolrDocument.extension_parameters[:marc_source_field])
  end

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)
end
