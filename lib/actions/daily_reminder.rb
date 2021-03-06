require "date"
require "./lib/emailer"

# Sends a notification containing all bullets with a specified date
class DailyReminder
  attr_reader :document, :notifier, :date
  private :document, :notifier, :date

  def initialize(document:, notifier: Emailer, date: Date.today)
    @document = document
    @notifier = notifier
    @date     = date
  end

  def execute
    bullets = document
      .with_date(date)
      .unchecked
      .bullets

    notifier.send_notification(html(bullets)) unless bullets.empty?
  end

  private

  def html(bullets)
    <<~HTML
      <ul>
      #{bullets.map(&:to_html).join.strip}
      </ul>
    HTML
  end
end
