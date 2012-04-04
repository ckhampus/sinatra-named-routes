require File.join(File.dirname(__FILE__), 'version')
require File.join(File.dirname(__FILE__), 'route_parser')

module Sinatra
  module NamedRoutes
    module Helpers

      # def uri(addr = nil, absolute = true, add_script_name = true, params = {})
      def uri(*args)
        path = args.shift if args.first.is_a? Symbol
        params = args.pop if args.last.is_a? Array or args.last.is_a? Hash

        if path
          addr = NamedRoutes.get_path(path, params)

          super(addr, *args)
        else
          super(*args)
        end

      end
      alias :to :uri
      alias :url :uri
    end

    def map(name, path)
      NamedRoutes.routes[name] = Route.new path
    end

    private

    def route(verb, path, options={}, &block)
      if path.is_a?(Symbol)
        path = NamedRoutes.routes[path].source
      end

      super(verb, path, options, &block)
    end

    def self.get_path(name, params = {})
      raise ArgumentError, "No route with the name #{name} exists." if NamedRoutes.routes.nil?
      NamedRoutes.routes[name].build params
    end

    def self.routes
      @@routes ||= {}
    end

    def self.registered(app)
      app.helpers NamedRoutes::Helpers
    end
  end
end