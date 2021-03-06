require 'contao/generators/base'
require 'contao/application'
require 'contao/notifier'
require 'fileutils'

module TechnoGate
  module Contao
    module Generators
      class Config < Base
        class AlreadyExists < RuntimeError; end

        def generate
          raise AlreadyExists if File.exists?(global_config_path)

          FileUtils.mkdir_p File.dirname(global_config_path)
          File.open global_config_path, 'w' do |config|
            config.write YAML.dump(default_global_config)
          end

          message = <<-EOS.gsub(/ [ ]+/, '').gsub("\n", ' ').chop
          The configuration file has been created at ~/.contao/config.yml,
          you need to edit this file before working with contao
          EOS
          Notifier.notify message, title: 'Config Generator'
        end

        def global_config_path
          Contao::Application.global_config_path
        end

        def default_global_config(options = {})
          Contao::Application.send(:default_global_config, options)
        end
      end
    end
  end
end
