# frozen_string_literal: true

class PsulDocumentComponent < Blacklight::DocumentComponent
  def before_render
    super
    with_title unless title || @show

    with_footer do
      safe_join([
        helpers.render(partial: 'external_links/index_external_links', locals: { document: @document }),
        content_tag(:div, class: 'blacklight-availability') do
          unless Settings.readonly
            helpers.render(partial: 'catalog/index_availability',
                           locals: { document: @document })
          end
        end
      ].compact)
    end
  end
end
