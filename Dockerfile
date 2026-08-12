# Dockerfile
# Usando a imagem oficial do Ruby
FROM ruby:3.2.2-slim

# Instala dependências do sistema necessárias
RUN apt-get update -qq && \
    apt-get install -y build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Define o diretório de trabalho
WORKDIR /app

# Copia os arquivos de dependências primeiro (para aproveitar o cache do Docker)
COPY Gemfile ./

# Instala as gems
RUN bundle install --jobs 4 --retry 3

# Copia o código da aplicação
COPY src/ .

# Expõe a porta que a aplicação vai usar
EXPOSE 4567

# Comando para iniciar a aplicação
CMD ["ruby", "app.rb"]