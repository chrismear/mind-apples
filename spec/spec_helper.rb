require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] = "test"
  require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
  require 'spec'
  require 'spec/rails'
  require 'mocha'

  require File.expand_path(File.join(File.dirname(__FILE__), 'factories'))
  require File.expand_path(File.join(File.dirname(__FILE__), 'shared_helper'))

  require "email_spec/helpers"
  require "email_spec/matchers"

  Spec::Runner.configure do |config|
    # If you're not using ActiveRecord you should remove these
    # lines, delete config/database.yml and disable :active_record
    # in your config/boot.rb
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

    # config.include AuthenticatedTestHelper

    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)
  end
end

Spork.each_run do
end
