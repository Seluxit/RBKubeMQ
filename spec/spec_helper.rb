require "rspec"
require "pry-byebug"
require "rbkubemq"
require "eventmachine"
require "yaml"
# require_relative File.expand_path('../../lib/rbkubemq', __FILE__)

RSpec.configure do |config|
	config.color = true
	yaml_file = YAML.load_file("#{__dir__}/config.yml")
	$host = yaml_file["host"]
end
