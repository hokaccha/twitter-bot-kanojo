require 'appengine-rack'

AppEngine::Rack.configure_app(
  :application => 'twitter-bot-kanojo',
  :version => 1
)

require 'main'

run Sinatra::Application
