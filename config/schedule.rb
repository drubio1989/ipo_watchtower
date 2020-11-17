# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every 1.day, at: '9:15 am' do
  rake "web_scrape:create_models"
  rake "web_scrape:create_models_two"
  rake "web_scrape:update_models"
  rake "web_scrape:update_models_two"
end

every 1.day, at: '5:15 pm' do
  rake "web_scrape:create_models"
  rake "web_scrape:create_models_two"
  rake "web_scrape:update_models"
  rake "web_scrape:update_models_two"
end

# Learn more: http://github.com/javan/whenever
