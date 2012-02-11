# Sinatra Named Routes [![Build Status](https://secure.travis-ci.org/ckhampus/sinatra-named-routes.png)](http://travis-ci.org/ckhampus/sinatra-named-routes)

This gem allows the use of named routes in Sinatra applications.

## Usage

To use this gem you must register it in your Sinatra application.

```ruby
require 'sinatra/base'
require 'sinatra/named_routes'

class MyApp < Sinatra::Base
  register Sinatra::NamedRoutes
end
```

The you use the `map` method to map a route to a name, and use that name when defining your routes.

```ruby
require 'sinatra/base'
require 'sinatra/named_routes'

class MyApp < Sinatra::Base
  register Sinatra::NamedRoutes
  
  map :article, '/article/:id'
  
  get :article do
    # get article bla bla ...
  end
end
```

To generate urls in extends Sinatras built-in methods like `url` and `to` but it does not break them. They work like before except that now you can also pass the route name and paramters. The parameters have to be always passed as the last argument. Otherwise the `url` work the same.

```ruby
# in your route or view you can write something like this
url :article, false, :id => 123 # /article/123
```

The `map` method supports the same routes as Sinatra does.

```ruby
# named parameters
map :article, '/article/:id'

url :article, false, :id => 123 # /article/123
  
# splats
map :article, '/article/*.*'

url :article, false, [123, 'json'] # /article/123.json

# regular expressions
map :article, %r{/article/([\w]+).([\w]+)}

url :article, false, [123, 'json'] # /article/123.json
  
# named captures
map :article, %r{/article/(?<slug>[^/?#]+)}

url :article, false, :slug => 'hello_world' # /article/hello_world

# optional named captures
map(:articles, %r{/articles(?<format>.[^/?#]+)?})

url :articles, false, :format => '.html' # /articles.html
```