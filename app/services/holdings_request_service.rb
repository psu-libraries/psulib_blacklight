# frozen_string_literal: true

class HoldingsRequestService
  attr_reader :args, :locations, :libraries, :exclude

  def initialize(args)
    @args = args
    @libraries_data = libraries_data
    @locations = libraries_data['locations']
    @libraries = libraries_data['libraries']
    @exclude = libraries_data['exclude_from_email_availability']
  end

  def make_holdings_request
    sirsi_uri = URI(Settings.sirsi_url + args)

    Net::HTTP.get(sirsi_uri)
  end

  def holdings_availability
    holdings = Hash.from_xml(make_holdings_request)
    availability = get_location_data(holdings)
    if availability.present?
      availability_to_string(availability)
    end
  end

  private

    def get_location_data(holdings)
      call_info = holdings['LookupTitleInfoResponse']['TitleInfo']['CallInfo']

      if call_info.is_a?(Array)
        get_data_from_call_info(call_info)
      else
        library_data = get_library_data(call_info)
        return [] if call_info['libraryID'] == 'ONLINE' || library_data.blank?

        [library_data]
      end
    end

    def get_data_from_call_info(call_info)
      availability = []
      call_info.each do |holding|
        if availability.size >= 30
          @view_more = true
          break
        end
        library_data = get_library_data(holding)
        next if holding['libraryID'] == 'ONLINE' || library_data.blank?

        availability << library_data
      end
      availability
    end

    def get_library_data(call_info_or_holding)
      item_location_data = get_item_location_data(call_info_or_holding)
      return {} if item_location_data.blank?

      { 'library' => libraries[call_info_or_holding['libraryID']],
        'call_number' => call_info_or_holding['callNumber'],
        'items' => item_location_data }
    end

    def get_item_location_data(holding)
      item_location_data = []
      if holding['ItemInfo'].is_a?(Array)
        holding['ItemInfo'].each do |item|
          if item_location_data.size >= 3
            @view_more = true
            break
          end
          unless exclude.key?(item['currentLocationID'])
            item_location_data << { 'current_location' => locations[item['currentLocationID']] }
          end
        end
      else
        unless exclude.key?(holding['ItemInfo']['currentLocationID'])
          item_location_data << { 'current_location' => locations[holding['ItemInfo']['currentLocationID']] }
        end
      end
      item_location_data
    end

    def availability_to_string(availability)
      string = "Currently on shelf as of #{Time.now.strftime('%m/%d/%Y %H:%M')}"
      availability.each do |library|
        string += "\n\n#{library['library']}:"
        library['items'].each do |item|
          string += "\nCall Number: #{library['call_number']}, Location: #{item['current_location']}"
        end
      end
      string += "\n"
      string += "\nFollow record link view more available locations" if @view_more
      string
    end

    def libraries_data
      @libraries_data ||= JSON.parse(Rails.root.join('app/javascript/availability/libraries_locations.json').read)
    end
end
