require 'rails_helper'

RSpec.describe "Errors", type: :request do

  describe "GET /bad_route" do
    it "returns http success" do
      get "/error/bad_route"
      expect(response).to have_http_status(:success)
    end
  end

end
