class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_request
  before_action :validate_accept_header
  before_action :set_headers

  private

  def validate_accept_header
    if request.headers["Accept"] != 'application/vnd.api+json'
      render json: { errors:
        [
          "status"=>"406",
          "title"=>"Not Acceptable",
          "detail"=>"#{request.format} is not supported.",
        ]
      },
      status: :not_acceptable
    end
  end

  def set_headers
    response.headers['Content-Type'] = 'application/vnd.api+json'
  end
  
  # https://ropesec.com/articles/timing-attacks/
  # https://thoughtbot.com/blog/token-authentication-with-rails
  # https://stackoverflow.com/questions/17712359/authenticate-or-request-with-http-token-returning-html-instead-of-json
  def request_http_token_authentication(realm = "Application", message = nil)
    self.headers["WWW-Authenticate"] = %(Token realm="#{realm.gsub(/"/, "")}")
    render json: {errors: ["status"=>"401", "title"=>"Unauthorized", "detail"=>"Api key credential is missing, disabled, or invalid."]}, status: :unauthorized
  end

  def authenticate_request
    authenticate_or_request_with_http_token do |token, options|
      api_key = ApiKey.find_by(access_token: token)
      api_key.present? && (api_key.active != false)
    end
  end

  # ToDo: Reimplment this once I understand how to properly mitigate timing attacks
  def secure_compare_with_hashing(key1, key2)
    ActiveSupport::SecurityUtils.secure_compare(key1, key2)
  end
end
