module V1
  module Helpers
    extend Grape::API::Helpers

    class EmitError < StandardError; end

    def emit_error msg, status, code
      error!({ message: msg, status: status, code: code }, status)
      # env['api.tilt.template'] = 'error'
      # env['api.tilt.locals'] = { status: status, code: code, error_msg: msg }
    end

    def emit_error! msg, status, code
      error!({ message: msg, status: status, code: code }, status)
      raise EmitError
    end

    def emit_empty
      { status: 200 }
    end


    def authenticate!
      emit_error! 'Unauthorized. Invalid or expired token.', 401, 1 unless current_user
      @current_user
    end

    def current_user
      token = ApiKey.where(access_token: params[:token]).first
      if token && !token.expired?
        @current_user = User.find(token.user_id)
      else
        false
      end
    end
  end

  class Root < Grape::API
    version 'v1'
    mount V1::Books
    mount V1::Auth
    mount V1::Users
    mount V1::Bookshelves
  end
end
