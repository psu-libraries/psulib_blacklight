# frozen_string_literal: true

module Browse::Paths
  def browse_path(args)
    send("#{action.singularize}_browse_path", args)
  end

  def browse_url
    send("#{action.singularize}_browse_url")
  end

  private

    def action
      @action ||= params.fetch(:action) { raise KeyError, 'params must include :action' }
    end
end
