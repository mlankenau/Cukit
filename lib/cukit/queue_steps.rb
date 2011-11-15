
require 'bunny'

# start the service
thread = Thread.new do
  puts "starting processort"
  Processor.start
  puts "processor finished"
end
sleep 5

When /^we enqueue '([^']*)' with routingkey "([^"]*)" to "([^"]*)"$/ do |msg, routing_key, exchange|
  b = Bunny.new(:logging => false)
  b.start
  e = b.exchange(exchange, :type => :topic)
  e.publish(msg, :key => routing_key)
  b.stop
end

Given /^the queue "([^"]*)" is empty$/ do |queue|
  b = Bunny.new(:logging => false)
  b.start
  q = b.queue(queue)
  loop do 
    msg = q.pop
    break if (msg[:payload] == :queue_empty)
  end
  b.stop
end

Then /^we have (\d+) messages in queue "([^"]*)"$/ do |n, queue|
  b = Bunny.new(:logging => false)
  b.start
  q = b.queue(queue)
  count = 0
  loop do 
    msg = q.pop
    break if (msg[:payload] == :queue_empty)
    puts msg.inspect
    count = count + 1
  end
  b.stop
  raise "there were #{count} messages instead" if count != n.to_i
end
