# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper.rb"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

$: << File.expand_path('../../lib/contao.rb', __FILE__)

require 'active_support/core_ext/kernel/reporting'
require 'contao'
require 'fakefs/spec_helpers'

Dir["#{File.expand_path('../support', __FILE__)}/**/*.rb"].each {|f| require f}

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.run_all_when_everything_filtered = true
  c.filter_run :focus

  c.include FakeFS::SpecHelpers, :fakefs

  c.before :each do
    ::TechnoGate::Contao.env  = @env  = :development
    ::TechnoGate::Contao.root = @root = "/root"
    ::TechnoGate::Contao::Application.configure do
      config.javascripts_path   = ["vendor/assets/javascripts/javascript", "app/assets/javascripts/javascript"]
      config.stylesheets_path   = 'app/assets/stylesheets'
      config.images_path        = 'app/assets/images'
      config.assets_public_path = 'public/resources'
    end

    silence_warnings do
      ::Compass::Commands::UpdateProject = stub.as_null_object
      ::Uglifier = mock("Uglifier").as_null_object
    end
  end
end
