namespace :email_notifications do
  desc "Sends subscribers their weekly upcoming ipo notification email"
  task send_upcoming_ipos_the_following_week: :environment do
    IpoNotificationMailer.send_weekly_notification.deliver_now
  end

  desc "Sends subscribers their day before notifications of ipo release"
  task send_day_of_ipo_release: :environment do
    IpoNotificationMailer.send_daily_notification.deliver_now
  end
end
