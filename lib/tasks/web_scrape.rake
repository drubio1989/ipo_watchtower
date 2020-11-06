require 'open-uri'

namespace :web_scrape do
  desc "Creates an ipo index"
  task populate_index: :environment do
    companies = []

    ('A'..'Z').to_a.each do |letter|
      html = URI.open(@url + "#{letter}/")
      doc = Nokogiri::HTML(html)
      company_names = doc.css('.ipo-index').css('a')
      company_names.each do |company|
        companies << Company.new(name: company.attributes['title'].value)
      end
    end

    Company.import companies, on_duplicate_key_ignore: true
  end
end

namespace :web_scrape do
  desc "Populates company and ipo_profile attributes. Should only have to be run twice."
  task populate_models: :environment do
  begin
    companies = []
    Company.all[0..1].each do |company|
      html = URI.open("https://www.iposcoop.com/ipo/#{company.slug}/")
  rescue OpenURI::HTTPError => e
      logger = Rails.logger
      logger.error("Populating attributes failed for #{company.name}. #{company.slug}" + ' ' + "#{e.message}")
  else
      doc = Nokogiri::HTML(html)

      description = ''
      doc.css('#main-content p').children.each do |info|
        description += info.text
      end
      company.description = description

      generalinfo_attrs = doc.css('tr:nth-child(5) .first+ td , .odd:nth-child(4) .first+ td , tr:nth-child(3) .first+ td').children.map(&:text)
      company.industry = generalinfo_attrs[0]
      company.employees = generalinfo_attrs[1].to_i
      company.founded = generalinfo_attrs[2].to_i

      contactinfo_attrs = doc.css('.odd:nth-child(9) .first+ td , tr:nth-child(8) .first+ td , .odd:nth-child(7) .first+ td').children.map(&:text)
      company.address = contactinfo_attrs[0]
      company.phone_number = contactinfo_attrs[1]

      financial_attrs = doc.css('.odd:nth-child(14) .first+ td , tr:nth-child(13) .first+ td , .odd:nth-child(12) .first+ td').children.map(&:text)

      market_cap = financial_attrs[0]
      revenue = financial_attrs[1]
      net_income = financial_attrs[2]
      company.market_cap = market_cap[1..(market_cap.index('m') - 1)].to_f
      company.revenue = revenue[1..(revenue.index('m') - 1)].to_f
      company.net_income = net_income[1..(net_income.index('m') - 1)].to_f

      ipo_profile_attrs = doc.css('.odd:nth-child(23) .first+ td , tr:nth-child(24) .first+ td , tr:nth-child(22) .first+ td , .odd:nth-child(21) .first+ td , tr:nth-child(20) .first+ td , .odd:nth-child(19) .first+ td , tr:nth-child(18) .first+ td , .odd:nth-child(17) .first+ td , tr:nth-child(16) .first+ td').map(&:text)
      expected_to_trade = ipo_profile_attrs[7].strip.split('/').map(&:to_i)
      ipo_profile = company.build_ipo_profile(
        symbol: ipo_profile_attrs[0],
        exchange: ipo_profile_attrs[1],
        shares: ipo_profile_attrs[2].to_f,
        price_low: ipo_profile_attrs[3].gsub('$','').split('-').map(&:to_f)[0],
        price_high: ipo_profile_attrs[3].gsub('$','').split('-').map(&:to_f)[1],
        estimated_volume: ipo_profile_attrs[4][1..(ipo_profile_attrs[4].index('m') - 1)].to_f,
        managers: ipo_profile_attrs[5].strip,
        co_managers: ipo_profile_attrs[6].strip,
        expected_to_trade: Date.new(expected_to_trade[2],expected_to_trade[0],expected_to_trade[1]),
        status: ipo_profile_attrs[8]
      )
      companies << company
    end
  end
    Company.import companies, recursive: true, on_duplicate_key_update: [:industry, :employees, :founded, :address, :phone_number, :market_cap, :revenue, :net_income]
  end
end
