require 'rails_helper'

RSpec.describe "IpoProfilesController", type: :request do
  let(:api_key) { create(:api_key) }
  let(:disabled_key) { create(:api_key, :disabled) }

  let(:invalid_headers) do
    { 'HTTP_AUTHORIZATION' => "Token token=#{disabled_key.access_token}" }
  end

  def valid_error(ticker)
    {
      "status"=> "404",
      "title"=> "Resource Not Found",
      "detail"=> "No ipo found for ticker #{ticker}"
    }
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

  let(:valid_keys) do
    %w[id type attributes relationships]
  end

  def valid_attributes(ipo_profile)
    {
      "company"=>ipo_profile.company.name,
      "ticker"=> ipo_profile.company.stock_ticker.ticker,
      "industry"=> ipo_profile.industry,
      "offer_date"=>ipo_profile.offer_date.strftime("%Y-%m-%d"),
      "shares"=>ipo_profile.shares,
      "offer_price"=>ipo_profile.price_low,
      "first_day_close_price"=>ipo_profile.first_day_close_price,
      "current_price"=>ipo_profile.current_price,
      "rate_of_return"=>ipo_profile.rate_of_return
    }
  end

  def valid_relationships(company)
    {
      "company"=> {
          "data"=> {
            "id"=> "#{company.id}",
            "type"=> "company"
        },
        "links"=> {
          "related"=> "#{api_v1_company_path(company.stock_ticker.ticker)}"
        }
      }
    }
  end

  def valid_recently_filed_attributes(ipo_profile)
    {
      "file_date"=> ipo_profile.file_date.strftime("%Y-%m-%d"),
      "ticker"=> ipo_profile.company.name,
      "ticker"=> ipo_profile.company.stock_ticker.ticker,
      "managers"=> ipo_profile.managers,
      "shares"=> ipo_profile.shares,
      "price_low"=> ipo_profile.price_low,
      "price_high"=> ipo_profile.price_high,
      "estimated_volume"=> ipo_profile.estimated_volume,
      "expected_to_trade"=> ipo_profile.expected_to_trade.strftime("%Y-%m-%d")
    }
  end

  def valid_calendar_attributes(ipo_profile)
    {
      "company"=>ipo_profile.company.name,
      "ticker"=> ipo_profile.company.stock_ticker.ticker,
      "managers"=> ipo_profile.managers,
      "shares"=>ipo_profile.shares,
      "price_low"=>ipo_profile.price_low,
      "price_high"=>ipo_profile.price_high,
      "estimated_volume"=>ipo_profile.estimated_volume,
      "expected_to_trade"=>ipo_profile.expected_to_trade.strftime("%Y-%m-%d")
    }
  end

  let(:valid_pagination_linkage) do
    {
      "self"=> "#{ENV["TEST_DOMAIN_URL"]}#{request.fullpath}",
      "current"=> "#{ENV["TEST_DOMAIN_URL"]}#{request.fullpath}?page[number]=1",
      "next"=> "#{ENV["TEST_DOMAIN_URL"]}#{request.fullpath}?page[number]=2",
      "last"=> "#{ENV["TEST_DOMAIN_URL"]}#{request.fullpath}?page[number]=3"
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

  describe 'GET #last-100' do
    context 'status codes' do
      subject { get api_v1_last_100_ipos_path, headers: headers }
      it_behaves_like 'requests_and_status_codes'
    end

    context 'unauthorized' do
      context 'with missing api key' do
        it 'returns 401' do
          get api_v1_last_100_ipos_path
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with a disabled key' do
        it 'returns 401' do
          get api_v1_last_100_ipos_path, headers: invalid_headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'bad media type' do
      it 'returns 406 if media type is not application/vnd.api+json' do
        get api_v1_last_100_ipos_path, headers: invalid_media_type
        expect(response).to have_http_status(:not_acceptable)
      end
    end

    describe 'json body structure' do
      it 'has the correct json body structure' do
        create(:ipo_profile)
        get api_v1_last_100_ipos_path, headers: headers
        payload = json_data[0]
        ipo_profile = IpoProfile.find(payload["id"])
        expect(payload.keys).to eq valid_keys
        expect(payload["attributes"]).to include valid_attributes(ipo_profile)
        expect(payload["relationships"]).to include valid_relationships(ipo_profile.company)
      end
    end

    it 'returns the last 100 ipos ordered by offer_date' do
      a = create(:ipo_profile, offer_date: Date.today - 7.days)
      b = create(:ipo_profile, offer_date: Date.today - 3.days)
      c = create(:ipo_profile, offer_date: Date.today - 1.days)

      get api_v1_last_100_ipos_path, headers: headers
      expect(assigns(:ipos)).to eq([a,b,c])
    end

    context 'pagination' do
      before(:each) do
        create_list(:ipo_profile, 90)
      end

      it 'paginates by collections of 30' do
        get api_v1_last_100_ipos_path, headers: headers
        expect(json_data.size).to eq 30
      end

      it 'has the correct top level pagination linkage' do
        get api_v1_last_100_ipos_path, headers: headers
        payload = json_pagination
        expect(payload).to include valid_pagination_linkage
      end
    end
  end

  describe 'GET #last-12-months' do
    context 'status codes' do
      subject { get api_v1_last_12_months_path, headers: headers }
      it_behaves_like 'requests_and_status_codes'
    end

    context 'unauthorized' do
      context 'with missing api key' do
        it 'returns 401' do
          get api_v1_last_12_months_path
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with a disabled key' do
        it 'returns 401' do
          get api_v1_last_12_months_path, headers: invalid_headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'bad media type' do
      it 'returns 406 if media type is not application/vnd.api+json' do
        get api_v1_last_12_months_path, headers: invalid_media_type
        expect(response).to have_http_status(:not_acceptable)
      end
    end

    describe 'json body structure' do
      it 'has the correct json body structure' do
        create(:ipo_profile, :within_12_months)
        get api_v1_last_12_months_path, headers: headers
        payload = json_data[0]
        ipo_profile = IpoProfile.find(payload["id"])
        expect(payload.keys).to eq valid_keys
        expect(payload["attributes"]).to include valid_attributes(ipo_profile)
        expect(payload["relationships"]).to include valid_relationships(ipo_profile.company)
      end
    end

    it 'returns ipos in the last 12 months ordered by offer_date' do
      a = create(:ipo_profile, :within_12_months)
      b = create(:ipo_profile, :within_12_months)
      c = create(:ipo_profile, offer_date: (Date.today - 2.years))

      get api_v1_last_12_months_path, headers: headers

      expect(assigns(:ipos)).to include(a,b)
      expect(assigns(:ipos)).to_not include([c])
    end

    context 'pagination' do
      before(:each) do
        create_list(:ipo_profile, 90, :within_12_months)
      end

      it 'paginates by collections of 30' do
        get api_v1_last_12_months_path, headers: headers
        expect(json_data.size).to eq 30
      end

      it 'has the correct top level pagination linkage' do
        get api_v1_last_12_months_path, headers: headers
        payload = json_pagination
        expect(payload).to include valid_pagination_linkage
      end
    end
  end

  describe 'GET #current-year-pricings' do
    context 'status codes' do
      subject { get api_v1_current_year_pricings_path, headers: headers }
      it_behaves_like 'requests_and_status_codes'
    end

    context 'unauthorized' do
      context 'with missing api key' do
        it 'returns 401' do
          get api_v1_current_year_pricings_path
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with a disabled key' do
        it 'returns 401' do
          get api_v1_current_year_pricings_path, headers: invalid_headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'bad media type' do
      it 'returns 406 if media type is not application/vnd.api+json' do
        get api_v1_current_year_pricings_path, headers: invalid_media_type
        expect(response).to have_http_status(:not_acceptable)
      end
    end

    describe 'json body structure' do
      it 'has the correct json body structure' do
        create(:ipo_profile, :starting_from_beginning_of_year)
        get api_v1_current_year_pricings_path, headers: headers
        payload = json_data[0]
        ipo_profile = IpoProfile.find(payload["id"])
        expect(payload.keys).to eq valid_keys
        expect(payload["attributes"]).to include valid_attributes(ipo_profile)
        expect(payload["relationships"]).to include valid_relationships(ipo_profile.company)
      end
    end

    it 'returns ipos from the beginning of the year to now' do
      a = create(:ipo_profile, :starting_from_beginning_of_year)
      b = create(:ipo_profile, offer_date: Date.today - 1.year)
      get api_v1_current_year_pricings_path, headers: headers

      expect(assigns(:ipos)).to include a
      expect(assigns(:ipos)).to_not include([b])
    end

    context 'pagination' do
      before(:each) do
        create_list(:ipo_profile, 90, :starting_from_beginning_of_year)
      end

      it 'paginates by collections of 30' do
        get api_v1_current_year_pricings_path, headers: headers
        expect(json_data.size).to eq 30
      end

      it 'has the correct top level pagination linkage' do
        get api_v1_current_year_pricings_path, headers: headers
        payload = json_pagination
        expect(payload).to include valid_pagination_linkage
      end
    end
  end

  describe 'GET #ipo-calendar' do
    context 'status codes' do
      subject { get api_v1_ipo_calendar_path, headers: headers }
      it_behaves_like 'requests_and_status_codes'
    end

    context 'unauthorized' do
      context 'with missing api key' do
        it 'returns 401' do
          get api_v1_ipo_calendar_path
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with a disabled key' do
        it 'returns 401' do
          get api_v1_ipo_calendar_path, headers: invalid_headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'bad media type' do
      it 'returns 406 if media type is not application/vnd.api+json' do
        get api_v1_ipo_calendar_path, headers: invalid_media_type
        expect(response).to have_http_status(:not_acceptable)
      end
    end

    describe 'json body structure' do
      it 'has the correct json body structure' do
        create(:ipo_profile)
        get api_v1_ipo_calendar_path, headers: headers
        payload = json_data[0]
        ipo_profile = IpoProfile.find(payload["id"])
        expect(payload.keys).to eq valid_keys
        expect(payload["attributes"]).to include valid_calendar_attributes(ipo_profile)
        expect(payload["relationships"]).to include valid_relationships(ipo_profile.company)
      end
    end

    it 'returns ipos that will be trading after the start of the current week' do
      a = create(:ipo_profile)
      b = create(:ipo_profile, expected_to_trade: Date.today - 7.days)
      get api_v1_ipo_calendar_path, headers: headers

      expect(assigns(:ipos)).to include a
      expect(assigns(:ipos)).to_not include([b])
    end

    context 'pagination' do
      before(:each) do
        create_list(:ipo_profile, 90)
      end

      it 'paginates by collections of 30' do
        get api_v1_ipo_calendar_path, headers: headers
        expect(json_data.size).to eq 30
      end

      it 'has the correct top level pagination linkage' do
        get api_v1_ipo_calendar_path, headers: headers
        payload = json_pagination
        expect(payload).to include valid_pagination_linkage
      end
    end
  end

  describe 'GET #recently-filed' do
    context 'status codes' do
      subject { get api_v1_ipos_recently_filed_path, headers: headers }
      it_behaves_like 'requests_and_status_codes'
    end

    context 'unauthorized' do
      context 'with missing api key' do
        it 'returns 401' do
          get api_v1_ipos_recently_filed_path
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with a disabled key' do
        it 'returns 401' do
          get api_v1_ipos_recently_filed_path, headers: invalid_headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'bad media type' do
      it 'returns 406 if media type is not application/vnd.api+json' do
        get api_v1_ipos_recently_filed_path, headers: invalid_media_type
        expect(response).to have_http_status(:not_acceptable)
      end
    end

    describe 'json body structure' do
      it 'has the correct json body structure' do
        create(:ipo_profile, file_date: Date.today - 1.week)
        get api_v1_ipos_recently_filed_path, headers: headers
        payload = json_data[0]
        ipo_profile = IpoProfile.find(payload["id"])
        expect(payload.keys).to eq valid_keys
        expect(payload["attributes"]).to include valid_recently_filed_attributes(ipo_profile)
        expect(payload["relationships"]).to include valid_relationships(ipo_profile.company)
      end
    end

    it 'returns ipos by recently filed' do
      a = create(:ipo_profile, file_date: Date.today - 1.week)
      b = create(:ipo_profile, file_date: Date.today - 7.months)
      get api_v1_ipos_recently_filed_path, headers: headers

      expect(assigns(:ipos)).to include a
      expect(assigns(:ipos)).to_not include([b])
    end

    context 'pagination' do
      before(:each) do
        create_list(:ipo_profile, 90)
      end

      it 'paginates by collections of 30' do
        get api_v1_ipos_recently_filed_path, headers: headers
        expect(json_data.size).to eq 30
      end

      it 'has the correct top level pagination linkage' do
        get api_v1_ipos_recently_filed_path, headers: headers
        payload = json_pagination
        expect(payload).to include valid_pagination_linkage
      end
    end
  end

  describe 'GET #show' do
    let(:ipo_profile) { create(:ipo_profile) }
    let(:stock_ticker) { ipo_profile.company.stock_ticker }

    context 'status codes' do
      subject { get api_v1_ipo_profile_path(stock_ticker.ticker), headers: headers }
      it_behaves_like 'requests_and_status_codes'
    end

    context 'unauthorized' do
      context 'with missing api key' do
        it 'returns 401' do
          get api_v1_ipo_profile_path(stock_ticker.ticker)
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with a disabled key' do
        it 'returns 401' do
          get api_v1_ipo_profile_path(stock_ticker.ticker), headers: invalid_headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'bad media type' do
      it 'returns 406 if media type is not application/vnd.api+json' do
        get api_v1_ipo_profile_path(stock_ticker.ticker), headers: invalid_media_type
        expect(response).to have_http_status(:not_acceptable)
      end
    end

    context 'errors' do
      it 'returns 404 and error object if record is not found' do
        get api_v1_ipo_profile_path('NTFD'), headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'has the proper error json body structure' do
        get api_v1_ipo_profile_path('NTSD'), headers: headers
        expect(json_error[0]).to include valid_error('NTSD')
      end
    end

    it 'has the correct json body structure' do
      get api_v1_ipo_profile_path(stock_ticker.ticker), headers: headers
      payload = json_data

      expect(payload.keys).to eq valid_keys
      expect(payload["attributes"]).to include valid_attributes(stock_ticker.ipo_profile)
      expect(payload["relationships"]).to include valid_relationships(stock_ticker.company)
    end
  end
end
