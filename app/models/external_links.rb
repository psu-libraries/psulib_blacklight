# frozen_string_literal: true

module ExternalLinks
  def psu_digital_collections_links
    return if full_links.blank?

    all_links.select { |link| digital_collections_link? link }
  end

  def access_online_links
    return if full_links.blank?

    all_links.reject { |link| digital_collections_link? link }
  end

  private

    def full_links
      @_source['full_links_struct']
    end

    def parsed_links
      full_links.map { |item| JSON.parse item }
    end

    def all_links
      parsed_links.each do |link|
        link['prefix'] = link_prefix link
        link['notes'] = link_notes link
      end
    end

    def digital_collections_link?(link)
      link['url'].include? 'libraries.psu.edu'
    end

    def link_prefix(link)
      "#{link['prefix'].chomp(':')}: " if link['prefix'].present?
    end

    def link_notes(link)
      ", #{link['notes'].chomp(':')}" if link['notes'].present?
    end
end
