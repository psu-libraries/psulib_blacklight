# frozen_string_literal: true

module ExternalLinks
  class PsuCollectionsLinksComponent < BaseLinksComponent
    def heading
      if links.map { |l| l['url'].include?('ark:/42409/fa8') }.count(true).positive?
        'Special Collections Materials'
      else
        'View in Penn State Digital Collections'
      end
    end
  end
end
