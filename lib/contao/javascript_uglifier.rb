require 'fileutils'
require 'uglifier'

module TechnoGate
  module Contao
    class JavascriptUglifier
      attr_accessor :js_src_paths, :js_path, :js_file, :options

      def initialize(options = {})
        @js_src_paths = options.delete(:js_src_paths).map do |path|
          TechnoGate::Contao.expandify(path)
        end

        @js_path      = TechnoGate::Contao.expandify options.delete(:js_path)
        @js_file      = File.join @js_path, options.delete(:js_file)
        @options      = options
      end

      # Compile javascript into one asset
      def compile
        prepare_folders
        compile_javascripts
        create_hashed_assets

        self
      end

      protected
      # Prepare folders
      def prepare_folders
        FileUtils.mkdir_p js_path
      end

      # Compile javascripts
      #
      # This method compiles javascripts from js_src_paths into
      # js_path/js_file and it uglifies only if the environment is equal
      # to :production
      def compile_javascripts
        tmp_app_js = "/tmp/#{File.basename js_file}-#{Time.now.usec}"

        FileUtils.mkdir_p '/tmp'
        File.open(tmp_app_js, 'w') do |compressed|
          js_src_paths.each do |src_path|
            Dir["#{src_path}/**/*.js"].sort.each do |f|
              if TechnoGate::Contao.env == :production
                compressed.write(Uglifier.new.compile(File.read(f)))
              else
                compressed.write("// #{f}\n")
                compressed.write(File.read(f))
                compressed.write("\n")
              end
            end
          end
        end

        FileUtils.mv tmp_app_js, js_file
      end

      # This function creates a hashed version of the assets
      def create_hashed_assets
        digest = Digest::MD5.hexdigest(File.read(js_file))
        hashed_app_js_path = "#{js_file.chomp(File.extname(js_file))}-#{digest}#{File.extname(js_file)}"
        FileUtils.ln_s js_file, hashed_app_js_path unless File.exists?(hashed_app_js_path)
      end
    end
  end
end
