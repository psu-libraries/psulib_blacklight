# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document
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
    language: 'language_facet_ssim'
  )

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

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

  def any_iiif_manifests?
    self[:iiif_manifest_ssim].present?
  end

  def iiif_manifest_urls
    if any_iiif_manifests?
      self[:iiif_manifest_ssim].map do |url|
        follow_redirects(url)
      end
    else
      []
    end.to_json
  end

  private

    def follow_redirects(url)
      host = URI.parse(url).host

      # Skip any further redirect business if we already know that we're going to get a
      # response with good CORS headers.
      return url if ['cdm17287.contentdm.oclc.org', 'digital.libraries.psu.edu'].include?(host)

      r = Faraday.head(url)

      # Allow the IIIF viewer to handle any further redirects on the front end as long as
      # we've arrived at a response that allows CORS.
      return url if r.headers['access-control-allow-origin'] == '*'

      case r.status
      when 301, 302
        follow_redirects(r.headers[:location])
      else
        # Let the IIIF viewer deal with any HTTP errors on the front end.
        url
      end
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError, URI::InvalidURIError
      # Again, let the viewer handle these errors.
      url
    end
end
