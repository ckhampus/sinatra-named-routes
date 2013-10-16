
module Sinatra
  module NamedRoutes
    class Route
      attr_reader :source

      def initialize(route)
        route = route.source if route.is_a? Regexp

        @source = route
        @input = StringScanner.new(route)
        @output = []

        parse
      end

      def build(params = {})
        path = []
        params = {} if params.nil?

        @output.each_index do |index|
          item = @output[index]
          next_item = @output.fetch(index + 1, nil)

          case item[:token]
          when :slash
            @trailing_slash = item[:optional]
            path << '/'
          when :dot
            @trailing_dot = item[:optional]
            path << '.'
          when :splat
            if params.is_a? Hash
              raise ArgumentError, 'No parameters passed.' if params[:splat].empty?
              path << params[:splat].shift
            else
              raise ArgumentError, 'No enough parameters passed.' if params.empty?
              path << params.shift
            end
          when :path
            path << item[:value]
          when :named_param
            item_key = item[:value]

            if params.has_key? item_key
              path << params.delete(item_key)
            else
              raise ArgumentError, "No value passed for '#{item_key.to_s}'" unless item[:optional]
            end
          when :regexp
            name = /#{item[:value]}/.names

            if name.any?
              name = name.first.to_sym

              if params.has_key? name
                path << params.delete(name)
              else
                raise ArgumentError, "No value passed for '#{name.to_s}'" unless item[:optional]
              end
            else
              if params.is_a? Hash
                raise ArgumentError, 'No enough parameters passed.' if params[:captures].empty? and !item[:optional]
                path << params[:captures].shift
              else
                raise ArgumentError, 'No enough parameters passed.' if params.empty?
                path << params.shift
              end
            end
          end
        end

        path = path.join

        if @trailing_dot
          path = path.chomp '.'
        end

        if @trailing_slash
          path = path.chomp '/'
        end

        path
      end

      private

      def is_optional?
        @output.last[:optional] = @input.scan(/\?/) ? true : false
      end

      def parse
        while token = parse_slash || parse_path || parse_named_param || 
                      parse_dot || parse_splat || parse_regexp
          @output << token
          is_optional?
        end
      end

      def parse_slash
        if @input.scan(/\//)
          {
            :token => :slash
          }
        else
          nil
        end
      end

      def parse_dot
        if @input.scan(/\./)
          {
            :token => :dot
          }
        else
          nil
        end
      end

      def parse_splat
        if @input.scan(/\*/)
          {
            :token => :splat
          }
        else
          nil
        end
      end

      def parse_path
        if @input.scan(/[\w\-]+/)
          {
            :token => :path,
            :value => @input.matched
          }
        else
          nil
        end
      end

      def parse_named_param
        if @input.scan(/:[^\W]*/)
          {
            :token => :named_param,
            :value => @input.matched.sub(':', '').to_sym
          }
        else
          nil
        end
      end

      def parse_regexp
        if @input.scan(/\([^\)]*\)/)
          {
            :token => :regexp,
            :value => @input.matched
          }
        else
          nil
        end
      end
    end
  end
end