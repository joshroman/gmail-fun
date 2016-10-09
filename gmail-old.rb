# Playing around with Gmail gem
# https://github.com/nu7hatch/gmail

require 'gmail'
require 'date'
require 'active_support'
require 'active_support/core_ext'
require './gmail_config'

gmail = Gmail.connect(Gmail_Config::KOKO[:username], Gmail_Config::KOKO[:password])

inbox = gmail.inbox
expenses = gmail.label("Expenses")
last_month = Date.today.month - 1
prev_month_expenses = expenses.find(:before => Date.today.beginning_of_month, :after => Date.today.beginning_of_month.last_month)


puts "Total number of emails in inbox: #{inbox.count}"
puts "Total number of unread emails: #{inbox.count(:unread)}"
puts "Total number of 'Expenses' emails last month: #{prev_month_expenses.count}"
prev_month_expenses.each {|email| puts "#{email.date} - #{email.subject}"}
#puts "All labels: #{gmail.labels.all}"
#puts "Total number of 'Expenses' emails: #{expenses.count}"

i = 0
prev_month_expenses.each do |email|

  new_email = gmail.compose do
    to "#{Gmail_Config::KOKO[:recipient]}"
    subject "Josh Expenses: #{email.subject}"
    content_type 'text/html; charset=UTF-8'
    body "#{email.body}"
    email.attachments.each do |attachment|
      add_file email.attachment
    end
  end

  gmail.deliver(new_email)

  i += 1
  puts "Sent email number #{i} of #{prev_month_expenses.count}"

end

gmail.logout
