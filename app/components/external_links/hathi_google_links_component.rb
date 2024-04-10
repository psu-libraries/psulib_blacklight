# frozen_string_literal: true

module ExternalLinks
  class HathiGoogleLinksComponent < ViewComponent::Base
    def initialize(document)
      @document = document
    end

    private

      def lccn
        document[:document]['lccn_ssim']&.first
      end

      def oclc
        document[:document]['oclc_number_ssim']&.first
      end

      def free_to_read?
        access_facet = document[:document]['access_facet']
        return false if access_facet.nil?

        access_facet.include?('Free to Read')
      end

      attr_reader :document
  end
end