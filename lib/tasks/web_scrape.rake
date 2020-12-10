require 'open-uri'

namespace :web_scrape do
  desc "Creates an ipo index"
  task populate_index: :environment do
  begin
    companies = []

    ('A'..'Z').to_a.each do |letter|
      html = URI.open("https://www.iposcoop.com/ipo-index/#{letter}/")
      doc = Nokogiri::HTML(html)
      company_names = doc.css('.ipo-index').css('a')
      company_names.each do |company|
        companies << Company.new(name: company.attributes['title'].value)
      end
    end
  rescue OpenURI::HTTPError, StandardError => e
    logger = Logger.new("#{Rails.root}/log/#{Date.today}-scraping.log")
    logger.info("Scrape took place on: #{Date.today}")
    logger.error("Populating attributes failed for #{company.name}. #{company.slug}" + ' ' + "#{e.message}")
  end
    Company.import companies, on_duplicate_key_update: true
  end
end

namespace :web_scrape do
  task update_company_attributes: :environment do
  begin
    companies = []
    Company.all.each do |company|
      html = URI.open("https://www.iposcoop.com/ipo/#{company.slug}/")
      doc = Nokogiri::HTML(html)

      description = ''
      doc.css('#main-content p').children.each do |info|
        description += info.text
      end
      company.description = description

      general_info = doc.css('tr:nth-child(5) .first+ td , .odd:nth-child(4) .first+ td , tr:nth-child(3) .first+ td').children.map(&:text)
      company.industry = general_info[0]
      company.employees = general_info[1].to_i
      company.founded = general_info[2].to_i

      contact_info= doc.css('.odd:nth-child(9) .first+ td , tr:nth-child(8) .first+ td , .odd:nth-child(7) .first+ td').children.map(&:text)
      company.address = contact_info[0]
      company.phone_number = contact_info[1]
      company.web_address = doc.css('.odd:nth-child(9) a').text

      financials = doc.css('.odd:nth-child(14) .first+ td , tr:nth-child(13) .first+ td , .odd:nth-child(12) .first+ td').children.map(&:text)

      market_cap, revenue, net_income = financials[0], financials[1], financials[2]

      if market_cap.nil?
        company.market_cap = ''
      else
        company.market_cap = market_cap[1..(market_cap.index('m') - 1)].to_f
      end

      if revenue.nil?
        company.revenue = ''
      else
        company.revenue = revenue[1..(revenue.index('m') - 1)].to_f
      end

      if net_income.nil?
        company.net_income = ''
      else
        company.net_income = net_income[1..(net_income.index('m') - 1)].to_f
      end
      companies << company
  rescue OpenURI::HTTPError, StandardError => e
      logger = Logger.new("#{Rails.root}/log/#{Date.today}-scraping.log")
      logger.info("Scrape took place on: #{Date.today}")
      logger.error("Populating attributes failed for #{company.name}. #{company.slug}" + ' ' + "#{e.message}")
    end
  end
    Company.import companies, on_duplicate_key_update: [:industry, :employees, :founded, :address, :phone_number, :market_cap, :revenue, :net_income, :description]
  end
end

namespace :web_scrape do
  task update_ipo_attributes: :environment do
  begin
    ipos = []
    Company.all.each do |company|
      html = URI.open("https://www.iposcoop.com/ipo/#{company.slug}/")
      doc = Nokogiri::HTML(html)

      expected_to_trade = doc.css('.odd:nth-child(23) .first+ td').children.first.text.strip.split('/').map(&:to_i)
      expected_to_trade.empty? ? expected_to_trade = '' : expected_to_trade = Date.new(expected_to_trade[2], expected_to_trade[0], expected_to_trade[1])

      ipo_profile = company.ipo_profile
      ipo_profile.expected_to_trade = expected_to_trade
      ipo_profile.co_managers = doc.css('tr:nth-child(22) .first+ td').text.strip
      ipo_profile.exchange = doc.css('.odd:nth-child(17) .first+ td').text.strip
      ipos << ipo_profile
  rescue OpenURI::HTTPError, StandardError => e
      logger = Logger.new("#{Rails.root}/log/#{Date.today}-scraping.log")
      logger.info("Scrape took place on: #{Date.today}")
      logger.error("Populating attributes failed for #{company.name}. #{company.slug}" + ' ' + "#{e.message}")
    end
  end
    IpoProfile.import ipos, on_duplicate_key_update: [:exchange, :expected_to_trade, :co_managers]
  end
