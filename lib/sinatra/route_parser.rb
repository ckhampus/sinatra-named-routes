class Route
  def initialize(route)
    @input = StringScanner.new(route)
    @output = []

    parse
  end

  def parse
    while token = parse_slash || parse_path || parse_named_param || parse_dot || parse_splat
      @output << token
      is_optional
    end

    @output
  end

  def build(params)
    path = []

    @output.each_index do |index|
      item = @output[index]
      next_item = @output.fetch(index + 1, nil)

      is_last = @output.size == index + 1

      case item[:token]
      when :slash
        @trailing_slash = item[:optional]
        path << '/'
      when :dot
        @trailing_dot = item[:optional]
        path << '.'
      when :path
        path << item[:value]
      when :named_param
        item_key = item[:value]

        if params.has_key? item_key
          path << params.delete(item_key)
        else
          unless item[:optional] then raise ArgumentError.new end
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

  def is_optional
    @output.last[:optional] = @input.scan(/\?/) ? true : false
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
    if @input.scan(/\w+/)
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

  def parse_capture_group
    if @input.scan(/\([^\)]*\)/)
      {
        :token => :named_param,
        :value => @input.matched
      }
    else
      nil
    end
  end
end