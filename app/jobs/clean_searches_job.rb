# frozen_string_literal: true

class CleanSearchesJob < ApplicationJob
  def perform(**args)
    Search.delete_old_searches(args[:days_old])
  end
end
