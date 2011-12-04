require File.join(File.dirname(__FILE__), 'spec_helper')

describe Sinatra::NamedRoutes do
  def helper_route(&block)
    mock_app do
      register Sinatra::NamedRoutes

      map(:path_named_params, '/hello/:name.:format')
      map(:path_splats, '/hello/*.*')
      map(:path_regexp, %r{/hello/([\w]+).([\w]+)})
      map(:path_named_captures, %r{/hello/(?<person>[^/?#]+)})
      map(:path_optional_named_captures, %r{/page(?<format>.[^/?#]+)?})

      get '/' do
        instance_eval(&block)
      end
    end

    get('/')
  end

  describe :routing do
    it 'does allow routing with symbols as paths' do
      mock_app do
        register Sinatra::NamedRoutes

        map :test, '/test'

        get :test do
          'symbols work'
        end
      end

      get('/test').should be_ok
      body.should be == 'symbols work'
    end

    it 'does not break normal routing' do
      mock_app do
        register Sinatra::NamedRoutes

        get '/normal' do
          'still works'
        end
      end

      get('/normal').should be_ok
      body.should be == 'still works'
    end

  end

  describe :path_helper do

    it 'does not break normal behavior' do
      helper_route do
        url '/route_one', false
      end

      body.should be == '/route_one'
    end

    it 'ignores params if path is not a symbol' do
      helper_route do
        url '/route_one', false, :name => 'cristian'
      end

      body.should be == '/route_one'
    end

    describe :named do
      it 'supports named parameters' do 
        helper_route do
          url :path_named_params, false, :name => 'cristian', :format => 'json'  
        end

        body.should be == '/hello/cristian.json'

        helper_route do
          url :path_named_params, false, 'name' => 'cristian', 'format' => 'json'  
        end

        body.should be == '/hello/cristian.json'
      end

      it 'ignores keys that are left' do
        helper_route do
          url :path_named_params, false, :name => 'cristian', :format => 'json', :color => 'blue'  
        end

        body.should be == '/hello/cristian.json'
      end

      it 'throws an exception if required keys do not exist' do
        expect do
          helper_route do
            url :path_named_params, false, :name => 'cristian', :color => 'blue'
          end
        end.to raise_exception ArgumentError
      end

    end

    describe :splat do
      it 'returns the correct url for path with splats' do
        helper_route do
          url :path_splats, false, ['cristian', 'json'] 
        end

        body.should be == '/hello/cristian.json'
      end

      it 'throws exception if params does not match number of splats' do
        expect do
          helper_route do
            url :path_splats, false, ['cristian']
          end
        end.to raise_exception ArgumentError
      end

    end

    describe :regular_expression do
      it 'returns the correct url for path with regular expressions' do
        helper_route do
          url :path_regexp, false, ['cristian', 'json'] 
        end

        body.should be == '/hello/cristian.json'
      end

      it 'throws exception if params does not match number of captures' do
        expect do
          helper_route do
            url :path_regexp, false, ['cristian']
          end
        end.to raise_exception ArgumentError
      end
    end

    describe :named_captures do
      it 'returns the correct url for path with named captures' do
        next if RUBY_VERSION < '1.9'

        helper_route do
          url :path_named_captures, false, :person => 'cristian'
        end

        body.should be == '/hello/cristian'
      end

      it 'returns the correct url for path with optional named captures' do
        next if RUBY_VERSION < '1.9'

        helper_route do
          url :path_optional_named_captures, false, :format => '.html'
        end

        body.should be == '/page.html'

        helper_route do
          url :path_optional_named_captures, false, :format => '.xml'
        end

        body.should be == '/page.xml'

        helper_route do
          url :path_optional_named_captures, false
        end

        body.should be == '/page'
      end
    end

  end

end