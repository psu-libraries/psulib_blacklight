# frozen_string_literal: true

module Browse
  class Controls < ViewComponent::Base
    attr_reader :navigator, :paginator

    # @param navigator [ViewComponent::Base]
    # @param paginator [ViewComponent::Base]
    def initialize(navigator:, paginator: PageSizeSelector.new)
      unless navigator.is_a?(ViewComponent::Base) && paginator.is_a?(ViewComponent::Base)
        raise ArgumentError, 'navigator and paginator must be view components'
      end

      @navigator = navigator
      @paginator = paginator
    end
  end
end
