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

  def online_version_links
    return if partial_links.blank?

    parsed_links(partial_links)
  end

  def related_resources_links
    return if suppl_links.blank?

    parsed_suppl_links.reject { |link| special_collections_link? link }
  end

  def psu_special_collections_links
    return if suppl_links.blank?

    parsed_suppl_links.select { |link| special_collections_link? link }
  end

  private

    def full_links
      @_source['full_links_struct']
    end

    def partial_links
      links = @_source['partial_links_struct']

      if @_source['iiif_manifest_ssim'].present?
        links.grep_v(/IIIF manifest/)
      else
        links
      end
    end

    def suppl_links
      @_source['suppl_links_struct']
    end

    def parsed_links(links)
      links
        .map { |item| JSON.parse item }
        .each do |link|
          link['prefix'] = link_prefix link
          link['notes'] = link_notes link
        end
    end

    def parsed_suppl_links
      parsed_links(suppl_links)
    end

    def all_links
      parsed_links(full_links)
    end

    def digital_collections_link?(link)
      matching_urls = [
        'digital.libraries.psu.edu',
        'libraries.psu.edu/collections',
        'libraries.psu.edu/about/collections',
        /collection.+\.libraries\.psu\.edu/
      ]

      link['url'].match? Regexp.union(matching_urls)
    end

    def special_collections_link?(link)
      link['url'].include?('ark:/42409/fa8')
    end

    def link_prefix(link)
      "#{link['prefix'].chomp(':')}: " if link['prefix'].present?
    end

    def link_notes(link)
      ", #{link['notes'].chomp(':')}" if link['notes'].present?
    end
end
