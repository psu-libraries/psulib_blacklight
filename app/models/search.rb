# frozen_string_literal: true

# @abstract Blacklight's search model which we use to model a user's search, but not store anything to the database.

class Search < ApplicationRecord
  belongs_to :user, optional: true

  serialize :query_params

  def saved?
    false
  end

  def readonly?
    true
  end
end
