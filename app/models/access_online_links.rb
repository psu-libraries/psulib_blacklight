# frozen_string_literal: true

module AccessOnlineLinks
  def access_online_links
    return nil if @_source['full_links_struct'].blank?

    filtered_links = @_source['full_links_struct'].reject do |item|
      (JSON.parse item)['url'].include? 'libraries.psu.edu'
    end

    return nil if filtered_links.blank?

    filtered_links.map { |item| JSON.parse item }
  end

  def psu_digital_collections_links
    return nil if @_source['full_links_struct'].blank?

    filtered_links = @_source['full_links_struct'].select do |item|
      (JSON.parse item)['url'].include? 'libraries.psu.edu'
    end

    return nil if filtered_links.blank?

    filtered_links.map { |item| JSON.parse item }
  end
end
