# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render status: 404 }
      format.all { render plain: 'not found', status: 404 }
    end
  end

  def internal_server_error
    render status: 500
  end
end