end

namespace :web_scrape do
  task create_models: :environment do
  begin
    stock_tickers = []

    html = URI.open("https://www.iposcoop.com/last-12-months/")
    doc = Nokogiri::HTML(html)

    company_names = doc.css('td:nth-child(1)').map(&:text)
    tickers = doc.css('td:nth-child(2)').map(&:text)
    industries = doc.css('td:nth-child(3)').map(&:text)
    offer_dates = doc.css('td:nth-child(4)').map(&:text)
    shares = doc.css('td:nth-child(5)').map(&:text)
    offer_prices = doc.css('td:nth-child(6)').map(&:text)
    first_day_close_prices = doc.css('td:nth-child(7)').map(&:text)
    current_prices = doc.css('td:nth-child(8)').map(&:text)
    rate_of_returns = doc.css('td:nth-child(9)').map(&:text)

    doc.css('td:nth-child(1)').size.times do |counter|
      next if StockTicker.exists?(ticker: tickers[counter])
      offer_date = offer_dates[counter].split('/').map(&:to_i)
      stock_ticker = StockTicker.new(ticker: tickers[counter])
      company = stock_ticker.build_company(name: company_names[counter])
      company.build_ipo_profile(
        industry: industries[counter],
        offer_date: Date.new(offer_date[2], offer_date[0], offer_date[1]),
        shares: shares[counter],
        offer_price: offer_prices[counter][1..-1].to_f,
        first_day_close_price: first_day_close_prices[counter][1..-1].to_f,
        current_price: current_prices[counter][1..-1].to_f,
        rate_of_return: rate_of_returns[counter][0..-2].to_f
      )
      stock_tickers << stock_ticker
    end
  rescue OpenURI::HTTPError => e
    logger = Logger.new("#{Rails.root}/log/#{Date.today}-scraping.log")
    logger.info("Scrape took place on: #{Date.today}")
    logger.error("https://www.iposcoop.com/last-12-months/ was an unable to be scraped #{e.message}")
  end
    StockTicker.import stock_tickers, recursive: true
  end
end

namespace :web_scrape do
  task create_models_two: :environment do
  begin
    stock_tickers = []

    html = URI.open("https://www.iposcoop.com/ipos-recently-filed/")
    doc = Nokogiri::HTML(html)

    file_dates = doc.css('td:nth-child(1)').map(&:text)
    company_names = doc.css('td:nth-child(2)').map(&:text)
    tickers = doc.css('td:nth-child(3)').map(&:text)
    managers = doc.css('td:nth-child(4)').map(&:text)
    shares = doc.css('td:nth-child(5)').map(&:text)
    price_low = doc.css('td:nth-child(6)').map(&:text)
    price_high = doc.css('td:nth-child(7)').map(&:text)
    estimated_volume = doc.css('td:nth-child(8)').map(&:text)
    statuses = doc.css('td:nth-child(9)').map(&:text)

    doc.css('td:nth-child(2)').size.times do |counter|
      next if StockTicker.exists?(ticker: tickers[counter])
      stock_ticker = StockTicker.new(ticker: tickers[counter])
      company = stock_ticker.build_company(name: company_names[counter])
      statuses[counter] = '' if [statuses[counter]].include? %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
      company.build_ipo_profile(
        file_date: Date.parse(file_dates[counter]),
        managers: managers[counter],
        shares: shares[counter].to_f,
        price_low: price_low[counter][1..-1].to_f,
        price_high: price_high[counter][1..-1].to_f,
        estimated_volume: estimated_volume[counter][1..-1].to_f,
        status: statuses[counter].strip
      )
      stock_tickers << stock_ticker
    end
  rescue OpenURI::HTTPError => e
    logger = Logger.new("#{Rails.root}/log/#{Date.today}-scraping.log")
    logger.info("Scrape took place on: #{Date.today}")
    logger.error("https://www.iposcoop.com/ipos-recently-filed/ was an unable to be scraped #{e.message}")
  end
    StockTicker.import stock_tickers, recursive: true
  end
end

