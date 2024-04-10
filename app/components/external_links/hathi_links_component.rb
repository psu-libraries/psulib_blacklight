# frozen_string_literal: true

module ExternalLinks
  class HathiLinksComponent < HathiGoogleLinksComponent
    def initialize(document)
      @document = document
    end

    def search_item
      return nil if free_to_read?

      return "oclc/#{oclc}" if oclc.present?

      return "lccn/#{lccn}" if lccn.present?

      return "issn/#{issn}" if issn.present?

      nil
    end

    private

      def issn
        document[:document]['issn_ssm']&.first
      end
  end
end