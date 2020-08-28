# frozen_string_literal: true

json.continueSearch url_for(search_state.to_h
                                .except('per_page')
                                .except('format')
                                .merge(action: 'index', controller: 'catalog', only_path: false))

json.meta do
  json.pages @presenter.pagination_info
end

json.data do
  json.array! @presenter.documents do |document|
    doc_presenter = index_presenter(document)
    document_url = polymorphic_url(url_for_document(document))
    json.id document.id
    json.type doc_presenter.display_type.first
    json.attributes do
      doc_presenter.fields_to_render.each do |field_name, field, field_presenter|
        json.partial! 'field', field: field,
                               field_name: field_name,
                               document_url: document_url,
                               doc_presenter: doc_presenter,
                               field_presenter: field_presenter,
                               view_type: 'index'
      end
    end

    json.links do
      json.self document_url
    end
  end
end
