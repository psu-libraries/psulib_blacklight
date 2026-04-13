# frozen_string_literal: true

require 'ipaddr'

module PsulibBlacklight
  class SolrRequestConfig
    HTTP_SETTINGS_HEADER_PATTERN = /\A(?:HTTP_)?X[-_]SETTINGS__([^_]+)__(.+)\z/i.freeze
    X_FORWARDED_FOR_HEADER_NAMES = %w[X-Forwarded-For HTTP_X_FORWARDED_FOR].freeze
    DEFAULT_INTERNAL_NETWORKS = [
      IPAddr.new('127.0.0.0/8'),
      IPAddr.new('10.0.0.0/8'),
      IPAddr.new('172.16.0.0/12'),
      IPAddr.new('192.168.0.0/16'),
      IPAddr.new('66.71.0.0/17'),
      IPAddr.new('75.102.64.0/18'),
      IPAddr.new('104.38.0.0/15'),
      IPAddr.new('128.118.0.0/16'),
      IPAddr.new('130.203.0.0/16'),
      IPAddr.new('146.186.0.0/16'),
      IPAddr.new('150.231.0.0/16'),
      IPAddr.new('169.254.0.0/16'),
      IPAddr.new('192.5.158.0/24'),
      IPAddr.new('192.5.159.0/24'),
      IPAddr.new('192.5.160.0/24'),
      IPAddr.new('192.5.161.0/24'),
      IPAddr.new('192.112.253.0/24'),
      IPAddr.new('15.181.183.32/32'),
      IPAddr.new('15.181.183.50/32'),
      IPAddr.new('130.41.195.214/32'),
      IPAddr.new('134.238.201.108/32'),
      IPAddr.new('165.85.38.136/32'),
      IPAddr.new('165.85.38.17/32'),
      IPAddr.new('165.85.42.87/32'),
      IPAddr.new('165.85.42.88/32'),
      IPAddr.new('165.85.50.151/32'),
      IPAddr.new('165.85.133.240/32'),
      IPAddr.new('165.85.199.10/32'),
      IPAddr.new('165.85.199.100/32'),
      IPAddr.new('165.85.209.63/32'),
      IPAddr.new('165.85.209.69/32'),
      IPAddr.new('208.127.66.230/32'),
      IPAddr.new('208.127.67.25/32'),
      IPAddr.new('208.127.75.216/32'),
      IPAddr.new('208.127.77.108/32')
    ].freeze

    attr_reader :request

    def initialize(request)
      @request = request
    end

    def url
      solr_config.query_url
    end

    private

      def solr_config
        @solr_config ||= PsulibBlacklight::SolrConfig.new(namespace: selected_namespace,
                                                          overrides: header_overrides)
      end

      def selected_namespace
        internal_request? ? :solrcat : :solr
      end

      def internal_request?
        request_ips.any? { |ip| internal_ip?(ip) }
      end

      def request_ips
        forwarded_ips = x_forwarded_for
        return forwarded_ips if forwarded_ips.any?

        [request.remote_ip].compact
      end

      def x_forwarded_for
        X_FORWARDED_FOR_HEADER_NAMES.flat_map do |name|
          value = request.headers[name]
          value.to_s.split(',').map(&:strip)
        end.compact_blank
      end

      def internal_ip?(ip)
        return false if ip.blank?

        address = IPAddr.new(ip)
        configured_internal_networks.any? { |network| network.include?(address) } ||
          DEFAULT_INTERNAL_NETWORKS.any? { |network| network.include?(address) }
      rescue IPAddr::InvalidAddressError
        false
      end

      def configured_internal_networks
        return [] unless Settings.respond_to?(:solrcat)

        Array(Settings.solrcat.ip_whitelist).filter_map do |whitelist_value|
          IPAddr.new(whitelist_value.to_s)
        rescue IPAddr::InvalidAddressError
          nil
        end
      end

      def header_overrides
        header_values = header_values_by_namespace
        header_values.fetch(selected_namespace, {})
      end

      def header_values_by_namespace
        request.headers.to_h.each_with_object(Hash.new { |hash, key| hash[key] = {} }) do |(key, value), namespaces|
          match = key.to_s.match(HTTP_SETTINGS_HEADER_PATTERN)
          next unless match

          namespace = match[1].downcase.to_sym
          field = match[2].downcase.to_sym
          namespaces[namespace][field] = value
        end
      end
  end
end
