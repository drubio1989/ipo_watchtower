# Developer note: I could either have used smtp settings or the aws sdk.
class IpoNotificationMailer < ApplicationMailer
  default from: 'contact@ipowatchtower.com', to: 'drubio1989@gmail.com'

  def send_weekly_notification
    @ipos = IpoProfile.includes(company: :stock_ticker).where("DATE(expected_to_trade) >= ?", Date.today.beginning_of_week).order(expected_to_trade: :desc)
    mail(subject: 'Upcoming Ipos This Week.')
  end

  def send_daily_notification
    @ipos = IpoProfile.includes(company: :stock_ticker).where("DATE(expected_to_trade) = ?", Date.today)
    mail(subject: 'Ipos Trading Today.')
  end
end
