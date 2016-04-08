root = File.expand_path('../', File.dirname(__FILE__))
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'acts_as_bytefield'
require 'pry'

# Load support
Dir[File.join(root, 'spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.profile_examples = 3
  config.order = :random
  Kernel.srand config.seed

  config.before(:all) do
    setup_db
  end
end
