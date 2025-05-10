#!/usr/bin/env bash
# exit on error
set -o errexit

# Instalar dependências
bundle install

# Configurar o ambiente para evitar problemas de concorrência durante a compilação de assets
export RAILS_ENV=production
export RAILS_SERVE_STATIC_FILES=true 
export NODE_OPTIONS="--max-old-space-size=1536"

# Criar pastas necessárias
mkdir -p tmp/pids
mkdir -p public/assets

# Compilação simplificada de assets
echo "Compilando assets..."
SECRET_KEY_BASE=dummyvalue bundle exec rake assets:precompile --trace

# Migrar e semear o banco de dados
bundle exec rake db:migrate
bundle exec rake db:seed