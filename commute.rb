#!/usr/bin/env ruby
# commute.rb - a little program to SMS real-time traffic information
# 
# example crontab entry:
# 30 17 * * 1-5 /path/to/commute.rb -t '+19175551212' -a '1500 market street, philadelphia, pa' -b '160 N Gulph Rd, King of Prussia, PA'
require 'rubygems'
require 'rest-client'
require 'json'
require 'pp'
require 'twilio-ruby'
require 'uri'
require 'optparse'

# Twilio API Settings
account_sid = ''
auth_token = ''

# VirtualEarth API Settings
map_key = ''

OPTIONS = {
	:sms_from => '+19175559999', # Your twilio phone number
	:sms_to=> '',

	:point_a => "",
	:point_b => "",
	
	:threshold => 0
}

ARGV.options do |opts|
	script_name = File.basename($0)
	opts.banner = "Usage: #{script_name} [options]"
	
	opts.separator ""
	opts.on("-f", "--from SOURCE", String,
		"Specifies the number to send the SMS from",
		"Default: #{OPTIONS[:sms_from]}") { |v| OPTIONS[:sms_from] = v }

	opts.on("-t", "--to DESTINATION", String,
		"Specifies the number to send the SMS to",
		"Default: #{OPTIONS[:sms_to]}") { |v| OPTIONS[:sms_to] = v }

	opts.on("-a", "--pointa ADDRESS", String,
		"Specifies the starting address (e.g. 1500 Market Street Philadelphia PA)",
		"Default: #{OPTIONS[:point_a]}") { |v| OPTIONS[:point_a] = v }

	opts.on("-b", "--pointb ADDRESS", String,
		"Specifies the ending address (e.g. 160 N Gulph Rd King of Prussia PA)",
		"Default: #{OPTIONS[:point_b]}") { |v| OPTIONS[:point_b] = v }

  opts.on("-d", "--duration DURATION", Integer,
  	"Specifies the notification threshold in minutes. No message will be sent unless threshold is exceeded.",
  	"Default: #{OPTIONS[:threshold]}") { |v| OPTIONS[:threshold] = v }

	opts.parse!
end

split_token = 'Zy4AmhWfARkK'

sms_from = OPTIONS[:sms_from]
sms_to = OPTIONS[:sms_to]

# Format duration strings
def dstr(secs)
	"#{(secs.to_f/60.0).round}m"
end

# this is a really mediocre way to get road names,
# but it works adequately for my commute
def roadname(details)
	details.last['names'].to_s.gsub(/[\"\[\]]/,'')
end

# Build/fetch the URL
point_a = URI.escape(OPTIONS[:point_a], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
point_b = URI.escape(OPTIONS[:point_b], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
url = 'http://dev.virtualearth.net/REST/v1/Routes?wayPoint.1=' + point_b + '&wayPoint.2=' + point_a + '&optimize=timeWithTraffic&distanceUnit=mi&key=' + map_key
response = RestClient.get(url)

# Parse the map server response
h = JSON.parse(response.body)
duration = h['resourceSets'][0]['resources'][0]['travelDuration'].to_i

# 
if duration.to_i < (OPTIONS[:threshold].to_i * 60)
  exit 0
else
  str = ""
  str << "Current Commute: #{dstr(duration)}\n\n"

  segments = h['resourceSets'][0]['resources'][0]['routeLegs'][0]['itineraryItems']

  # Build a response, excluding segments under 4 mins, and segments w/o details
  segments.each do |segment|
  	next if roadname(segment['details']).nil?
  	next if segment['travelDuration'] < 240

  	str << "#{roadname(segment['details'])} (#{dstr(segment['travelDuration'])})"
  	if segment['warnings']
  		str << " (#{segment['warnings'][0]['severity']}: #{segment['warnings'][0]['text'].chomp})"
  	end
  	str << "\n"
  end
  str.chomp!

  # Split message over multiple messages if it's too long
  maxlen = 150
  sms = str.gsub(/(.{1,#{maxlen}})(?: +|$)\n?|(.{#{maxlen}})/m, "#{split_token}\\1\\2\n")
  messages = sms.split(split_token).delete_if { |x| x.empty? }

  # Send the Twilio
  @client = Twilio::REST::Client.new account_sid, auth_token
  messages.each_with_index do |message, i|
  	message = "(#{i+1}/#{messages.size}) #{message}" if messages.size > 1
  	@client.account.sms.messages.create(
  		:from => sms_from,
  		:to => sms_to,
  		:body => message
  	)
  	sleep 4 # a sloppy but seemingly sufficient way to get the messages to show up in order
  end
end