# frozen_string_literal: true

class PsulDocumentComponent < Blacklight::DocumentComponent
  def before_render
    super
    set_slot(:title, nil, actions: false) unless @show

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

  def call
    content_tag @component,
                id: @id,
                data: {
                  'document-id': @document.id.to_s.parameterize,
                  'document-counter': @counter
                },
                itemscope: true,
                itemtype: @document.itemtype,
                class: classes.flatten.join(' ') do
      safe_join([
        content_tag(:div, class: 'documentHeader row align-items-start gx-3') do
          safe_join([
            content_tag(:div, class: 'col-sm-9 pe-0') do
              safe_join([
                title,
                embed,
                content,
                metadata,
                metadata_sections.to_a,
                partials
              ].compact)
            end,
            content_tag(:div, class: 'col-sm-3 d-flex flex-column align-items-end ps-0 pe-0') do
              safe_join([
                helpers.render_index_doc_actions(@document,
                                                 wrapping_class: 'index-document-functions d-flex justify-content-end mb-2'),
                thumbnail
              ].compact)
            end
          ].compact)
        end,
        footer
      ].compact)
    end
  end
end
