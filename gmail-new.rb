# Playing around with Gmail gem
# https://github.com/nu7hatch/gmail

require 'gmail'
require 'date'
require 'active_support'
require 'active_support/core_ext'
require 'fileutils'
require './gmail_config'

gmail = Gmail.connect(Gmail_Config::KOKO[:username], Gmail_Config::KOKO[:password])

i = 0
last_month = Date.today.month - 1

month_name = "SEPT"

forwardable_mail = gmail.mailbox("Expenses").emails(gm: 'after:2016-08-30 before:2016-10-01' )
# forwardable_mail = gmail.mailbox("Expenses").emails(:before => Date.today.beginning_of_month, :after => Date.today.beginning_of_month.last_month)


forwardable_mail.each do |email|

  new_email = gmail.compose do
    to "#{Gmail_Config::KOKO[:recipient]}"
    subject "JR #{month_name} Exp: #{email.subject}: #{email.date.to_s}"

    # SINGLE-PART EMAILS
    if email.content_type == "text/plain"
      content_type "text/plain"
      body "#{email.body}"
    else
      content_type "text/html"
      body "#{email.body}"
    end

    # MULTI-PART EMAILS
    if email.text_part
        text_part do
          content_type "#{email.text_part.content_type}; #{email.text_part.content_type_parameters}"
          body "#{email.text_part}"
        end
    end

    if email.html_part
      unless email.html_part.content_transfer_encoding == "base64"
        html_part do
          content_type "#{email.html_part.content_type}; #{email.html_part.content_type_parameters}"
          content_transfer_encoding = "#{email.html_part.content_transfer_encoding}"
          body "#{email.html_part.decoded}"
        end
      end
    end

    email.attachments.each do |attachment|
      unless File.exists?("images/#{Date.today}")
        FileUtils.mkdir_p "images/#{Date.today}"
      end

      filename = attachment.filename
      begin
        File.open("images/#{Date.today}/" + filename, "w+b", 0644) {|f| f.write attachment.body.decoded}
      rescue => e
        puts "Unable to save data for #{filename} because #{e.message}"
      end

      add_file "images/#{Date.today}/#{filename}"
    end
  end

  gmail.deliver(new_email)

  i += 1
  puts "Sent email number #{i} of #{forwardable_mail.count}"

end

puts "**** WELL DONE, SIR! ****"

gmail.logout
