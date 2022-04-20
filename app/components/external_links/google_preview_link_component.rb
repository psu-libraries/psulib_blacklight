# frozen_string_literal: true

module ExternalLinks
  class GooglePreviewLinkComponent < ViewComponent::Base
    def initialize(document)
      @document = document
    end

    def search_item
      return nil if free_to_read? || hathi_link?

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

      def free_to_read?
        access_facet = document[:document]['access_facet']
        return false if access_facet.nil?

        access_facet.include?('Free to Read')
      end

      def hathi_link?
        document[:ht_access] == 'allow' || (document[:ht_access] == 'deny' && Settings&.hathi_etas)
      end

      attr_reader :document
  end
end
