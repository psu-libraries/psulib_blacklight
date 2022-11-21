# frozen_string_literal: true

module ExternalLinks
  class PsuCollectionsLinksComponent < BaseLinksComponent
    def heading
      if links.collect { |l| l['url'].include?('ark:/42409/fa8') }.count(true) > 0
        'Special Collections Materials'
      else
        'View in Penn State Digital Collections'
      end
    end
  end
end
