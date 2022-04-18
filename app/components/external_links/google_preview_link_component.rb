# frozen_string_literal: true

module ExternalLinks
  class GooglePreviewLinkComponent < ViewComponent::Base
    def initialize(document)
      @document = document
    end

    def search_item
      return "LCCN:#{lccn}" if lccn.present?

      return "OCLC:#{oclc}" if oclc.present?

      return "ISBN:#{isbn}" if isbn.present?

      nil
    end

    private

      def lccn
        document[:document]['lccn_ssim']&.first
      end

      def oclc
        document[:document]['oclc_number_ssim']&.first
      end

      def isbn
        document[:document]['isbn_valid_ssm']&.first
      end

      attr_reader :document
  end
end
