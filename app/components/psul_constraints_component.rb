# frozen_string_literal: true

class PsulConstraintsComponent < Blacklight::ConstraintsComponent
  def initialize(search_state:)
    super(search_state: search_state, query_constraint_component: PsulConstraintLayoutComponent,
          facet_constraint_component: PsulConstraintComponent)
  end
end
