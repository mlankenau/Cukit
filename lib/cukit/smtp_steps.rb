require 'rubygems'
require 'socket'

$mails = []
$last_mail = nil
$smtp = nil

#
# SMTP mock
#
def start_smtp
  $smtp = Thread.new do 
    puts "starting smtp on 10025"
    server = TCPServer.open(10025)
    loop do
      client = server.accept
      puts "got connection"
      client.puts "220 service ready"

      mail = {}
      mode = :header
      loop do
        line = client.gets

        if (line.strip == "SHUTDOWN")
          puts "SMTP: i have to go..."
          client.close
          server.close
          raise "end"
        end
        #puts "we got #{line}"
        if mode == :header
          if line =~ /HELO (.*)/
            client.puts "250 OK"  
          elsif line=~ /EHLO (.*)/
            client.puts "250 OK"
          elsif line =~ /MAIL FROM:(.*)/
            mail[:from] = $~[1].strip
            client.puts "250 OK"
          elsif line =~ /RCPT TO:(.*)/
            mail[:to] = $~[1].strip
            client.puts "250 OK"
          elsif line =~ /DATA/
            client.puts "354 start mail input"
            mode = :data
          end
        elsif mode== :data
          mail[:data] ||= ""
          mail[:data] = mail[:data] + line
          if line.strip == "."
            $mails << mail
            client.close
            break
          end
        end
      end
    end
  end
end

Given /^the SMTP is available$/ do
  start_smtp
end


Given /^the SMTP is NOT available$/ do
  if $smtp
    socket = TCPSocket.new "localhost", 10025
    socket.puts "SHUTDOWN"
    $smtp = nil
  end
end


Then /^a mail is sent to "([^"]*)"$/ do |to|
  start = Time.now
  while $mails.size == 0 and (Time.now - start) < 5 do
    sleep 0.5
  end
  raise "got no mail" if ($mails.size == 0) 
  $last_mail = $mails.delete_at(0)
  raise "mail is send to #{$last_mail[:to]} instead to #{to}" if to != $last_mail[:to]
end

Then /^the body contains "([^"]*)"$/ do |pattern|
  raise "it does not contain #{pattern}" if $last_mail[:data].include?(pattern)
end
