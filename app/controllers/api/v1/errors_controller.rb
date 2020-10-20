module Api::V1
  class ErrorsController < ApplicationController

    def unsupported_request
      if request.format != 'application/json'
        render json: { errors:
          [
            "status"=>"406",
            "title"=>"Not Acceptable",
            "detail"=>"#{request.format} is not supported.",
          ]
        },
        status: :not_acceptable
      else
        render json: { errors:
          [
            "status"=>"400",
            "title"=>"Bad Request",
            "detail"=>"Request is not recognized by application",
          ]
        },
        status: :bad_request
      end
    end
  end
end
