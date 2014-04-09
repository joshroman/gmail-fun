# Playing around with Ruby-Gmail gem

require 'gmail'
require './gmail_config'

gmail = Gmail.new(Gmail_Config::KOKO[:username], Gmail_Config::KOKO[:password])

inbox = gmail.inbox

puts "Total number of emails in inbox: #{inbox.count}"
puts "Total number of unread emails: #{inbox.count(:unread)}"

email = gmail.generate_message do
  from "josh@kokofitclub.com"
  to "joshroman@gmail.com"
  subject "You have #{inbox.count} emails in your inbox."
  body "Don't check them right now!"
end

# email.deliver!

gmail.logout
