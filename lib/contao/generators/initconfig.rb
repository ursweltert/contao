require 'contao/generators/base'

module TechnoGate
  module Contao
    module Generators
      class Initconfig < Base
        class InitconfigRequired < RuntimeError; end

        def generate
          require_initconfig

          config = Contao::Application.config
          File.open initconfig_path, 'w' do |f|
            f.write ERB.new(File.read(options[:template]), nil, '-').result(binding)
          end
        end

        protected
        def require_initconfig
          raise InitconfigRequired unless options[:template]
        end

        def initconfig_path
          Pathname.new(Rails.public_path).join 'system/config/initconfig.php'
        end
      end
    end
  end
end
