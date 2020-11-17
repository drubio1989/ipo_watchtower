Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      defaults format: :api_json do
        get 'ipos-recently-filed', to: 'ipo_profiles#recently_filed', constraints: -> request { request.format == :api_json }
        get 'last-100-ipos', to: 'ipo_profiles#last_100', constraints: -> request { request.format == :api_json }
        get 'last-12-months', to: 'ipo_profiles#last_12_months', constraints: -> request { request.format == :api_json }
        get 'current-year-pricings', to: 'ipo_profiles#current_year_pricings', constraints: -> request { request.format == :api_json }
        get 'ipo-calendar', to: 'ipo_profiles#ipo_calendar', constraints: -> request { request.format == :api_json }
        get 'ipo-index', to: 'companies#index', constraints: -> request { request.format == :api_json }
      end

      defaults format: :api_json do
        get 'ipo_profiles/:ticker', to: 'ipo_profiles#show', as: 'ipo_profile', constraints: -> request { request.format == :api_json }
        get 'companies/:ticker', to: 'companies#show', as: 'company', constraints: -> request { request.format == :api_json }
      end
    end
  end

  defaults format: :api_json do
    match '*path', to: 'errors#unsupported_request', via: :all
  end
end