namespace :web_scrape do
  task update_models: :environment do
  begin
    ipos = []

    html = URI.open("https://www.iposcoop.com/last-12-months/")
    doc = Nokogiri::HTML(html)

    company_names = doc.css('td:nth-child(1)').map(&:text)
    tickers = doc.css('td:nth-child(2)').map(&:text)
    industries = doc.css('td:nth-child(3)').map(&:text)
    offer_dates = doc.css('td:nth-child(4)').map(&:text)
    shares = doc.css('td:nth-child(5)').map(&:text)
    offer_prices = doc.css('td:nth-child(6)').map(&:text)
    first_day_close_prices = doc.css('td:nth-child(7)').map(&:text)
    current_prices = doc.css('td:nth-child(8)').map(&:text)
    rate_of_returns = doc.css('td:nth-child(9)').map(&:text)

    doc.css('td:nth-child(1)').size.times do |counter|
      next unless StockTicker.exists?(ticker: tickers[counter])
      offer_date = offer_dates[counter].split('/').map(&:to_i)
      stock_ticker = StockTicker.find_by(ticker: tickers[counter])
      ipo_profile = stock_ticker.ipo_profile
      ipo_profile.industry = industries[counter]
      ipo_profile.offer_date = Date.new(offer_date[2], offer_date[0], offer_date[1])
      ipo_profile.shares = shares[counter]
      ipo_profile.offer_price = offer_prices[counter][1..-1].to_f
      ipo_profile.first_day_close_price = first_day_close_prices[counter][1..-1].to_f
      ipo_profile.current_price = current_prices[counter][1..-1].to_f
      ipo_profile.rate_of_return = rate_of_returns[counter][0..-2].to_f
      ipos << ipo_profile
    end
  rescue OpenURI::HTTPError => e
    logger = Logger.new("#{Rails.root}/log/#{Date.today}-scraping.log")
    logger.info("Scrape took place on: #{Date.today}")
    logger.error("https://www.iposcoop.com/last-12-months/ was an unable to be scraped #{e.message}")
  end
    IpoProfile.import ipos, on_duplicate_key_update: [:industry, :offer_date, :shares, :offer_price, :first_day_close_price, :current_price, :rate_of_return]
  end
end

namespace :web_scrape do
  task update_models_two: :environment do
  begin
    ipos = []
    html = URI.open("https://www.iposcoop.com/ipos-recently-filed/")
    doc = Nokogiri::HTML(html)

    file_dates = doc.css('td:nth-child(1)').map(&:text)
    company_names = doc.css('td:nth-child(2)').map(&:text)
    tickers = doc.css('td:nth-child(3)').map(&:text)
    managers = doc.css('td:nth-child(4)').map(&:text)
    shares = doc.css('td:nth-child(5)').map(&:text)
    price_low = doc.css('td:nth-child(6)').map(&:text)
    price_high = doc.css('td:nth-child(7)').map(&:text)
    estimated_volume = doc.css('td:nth-child(8)').map(&:text)
    status = doc.css('td:nth-child(9)').map(&:text)

    doc.css('td:nth-child(2)').size.times do |counter|
      next unless StockTicker.exists?(ticker: tickers[counter])
      status[counter] = '' if [status[counter]].include? %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]

      if tickers[counter] == 'TBA'
        next
      else
        stock_ticker = StockTicker.find_by(ticker: tickers[counter])
        ipo_profile = stock_ticker.ipo_profile
        ipo_profile.file_date = Date.parse(file_dates[counter])
        ipo_profile.managers = managers[counter]
        ipo_profile.shares = shares[counter]
        ipo_profile.price_low = price_low[counter][1..-1].to_f
        ipo_profile.price_high = price_high[counter][1..-1].to_f
        ipo_profile.estimated_volume = estimated_volume[counter][1..-1].to_f
        ipo_profile.status = status[counter].strip
        ipos << ipo_profile
      end
    end
  rescue OpenURI::HTTPError => e
    logger = Logger.new("#{Rails.root}/log/#{Date.today}-scraping.log")
    logger.info("Scrape took place on: #{Date.today}")
    logger.error("https://www.iposcoop.com/ipos-recently-filed/ was an unable to be scraped #{e.message}")
  end
    ipos.uniq!
    IpoProfile.import ipos, on_duplicate_key_update: [:file_date, :managers, :shares, :price_low, :price_high, :estimated_volume, :status]
  end
end
