require 'rails_helper'

RSpec.describe "Errors", type: :request do
  let(:api_key) { create(:api_key) }
  let(:headers) do
    { 'HTTP_AUTHORIZATION' => "Token token=#{api_key.access_token}" }
  end

  describe 'GET #unsupported_request' do
    describe 'garbage routes' do
      it 'returns 400' do
        get "/api/v1/bogus_garbage_request", headers: headers
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'bad media formats' do

      it 'returns 406' do
        %w[html csv xml].each do |format|
          get "/api/v1/last-100-ipos.#{format}", headers: headers
          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(response).to have_http_status(:not_acceptable)
        end
      end
    end
  end
end
