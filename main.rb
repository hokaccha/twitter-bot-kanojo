require 'rubygems'
require 'sinatra'
require 'yaml'
require 'appengine-apis/memcache'
require 'twitter'

before do
  @conf    = YAML.load_file('config.yaml')
  @twitter = Twitter.new(@conf['user']['username'], @conf['user']['password'])
end

get '/cron/return' do
  memcache = AppEngine::Memcache.new
  tweets = @twitter.user_timeline(@conf['kareshi']);
  tweets.each do |tweet|
    if tweet['text'] =~ /@#{@conf['user']['username']}/
      break if memcache.get('last_id') == tweet['id']
      messages = YAML.load_file('messages.yaml')['return']
      message = "@#{@conf['kareshi']} #{messages[rand(messages.length)]}"
      @twitter.update(message)
      memcache.set('last_id', tweet['id'])
      break
    end
  end
  return
end

get '/cron/auto' do
  messages = YAML.load_file('messages.yaml')['auto']
  message = "@#{@conf['kareshi']} #{messages[rand(messages.length)]}"
  @twitter.update(message)
  return
end
