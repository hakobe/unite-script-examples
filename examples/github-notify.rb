require 'net/http'
require 'uri'
require 'json'
require 'yaml'
require 'openssl'

# save token configuration at ~/.unitescriptrc as yaml
#
# github-notify:
#   github
#     - api_base: https://api.github.com
#       oauth_token: abcd1234
#   open_command: open

CONFIG = '~/.unitescriptrc'

def config
  YAML.load( File.open(File.expand_path( CONFIG )) {|f| f.read } ).fetch('github-notify', {})
end

def fetch_json(url)
  github_config = config['github'].find {|c| /^#{c['api_base']}/.match(url.to_s) }

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # XXX
  http.open_timeout = 3
  http.start do
    res = http.get(url.path, { 'Authorization' => "token #{ github_config['oauth_token'] }"} )
    JSON.parse(res.body)
  end
end

def open_subject(resource_url)
  resource_url = URI.parse(resource_url)
  html_url = fetch_json(resource_url)['html_url']
  system("#{ config['open_command'] } #{ html_url }")
end

def list
  config['github'].each do |github_config|
    api_url = URI.parse( github_config['api_base'] + '/notifications' )

    results = fetch_json(api_url)
    results.each do |notify|
      puts "[#{notify['repository']['name']} #{ notify['subject']['type']}] #{ notify['subject']['title'] }\t" +
        "call unite#util#system('ruby #{  File.expand_path(__FILE__) } open #{ notify['subject']['url'] }')"
    end
  end
end

command = ARGV.shift

case command
when 'open'
  open_subject(*ARGV)
else
  list
end
