# app.rb
require 'sinatra'
require 'sinatra/json'
require 'json'
require 'monitor'

# ==================== CONFIGURAÇÃO ====================
# Configuração para usar WEBrick
set :server, 'webrick'
set :port, 4567
set :bind, '0.0.0.0'
set :ttl_cache, ENV.fetch('LOCAL_CACHE_DEFAULT_TIMEOUT', '20').to_i

# ==================== CACHE SIMPLES ====================
class SimpleCache
  include MonitorMixin
  
  def initialize(ttl_seconds = settings.ttl_cache)
    super()
    @cache = {}
    @ttl = ttl_seconds
    
  end
  
  def get(key)
    synchronize do
      if @cache.key?(key)
        data, timestamp = @cache[key]
        if Time.now - timestamp < @ttl
          return data
        else
          @cache.delete(key)
          return nil
        end
      end
      nil
    end
  end
  
  def set(key, value)
    synchronize do
      @cache[key] = [value, Time.now]
    end
  end
  
  def clear
    synchronize do
      @cache.clear
    end
  end
  
  def stats
    synchronize do
      {
        size: @cache.size,
        keys: @cache.keys,
        ttl: @ttl,
        expired: @cache.select { |_, (_, timestamp)| Time.now - timestamp >= @ttl }.keys
      }
    end
  end
end

# Inicializa o cache com 10 segundos
$cache = SimpleCache.new(settings.ttl_cache)

# Helper para cachear respostas
def cached_response(&block)
  # Cria uma chave única baseada no path e query string
  cache_key = "#{request.path_info}?#{request.query_string}"
  
  # Tenta buscar do cache
  cached_data = $cache.get(cache_key)
  
  if cached_data
    puts "🔵 [CACHE HIT] #{cache_key} - #{Time.now.strftime('%H:%M:%S')}"
    content_type :json
    return cached_data
  end
  
  puts "🟢 [CACHE MISS] #{cache_key} - #{Time.now.strftime('%H:%M:%S')}"
  result = yield
  $cache.set(cache_key, result)
  content_type :json
  result
end

# ==================== ENDPOINTS ====================

# Endpoint 1: Rota raiz que retorna uma mensagem de boas-vindas (COM CACHE)
get '/estatico' do
  cached_response do
    {
      message: 'Desafio 2026 Entrevista APP Sinatra',
    }.to_json
  end
end

# Endpoint 2: Rota de status que retorna informações da aplicação (COM CACHE)
get '/timer' do
  cached_response do
    {
      application: 'Sinatra App2',
      timestamp: Time.now.to_s,
    }.to_json
  end
end

# ==================== TRATAMENTO DE ERROS ====================

# Rota para tratamento de erro 404
not_found do
  content_type :json
  {
    error: 'Rota não encontrada',
    status: 404,
    timestamp: Time.now.to_s
  }.to_json
end

# ==================== LOG DE REQUISIÇÕES ====================
before do
  puts "📥 [REQUEST] #{request.request_method} #{request.path_info} #{request.query_string} - #{Time.now.strftime('%H:%M:%S')}"
end

after do
  puts "📤 [RESPONSE] #{request.path_info} - Status: #{response.status}"
end