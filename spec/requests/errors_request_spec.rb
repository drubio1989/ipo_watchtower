require 'rails_helper'

RSpec.describe "Errors", type: :request do
  let(:api_key) { create(:api_key) }
  let(:headers) do
    {
      'HTTP_AUTHORIZATION' => "Token token=#{api_key.access_token}",
      'Accept' => "application/vnd.api+json"
    }
  end

  describe 'GET #unsupported_request' do
    describe 'garbage routes' do
      it 'returns 400' do
        get "/api/v1/bogus_garbage_request", headers: headers
        expect(response.content_type).to eq("application/vnd.api+json")
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
