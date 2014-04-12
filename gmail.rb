# Playing around with Gmail gem
# https://github.com/nu7hatch/gmail

require 'gmail'
require './gmail_config'

gmail = Gmail.connect(Gmail_Config::KOKO[:username], Gmail_Config::KOKO[:password])

inbox = gmail.inbox
expenses = gmail.label("Expenses")
march_expenses = expenses.find(:before => Date.parse("2014-04-01"), :after => Date.parse("2014-03-01"))

puts "Total number of emails in inbox: #{inbox.count}"
puts "Total number of unread emails: #{inbox.count(:unread)}"
puts "All labels: #{gmail.labels.all}"
puts "Total number of 'Expenses' emails: #{expenses.count}"
puts "Total number of 'Expenses' emails in March: #{march_expenses.count}"
march_expenses.each {|email| puts "#{email.date} - #{email.subject}"}

i = 0
march_expenses.each do |email|
  # make this a #forward method...
  new_email = gmail.compose do
    to "sharon@kokofitclub.com"
    subject "Josh Expenses: #{email.subject}"
    # is there a #message method?
    body "#{email.body}"
    # what about attachments?
  end
  gmail.deliver(new_email)
  i += 1
  puts "Sent email number #{i} of #{march_expenses.count}"
  
end
  
gmail.logout
