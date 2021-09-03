# frozen_string_literal: true

module Browse::Paths
  def browse_path(args)
    if action == 'index'
      super(args)
    else
      send("browse_#{action}_path", args)
    end
  end

  def browse_url
    if action == 'index'
      super(args)
    else
      send("browse_#{action}_url")
    end
  end

  private

    def action
      @action ||= params.fetch(:action) { raise KeyError, 'params must include :action' }
    end
end
