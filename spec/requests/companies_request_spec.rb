require 'rails_helper'

RSpec.describe "Companies", type: :request do
  let(:api_key) { create(:api_key) }
  let(:disabled_key) { create(:api_key, :disabled) }
  let(:ipo_profile) { create(:ipo_profile) }
  let(:company) { ipo_profile.company}

  let(:invalid_headers) do
    { 'HTTP_AUTHORIZATION' => "Token token=#{disabled_key.access_token}" }
  end

  let(:invalid_media_type) do
    {
      'HTTP_AUTHORIZATION' => "Token token=#{api_key.access_token}",
      'Accept' => "text/html"
    }
  end

  let(:headers) do
    {
      'HTTP_AUTHORIZATION' => "Token token=#{api_key.access_token}",
      'Accept' => "application/vnd.api+json"
    }
  end

  def valid_error(id)
    {
      "status"=> "404",
      "title"=> "Record Not Found",
      "detail"=> "Couldn't find Company with 'id'=#{id}"
    }
  end

  let(:valid_attributes) do
    {
      "name"=> company.name,
      "description"=>company.description,
      "industry"=>company.industry,
      "employees"=>company.employees,
      "founded"=>company.founded.to_s,
      "address"=>company.address,
      "phone_number"=>company.phone_number,
      "web_address"=>company.web_address,
      "view_prospectus"=>company.view_prospectus,
      "market_cap"=>company.market_cap,
      "revenue"=>company.revenue,
      "net_income"=>company.net_income
    }
  end

  let(:valid_keys) do
    %w[id type attributes relationships links]
  end

  let(:valid_relationships) do
    {
      "ipo_profile"=> {
          "data"=> {
            "id"=> "#{ipo_profile.id}",
            "type"=> "ipo"
        }
      }
    }
  end

  let(:valid_included_attributes) do
    {
      "id"=> "#{ipo_profile.id}",
      "type"=> "ipo",
      "attributes"=> {
        "company"=> company.name,
        "symbol"=> ipo_profile.symbol,
        "industry"=> company.industry,
        "shares"=> ipo_profile.shares,
        "exchange"=> ipo_profile.exchange,
        "estimated_volume"=> ipo_profile.estimated_volume,
        "managers"=>ipo_profile.managers,
        "co_managers"=> ipo_profile.co_managers,
        "status"=> ipo_profile.status,
        "expected_to_trade"=> ipo_profile.expected_to_trade.strftime('%Y-%m-%d'),
        "price_range"=> "#{ipo_profile.price_low}" + "-" + "#{ipo_profile.price_high}"
      }
    }
  end

  shared_examples_for 'requests_and_status_codes' do
    it 'returns 200' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'returns json content type' do
      subject
      expect(response.content_type).to eq("application/vnd.api+json")
    end
  end

  describe 'GET #ipo-index' do
    context 'status codes' do
      subject { get api_v1_ipo_index_path, headers: headers }
      it_behaves_like 'requests_and_status_codes'
    end

    context 'unauthorized' do
      context 'with missing api key' do
        it 'returns 401' do
          get api_v1_ipo_index_path
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with a disabled key' do
        it 'returns 401' do
          get api_v1_ipo_index_path, headers: invalid_headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'bad media type' do
      it 'returns 406 if media type is not application/vnd.api+json' do
        get "/api/v1/last-100-ipos", headers: invalid_media_type
        expect(response).to have_http_status(:not_acceptable)
      end
    end

    it 'has the correct json body structure' do
      create(:company, name: 'Alpha Inc.')
      get api_v1_ipo_index_path, headers: headers
      payload = json_data[0]
      expect(payload.keys).to eq valid_keys
      expect(payload["attributes"]).to include "name"=>"Alpha Inc."
      expect(payload["links"]).to include "self" => "/api/v1/ipo/companies/alpha-inc"
    end

    context 'filter' do
      it 'correctly filters company by params' do
        a = create(:company, name: 'ACME Inc.')
        b = create(:company, name: 'Beta Corp')

        get api_v1_ipo_index_path, headers: headers, params: { filter: {name: 'B'} }
        payload = json_data[0]

        expect(payload).to_not include [a]
        expect(payload.keys).to eq valid_keys
        expect(payload["attributes"]).to include "name"=>b.name
        expect(payload["links"]).to include "self" => "/api/v1/ipo/companies/#{b.slug}"
      end
    end
  end

  describe 'GET #show' do
    context 'status codes' do
      subject { get api_v1_company_path(company.id), headers: headers }
      it_behaves_like 'requests_and_status_codes'
    end

    context 'unauthorized' do
      context 'with missing api key' do
        it 'returns 401' do
          get api_v1_company_path(company.id)
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with a disabled key' do
        it 'returns 401' do
          get api_v1_company_path(company.id), headers: invalid_headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'bad media type' do
      it 'returns 406 if media type is not application/vnd.api+json' do
        get api_v1_company_path(company.id), headers: invalid_media_type
        expect(response).to have_http_status(:not_acceptable)
      end
    end

    context 'errors' do
      it 'returns 404 and error object if record is not found' do
        get api_v1_company_path(1), headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'has the proper error json body structure' do
        get api_v1_company_path(1), headers: headers
        expect(json_error[0]).to include valid_error(1)
      end
    end

    it 'has the correct json body structure' do
      get api_v1_company_path(company.id), headers: headers
      payload = json_data
      included = json_included[0]

      expect(payload.keys).to eq valid_keys
      expect(payload["attributes"]).to include valid_attributes
      expect(payload["relationships"]).to include valid_relationships
      expect(payload["links"]).to include "self" => "/api/v1/ipo/companies/#{company.slug}"
      expect(included).to include valid_included_attributes
    end
  end
end
