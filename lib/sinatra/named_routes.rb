require 'version'

module Sinatra
  module NamedRoutes
    @@routes = {}

    #def uri(addr = nil, absolute = true, add_script_name = true, params = {})
    def uri(*args)
      path = args.shift if args.first.is_a? Symbol
      params = args.pop if args.last.is_a? Array or args.last.is_a? Hash

      if path
        addr = get_path(path, params)

        super(addr, *args)
      else
        super(*args)
      end

    end

    alias :to :uri
    alias :url :uri

    def map(name, path)
      route = {}
      route[:path] = path

      if path.is_a? String
        named = path.scan(/(?<=:)[^\.\/]*/).map { |item| item.to_sym }
        splat = path.scan(/\*/)

        params = { :named => named, :splat => splat }
      elsif path.is_a? Regexp
        regexp = path.source.scan(/\([^\)]*\)/)

        params = { :regexp => regexp }
      end

      route[:params] = params

      @@routes[name] = route
    end

    private

    def get_path(name, params = {})
      route = @@routes[name]

      path = route[:path]

      if params.is_a? Hash
        
        # Turn string keys into symbols
        params = params.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

        if path.is_a? String
          route[:params][:named].each do |key|
            if params.has_key? key
              path = path.sub(key.inspect, params[key])
            else
              raise ArgumentError.new
            end
          end
        end
      elsif params.is_a? Array
        if path.is_a? String
          if route[:params][:splat].length != params.length
            raise ArgumentError.new
          end

          params.each do |value|
            path = path.sub('*', value)
          end
        elsif path.is_a? Regexp
          if route[:params][:regexp].length != params.length
            raise ArgumentError.new
          end

          path = path.source

          params.each_index do |index|
            path = path.sub(route[:params][:regexp][index], params[index])
          end
        end
      end

      path
    end

    def route(verb, path, options={}, &block)
      if path.is_a?(Symbol)
        path = @@routes[path][:path]
      end

      super(verb, path, options, &block)
    end

    def self.registered(app)
      app.helpers NamedRoutes
    end
  end
end