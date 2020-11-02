require 'open-uri'

module WebScraper
  class IpoDataCreator < ApplicationService
    def initialize(url)
      @url = url # https://www.iposcoop.com/ipo-index/
    end

    def call
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
end
