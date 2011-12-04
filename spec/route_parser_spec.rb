require File.join(File.dirname(__FILE__), 'spec_helper')

describe Route do
  it 'parses route into hash' do
    route = Route.new('/hello/:name.?:format?')
    route.parse.should eql [
      {
        :token    => :slash,
        :optional => false
      },
      {
        :token    => :path,
        :value    => 'hello',
        :optional => false
      },
      {
        :token    => :slash,
        :optional => false
      },
      {
        :token    => :named_param,
        :value    => 'name',
        :optional => false
      },
      {
        :token    => :dot,
        :optional => true
      },
      {
        :token    => :named_param,
        :value    => 'format',
        :optional => true
      }
    ]
  end

  it 'builds url from provided params' do
    route = Route.new('/hello/:name.?:format?')
    url = route.build :name => 'Cristian'
    url.should eql '/hello/Cristian'

    url = route.build :name => 'Cristian', :format => 'json'
    url.should eql '/hello/Cristian.json'
  end
end