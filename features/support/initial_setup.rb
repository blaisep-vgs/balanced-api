require 'httparty'
require 'json'
require 'coveralls'
Coveralls.wear!

# TODO: move this into the lib
$root_url = ENV['BALANCED_ROOT'] || 'https://api.balancedpayments.com'
$accept_header = 'application/vnd.api+json;revision=1.1'

# First, we need to create an API key. This is as easy as making a POST request.

options = {
  headers: {
    "Accept" => $accept_header,
  },
}
response = HTTParty.post("#{$root_url}/api_keys", options)
$api_secret = JSON.parse(response.body)["api_keys"][0]["secret"]
puts "SECRET: #{$api_secret}"

# Now that we have our key, we need to make a marketplace. Lots of our scenarios
# will fail unless we've made at least one.

options = {
  headers: {
    "Accept" => $accept_header,
  },
  basic_auth: {
    username: $api_secret,
    password: ""
  },
}

response = HTTParty.post("#{$root_url}/marketplaces", options)
marketplace_id = response["marketplaces"][0]["id"]
puts "MARKETPLACE: #{marketplace_id}"

# create an initial amount of money in the marketplace
# Sorry, whoever owns this card. ;)
HTTParty.post("#{$root_url}/debits", options.merge(body: {
        amount: 100_000_00, # WE"RE RICH!!!!
        source: {
          number: "4111111111111111",
          expiration_year: "2018",
          expiration_month: 12
        }
}))

$:.unshift(File.dirname(__FILE__)+'/../../lib')

require 'balanced/tiny_client'
require 'balanced/extracer'

$client = Balanced::TinyClient.new($api_secret, $accept_header, $root_url)

at_exit do
  $extracer.save
end
