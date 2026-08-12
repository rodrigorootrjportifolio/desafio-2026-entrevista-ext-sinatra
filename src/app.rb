require 'sinatra'
require 'json'
require 'active_support/cache'

CACHE = ActiveSupport::Cache::MemoryStore.new
CACHE_DEFAULT_TIMEOUT' = ENV.fetch('LOCAL_CACHE_DEFAULT_TIMEOUT', '600')

get '/timer' do
  content_type :json

  datetime = CACHE.fetch('datetime', expires_in: CACHE_DEFAULT_TIMEOUT') do
    Time.now.iso8601
  end

  {
    datetime: datetime,
    version: ENV.fetch('APP_VERSION', 'unknown')
  }.to_json
end

get '/static' do
  content_type :json

  CACHE.fetch('static_response', expires_in: CACHE_DEFAULT_TIMEOUT') do
    {
      message: 'Hello from Sinatra',
      version: ENV.fetch('APP_VERSION', 'unknown')
    }.to_json
  end
end