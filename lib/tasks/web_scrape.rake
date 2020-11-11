require 'open-uri'

namespace :web_scrape do
  desc "Creates an ipo index"
  task populate_index: :environment do
    companies = []

    ('A'..'Z').to_a.each do |letter|
      html = URI.open("https://www.iposcoop.com/ipo-index/#{letter}/")
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
  task populate_company: :environment do
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
      companies << company
  rescue OpenURI::HTTPError, StandardError => e
      logger = Rails.logger
      logger.error("Populating attributes failed for #{company.name}. #{company.slug}" + ' ' + "#{e.message}")
    end
  end
    Company.import companies, recursive: true, on_duplicate_key_update: [:industry, :employees, :founded, :address, :phone_number, :market_cap, :revenue, :net_income]
  end
end

# namespace :web_scrape do
#   task populate_last_12_months: :environment do
#   begin
#     ipos = []
#     html = URI.open("https://www.iposcoop.com/last-12-months/")
#     doc = Nokogiri::HTML(html)
#
#     companies = doc.css('td:nth-child(1)').map(&:text)
#     offer_dates = doc.css('td:nth-child(4)').map(&:text)
#     shares = doc.css('td:nth-child(5)').map(&:text)
#     offer_price = doc.css('td:nth-child(6)').map(&:text)
#     first_day_close_price = doc.css('td:nth-child(7)').map(&:text)
#     current_price = doc.css('td:nth-child(8)').map(&:text)
#     rate_of_return = doc.css('td:nth-child(9)').map(&:text)
#
#     doc.css('td:nth-child(2)').size.times do |counter|
#       company_name = companies[counter]
#       date = offer_dates[counter].split('/').map(&:to_i)
#
#       company = Company.find_by(name: company_name)
#       ipo_profile = company.ipo_profile
#       ipo_profile.offer_date = Date.new(date[2], date[0], date[1])
#       ipo_profile.offer_price = offer_price[counter][1..-1].to_f
#       ipo_profile.first_day_close_price = first_day_close_price[counter][1..-1].to_f
#       ipo_profile.current_price = current_price[counter][1..-1].to_f
#       ipo_profile.rate_of_return = rate_of_return[counter][1..-2].to_f
#       ipos << ipo_profile
#   rescue StandardError => e
#     logger = Rails.logger
#     logger.error("Information unable to be populated for #{company_name}#{e}")
#   end
#     end
#     IpoProfile.import ipos, on_duplicate_key_update: [:offer_date, :offer_price, :first_day_close_price, :current_price, :rate_of_return]
#   end
# end
#
# namespace :web_scrape do
#   task populate_recently_filed: :environment do
#     companies= []
#     html = URI.open("https://www.iposcoop.com/ipos-recently-filed/")
#     doc = Nokogiri::HTML(html)
#
#     counter = 0
#     file_dates = doc.css('td:nth-child(1)').map(&:text)
#     company_names = doc.css('td:nth-child(2)').map(&:text)
#     symbols = doc.css('td:nth-child(3)').map(&:text)
#     managers = doc.css('td:nth-child(4)').map(&:text)
#     shares = doc.css('td:nth-child(5)').map(&:text)
#     price_low = doc.css('td:nth-child(6)').map(&:text)
#     price_high = doc.css('td:nth-child(7)').map(&:text)
#     estimated_volume = doc.css('td:nth-child(8)').map(&:text)
#     status = doc.css('td:nth-child(9)').map(&:text)
#
#     doc.css('td:nth-child(2)').size.times do |counter|
#       #TODO: Take into account IMNM
#       next '' if symbols[counter] == 'IMNM'
#       status[counter] = '' if [status[counter]].include? %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
#       company = Company.new(name: company_names[counter])
#       company.build_ipo_profile(
#         file_date: Date.parse(file_dates[counter]),
#         symbol: symbols[counter],
#         managers: managers[counter],
#         shares: shares[counter].to_f,
#         price_low: price_low[counter][1..-1].to_f,
#         price_high: price_high[counter][1..-1].to_f,
#         estimated_volume: estimated_volume[counter][1..-1].to_f,
#         status: status[counter].strip
#       )
#
#       companies << company
#       counter += 1
#     end
#
#     Company.import companies, recursive: true
#   end
# end
