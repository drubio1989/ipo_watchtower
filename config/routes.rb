Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'ipos-recently-filed', to: 'ipo_profiles#recently_filed'
      get 'last-100-ipos', to: 'ipo_profiles#last_100'
      get 'last-12-months', to: 'ipo_profiles#last_12_months'
      get 'current-year-pricings', to: 'ipo_profiles#current_year_pricings'
      get 'ipo-calendar', to: 'ipo_profiles#ipo_calendar'
      get 'ipo-index', to: 'companies#index'

      scope :ipo do
        resources :companies, only: [:show]
      end
    end
  end
end
