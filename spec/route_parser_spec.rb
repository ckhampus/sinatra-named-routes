require File.join(File.dirname(__FILE__), 'spec_helper')

describe Route do
  it 'supports named parameters' do
    route = Route.new('/hello/:person.:format')
    url = route.build :person => 'cristian', :format => 'json'
    url.should eql '/hello/cristian.json'
  end

  it 'throws exception if required named params are missing' do
    expect do
      route = Route.new('/hello/:person.:format')
      url = route.build :person => 'cristian'
    end.to raise_exception ArgumentError
  end

  it 'supports splats' do
    route = Route.new('/hello/*.*')
    url = route.build ['cristian', 'json']
    url.should eql '/hello/cristian.json'
  end

  it 'throws exception if required splats are missing' do
    expect do
    route = Route.new('/hello/*.*')
    url = route.build ['cristian']
    end.to raise_exception ArgumentError
  end

  it 'supports splats mixed wih named parameters' do
    route = Route.new('/hello/:person.*')
    url = route.build :person => 'cristian', :splat => ['json']
    url.should eql '/hello/cristian.json'
  end

  it 'supports regular expressions' do
    route = Route.new(%r{/hello/([\w]+).([\w]+)})
    url = route.build ['cristian', 'html']
    url.should eql '/hello/cristian.html'
  end

  it 'supports optional regular expressions mixed with named params' do
    route = Route.new(%r{/hello/:lang/([\w]+).?([\w]+)?})
    url = route.build :lang => 'en', :captures => ['cristian', 'html']
    url.should eql '/hello/en/cristian.html'

    url = route.build :lang => 'en', :captures => ['cristian']
    url.should eql '/hello/en/cristian'
  end

  it 'supports named capture groups' do
    next if RUBY_VERSION < '1.9'

    route = Route.new(%r{/hello/(?<person>[^/?#]+)})
    url = route.build :person => 'cristian'
    url.should eql '/hello/cristian'
  end

  it 'supports optional named capture groups' do
    next if RUBY_VERSION < '1.9'

    route = Route.new(%r{/page(?<format>.[^/?#]+)?})
    url = route.build
    url.should eql '/page'

    url = route.build :format => '.html'
    url.should eql '/page.html'

    url = route.build :format => '.xml'
    url.should eql '/page.xml'
  end
end