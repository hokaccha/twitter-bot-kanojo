require 'rubygems'
require 'sinatra'
require 'yaml'
require 'json'
require 'appengine-apis/urlfetch'
require 'appengine-apis/memcache'

before do
  @conf    = YAML.load_file('config.yaml')
  @twitter = Twitter::new(@conf['user']['username'], @conf['user']['password'])
end

get '/cron/return' do
  memcache = AppEngine::Memcache.new
  tweets = @twitter.user_timeline(@conf['kareshi']);
  tweets.each do |tweet|
    if tweet['text'] =~ /@#{@conf['user']['username']}/ and memcache.get('last_id') != tweet['id']
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

class Twitter
  def initialize(username, password)
    @username = username
    @password = password
  end

  def update(body)
    url = 'http://twitter.com/statuses/update.json'
    request(url, 'POST', { :payload => "status=#{body}" })
  end

  def user_timeline(screen_name)
    url = "http://twitter.com/statuses/user_timeline/#{screen_name}.json"
    res = request(url)
    JSON.parser.new(res.body).parse
  end

  private

  def request(url, method = 'GET', options = {})
    req = Net::HTTP::Get.new('/')
    req.basic_auth @username, @password
    options[:method]  = method
    options[:headers] = { 'Authorization' => req['Authorization'] }
    AppEngine::URLFetch.fetch(url, options)
  end
end
