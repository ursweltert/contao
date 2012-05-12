require 'spec_helper'

module TechnoGate
  module Contao
    describe JavascriptUglifier do
      before :each do
        TechnoGate::Contao.env  = @env  = :development
        TechnoGate::Contao.root = @root = "/root"

        silence_warnings do
          Uglifier = mock("Uglifier").as_null_object
        end
      end

      subject {
        JavascriptUglifier.new(
          js_src_paths: ["app/stylsheets"],
          js_path:      'js',
          js_file:      'app.js'
        )
      }

      describe "attributes" do
        [:js_src_paths, :js_path, :js_file, :options].each do |attr|
          it "should have #{attr} as attr_accessor" do
            subject.should respond_to(attr)
            subject.should respond_to("#{attr}=")
          end
        end
      end

      describe "init" do
        it "I can init the class js_src_paths" do
          subject.js_src_paths.class.should == Array
          subject.js_src_paths.first.to_s.should == File.join(@root, "app/stylsheets")
        end

        it "I can init the class js_path" do
          subject.js_path.to_s.should == File.join(@root, "js")
        end

        it "I can init the class js_file" do
          subject.js_file.to_s.should == File.join(@root, "js", "app.js")
        end

        describe "with root path not set" do
          before :each do
            TechnoGate::Contao.class_variable_set(:@@root, nil)
          end

          it "should raise an exception" do
            expect do
              JavascriptUglifier.new(
                js_src_paths: ["app/stylsheets"],
                js_path:      'js',
                js_file:      'app.js'
              )
            end.to raise_error(TechnoGate::Contao::RootNotSet)
          end
        end
      end

      describe "#compile" do
        before :each do
          subject.stub(:prepare_folders)
          subject.stub(:compile_javascripts)
          subject.stub(:create_hashed_assets)
        end

        it {should respond_to :compile}

        it "should return self" do
          subject.compile.should == subject
        end

        it "should have the following call stack" do
          subject.should_receive(:prepare_folders).once.ordered
          subject.should_receive(:compile_javascripts).once.ordered
          subject.should_receive(:create_hashed_assets).once.ordered
          subject.compile
        end
      end

      describe "#prepare_folders", :fakefs do
        before :each do
          subject.js_path     = '/src'
        end

        it {should respond_to :prepare_folders}

        it "should create the js_path" do
          subject.send :prepare_folders
          File.directory?(subject.js_path).should be_true
        end
      end

      describe "#compile_javascripts", :fakefs do
        before :each do
          Uglifier.any_instance.stub(:compile)

          subject.js_src_paths = ["/src"]
          subject.js_path      = "/js"
          subject.js_file      = "app.js"

          FileUtils.mkdir_p subject.js_src_paths.first
          FileUtils.mkdir_p subject.js_path

          @file_path   = File.join(subject.js_src_paths.first, "file.js")
          @app_js_path = subject.js_file

          File.open(@file_path, 'w') do |file|
            file.write("not compiled js")
          end
        end

        it {should respond_to :compile_javascripts}

        it "should compile javascripts into js_path/js_file" do
          subject.send :compile_javascripts
          File.exists?(@app_js_path).should be_true
        end

        it "should add the contents of file.js to app.js un-minified if env is development" do
          subject.send :compile_javascripts
          File.read(@app_js_path).should ==
            "// #{@file_path}\n#{File.read(@file_path)}\n"
        end

        it "should add the contents of file.js to app.js minified if env is production" do
          TechnoGate::Contao.env = :production
          Uglifier.any_instance.should_receive(:compile).once.and_return("compiled js")

          subject.send :compile_javascripts
          File.read(@app_js_path).should == "compiled js"
        end
      end

      describe "#create_hashed_assets", :fakefs do
        before :each do
          FileUtils.mkdir_p subject.js_path
          @app_js_path = subject.js_file

          File.open(@app_js_path, 'w') do |file|
            file.write('compiled js')
          end

          @digest = Digest::MD5.hexdigest('compiled js')
        end

        it {should respond_to :create_hashed_assets}

        it "should create a minified version of the asset" do
          subject.send :create_hashed_assets
          File.exists?(File.join(subject.js_path, "app-#{@digest}.js")).should be_true
        end
      end
    end
  end
end
