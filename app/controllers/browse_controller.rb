# frozen_string_literal: true

class BrowseController < ApplicationController
  def call_numbers
    @shelf_list = ShelfListPresenter.new(shelf_list_params)
  end

  def authors
    @author_list = BrowseList.new(author_list_params)
  end

  def subjects
    @subject_list = BrowseList.new(subject_list_params)
  end

  def titles
    @title_list = BrowseList.new(title_list_params)
  end

  private

    def author_list_params
      params
        .permit(:length, :page, :prefix)
        .to_hash
        .merge(field: 'all_authors_facet')
        .symbolize_keys
    end

    def shelf_list_params
      params
        .permit(:starting, :ending, :length, :nearby, :classification)
        .to_hash
        .delete_if { |param, value| param == 'classification' && %w(LC DEWEY).exclude?(value.upcase) }
        .symbolize_keys
    end

    def subject_list_params
      params
        .permit(:length, :page, :prefix)
        .to_hash
        .merge(field: 'subject_browse_facet')
        .symbolize_keys
    end

    def title_list_params
      params
        .permit(:length, :page, :prefix)
        .to_hash
        .merge(field: 'title_sort')
        .symbolize_keys
    end
end
