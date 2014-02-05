require 'net/http'
require 'uri'
require 'json'

API_URL = URI.parse('https://api.github.com/notifications?all=1')

http = Net::HTTP.new(API_URL.host, API_URL.port)
http.use_ssl = true
http.start do |http|
  res = http.get(API_URL.path, { 'Authorization' => "token #{ ENV['GITHUB_TOKEN'] }"} )
  results = JSON.parse(res.body)
  results.each do |notify|
    puts "#{ notify['subject']['title'] }\tcall unite#util#open('#{ notify['subject']['url'] }')"
  end
end
