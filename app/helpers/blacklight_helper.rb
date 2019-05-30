# frozen_string_literal: false
#
module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # Generate the link to citations for Documents
  # @param path [String] the URL path for the link
  # @return [String] the markup for the link
  def render_cite_link(path)
    child = 'Cite'
    link_to(child.html_safe, path, id: 'citeLink', data: { ajax_modal: 'trigger' }, class: 'btn btn-info')
  end
end

