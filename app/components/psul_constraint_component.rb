# frozen_string_literal: true

class PsulConstraintComponent < Blacklight::ConstraintComponent
  with_collection_parameter :facet_item_presenter

  def initialize(facet_item_presenter:)
    super(facet_item_presenter: facet_item_presenter, layout: PsulConstraintLayoutComponent)
  end
end
