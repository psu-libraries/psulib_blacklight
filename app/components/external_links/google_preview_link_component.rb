# frozen_string_literal: true

module ExternalLinks
  class GooglePreviewLinkComponent < HathiGoogleLinksComponent
    def search_item
      return nil if free_to_read?

      return "LCCN:#{lccn}" if lccn.present?

      return "OCLC:#{oclc}" if oclc.present?

      return "ISBN:#{isbn}" if isbn.present?

      nil
    end

    private

      def isbn
        document[:document]['isbn_valid_ssm']&.first
      end
  end
end
