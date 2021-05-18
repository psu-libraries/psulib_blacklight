# frozen_string_literal: true

# @abstract By including this module in CatalogController, we are overriding the behaviour of Blacklight::SearchContext
# so that search histories are persisted in Redis and not Postgres. The Search and SearchHistory model, both of which
# are backed by Redis, replace the Postgres-backed Search model in Blacklight. SearchHistory is stored via the user's
# session id and contains a set of Search ids. Each Search contains the parameters of a user's search.
#
# A given search is either recalled from the user's search history, if it's been used before, or saved to their history
# if it hasn't. All searches and search histories expire from Redis after a specified time configured in Redis's TTL.

module SearchContext
  extend ActiveSupport::Concern

  private

    def find_search_session
      if agent_is_crawler?
        nil
      elsif params[:search_context].present?
        find_or_initialize_search_session_from_params JSON.parse(params[:search_context])
      elsif params[:search_id].present?
        ::Search.find(search_session['id'])
      elsif start_new_search_session?
        find_or_initialize_search_session_from_params search_state.to_h
      elsif search_session['id']
        ::Search.find(search_session['id'])
      end
    end

    def find_or_initialize_search_session_from_params(params)
      params_copy = params.reject { |k, v| blacklisted_search_session_params.include?(k.to_sym) || v.blank? }

      return if params_copy.reject { |k, _v| [:action, :controller].include? k.to_sym }.blank?

      saved_search = search_history.searches.find { |search| search.query_params == params_copy }

      saved_search || ::Search.create(query_params: params_copy).tap do |search|
        search_history.add(search)
      end
    end

    def search_history
      @search_history ||= ::SearchHistory.find_or_initialize(session.id)
    end
end
