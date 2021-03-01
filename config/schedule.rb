# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every 1.day, at: ['12:00 pm', '4:15 pm'] do
  rake "web_scrape:create_models"
  rake "web_scrape:create_models_two"
  rake "web_scrape:update_models"
  rake "web_scrape:update_models_two"
  rake "web_scrape:daily_update"
end

every :sunday, at: '6pm' do
  rake "email_notifications:send_upcoming_ipos_the_following_week"
end

every 1.day, at: '8am' do
  rake "email_notifications:send_day_of_ipo_release"
end

# Learn more: http://github.com/javan/whenever
