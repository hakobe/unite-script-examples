require 'net/http'
require 'uri'
require 'json'
require 'yaml'

# save token configuration at ~/.unitescriptrc as yaml
#
# github-notify:
#   - api_base: https://api.github.com
#     oauth_token: abcd1234

CONFIG = '~/.unitescriptrc'
configs = YAML.load( File.open(File.expand_path( CONFIG )) {|f| f.read } ).fetch('github-notify', [])

configs.each do |config|
  api_url = URI.parse( config['api_base'] + '/notifications' )
  
  http = Net::HTTP.new(api_url.host, api_url.port)
  http.use_ssl = true
  http.open_timeout = 3
  http.start do |http|
    res = http.get(api_url.path, { 'Authorization' => "token #{ config['oauth_token'] }"} )
    results = JSON.parse(res.body)
    results.each do |notify|
      puts "#{ notify['subject']['type']}/#{ notify['reason']} #{ notify['subject']['title'] }\tcall unite#util#open('#{ notify['subject']['url'] }')"
    end
  end
end
