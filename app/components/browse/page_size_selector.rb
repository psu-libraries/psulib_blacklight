# frozen_string_literal: true

class Browse::PageSizeSelector < ViewComponent::Base
  attr_reader :params

  def initialize(params:)
    @params = params
  end

  def link_path(length)
    browse_path(length: length,
                starting: params[:starting],
                ending: params[:ending],
                nearby: params[:nearby])
  end
end
