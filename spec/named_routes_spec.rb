require_relative 'spec_helper'

describe Sinatra::NamedRoutes do
  def helper_route(&block)
    result = nil
    @helper_app.get('/helper_route') do
      result = instance_eval(&block)
      'ok'
    end
    get '/helper_route'
    last_response.should be_ok
    body.should be == 'ok'
    result
  end

  before do
    app = nil

    mock_app do
      register Sinatra::NamedRoutes

      map(:hello, '/hello')

      map(:path_named, '/hello/:name')
      map(:path_multi_named, '/hello/:name.:format')
      map(:path_splat, '/hello/*')
      map(:path_multi_splat, '/hello/*.*')
      map(:path_regexp, %r{/hello/([\w]+)})
      map(:path_multi_regexp, %r{/hello/([\w]+).([\w]+)})

      get('/') { 'hello' }
      get(:hello) { 'hello world' }
      get('/hello/:name') { |name| "hello #{name}" }

      app = self
    end

    @helper_app = app
  end

  describe :helper_route do
    it 'runs the block' do
      ran = false
      helper_route { ran = true }
      ran.should be_true
    end

    it 'returns the block result' do
      helper_route { 42 }.should be == 42
    end

  end

  describe :routing do
    it 'does still allow normal routing' do
      get('/').should be_ok
      body.should be == 'hello'

      get('/hello/cristian').should be_ok
      body.should be == 'hello cristian'
    end

    it 'does still allow routing with symbols as paths' do 
      get('/hello').should be_ok
      body.should be == 'hello world'
    end

  end

  describe :path_helper do

    it 'does not break normal behavior' do
      helper_route do
        url '/route_one', false
      end.should be == '/route_one'
    end

    it 'ignores params if path is not a symbol' do
      helper_route do
        url '/route_one', false, name: 'cristian'
      end.should be == '/route_one'
    end

    describe :named do
      it 'returns the correct path if passed a hash with symbols as keys' do 
        helper_route do
          url :path_multi_named, false, name: 'cristian', format: 'json'  
        end.should be == '/hello/cristian.json'
      end

      it 'returns the correct path if passed a hash with strings as keys' do
        helper_route do
          url :path_multi_named, false, 'name' => 'cristian', 'format' => 'json'  
        end.should be == '/hello/cristian.json'
      end

      it 'ignores keys that are left' do
        helper_route do
          url :path_multi_named, false, name: 'cristian', format: 'json', color: 'blue'  
        end.should be == '/hello/cristian.json'
      end

      it 'throws an exception if required keys do not exist' do
        expect do
          helper_route do
            url :path_multi_named, false, name: 'cristian', color: 'blue'
          end
        end.to raise_exception ArgumentError
      end

    end

    describe :splat do
      it 'returns the correct url for path with splats' do
        helper_route do
          url :path_multi_splat, false, ['cristian', 'json'] 
        end.should be == '/hello/cristian.json'
      end

      it 'throws exception if params does not match number of splats' do
        expect do
          helper_route do
            url :path_multi_splat, false, ['cristian']
          end
        end.to raise_exception ArgumentError
      end

    end

    describe :regular_expression do
      it 'returns the correct url for path with regular expressions' do
        helper_route do
          url :path_multi_regexp, false, ['cristian', 'json'] 
        end.should be == '/hello/cristian.json'
      end

      it 'throws exception if params does not match number of captures' do
        expect do
          helper_route do
            url :path_multi_regexp, false, ['cristian']
          end
        end.to raise_exception ArgumentError
      end

    end

  end

end