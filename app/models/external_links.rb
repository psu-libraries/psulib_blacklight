# frozen_string_literal: true

module ExternalLinks
  def psu_digital_collections_links
    return if full_links.blank?

    parsed_links.select { |link| digital_collections_link? link }
      .each do |link|
      link['prefix'] = link_prefix link
      link['notes'] = link_notes link
    end
  end

  def access_online_links
    return if full_links.blank?

    parsed_links.reject { |link| digital_collections_link? link }
      .each do |link|
        link['prefix'] = link_prefix link
        link['notes'] = link_notes link
      end
  end

  private

    def full_links
      @_source['full_links_struct']
    end

    def parsed_links
      full_links.map { |item| JSON.parse item }
    end

    def digital_collections_link?(link)
      link['url'].include? 'libraries.psu.edu'
    end

    def link_prefix(link)
      "#{link['prefix'].chomp(':')}: " if link['prefix'].present?
    end

    def link_notes(link)
      ", #{link['notes']}" if link['notes'].present?
    end
end
