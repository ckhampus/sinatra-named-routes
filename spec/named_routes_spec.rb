require File.join(File.dirname(__FILE__), 'spec_helper')

describe Sinatra::NamedRoutes do
  def helper_route(&block)
    time = Time.now.usec

    mock_app do
      register Sinatra::NamedRoutes

      map(:path_named_params, '/hello/:name.:format')
      map(:path_splats, '/hello/*.*')
      map(:path_regexp, %r{/hello/([\w]+).([\w]+)})
      map(:path_named_captures, %r{/hello/(?<person>[^/?#]+)})
      map(:path_optional_named_captures, %r{/page(?<format>.[^/?#]+)?})

      get "/#{time}" do
        instance_eval(&block)
      end
    end

    get "/#{time}"
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

    it 'does not break normal helper behavior' do
      mock_app do
        register Sinatra::NamedRoutes

        get '/' do
          url '/route', false
        end
      end

      get('/').should be_ok
      body.should be == '/route'
    end

    it 'ignores params if path is not a symbol' do
      mock_app do
        register Sinatra::NamedRoutes

        get '/' do
          url '/route', false, :name => 'cristian'
        end
      end

      get('/').should be_ok
      body.should be == '/route'
    end

    it 'returns the correct urls' do
      mock_app do
        register Sinatra::NamedRoutes

        map :path, '/hello/?:person?'

        get '/test1' do
          url :path, false, :person => 'cristian'
        end

        get '/test2' do
          url :path, false
        end
      end

      get('/test1').should be_ok
      body.should be == '/hello/cristian'

      get('/test2').should be_ok
      body.should be == '/hello'
    end

  end

end