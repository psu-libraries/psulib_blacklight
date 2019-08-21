# frozen_string_literal: true

module LayoutHelper
  include Blacklight::LayoutHelperBehavior
  ##
  # Classes used for sizing the main content of a Blacklight page
  # @return [String]
  def main_content_classes
    'col-md-8'
  end

  ##
  # Classes used for sizing the sidebar content of a Blacklight page
  # @return [String]
  def sidebar_classes
    'page-sidebar col-md-4'
  end

  ##
  # Class used for specifying main layout container classes. Can be
  # overwritten to return 'container-fluid' for Bootstrap full-width layout
  # @return [String]
  def container_classes
    'container'
  end
end
