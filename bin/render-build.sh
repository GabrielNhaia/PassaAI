#!/usr/bin/env bash
# exit on error
set -o errexit

# Instalar depend�ncias
bundle install

# Configurar o ambiente para evitar problemas de concorr�ncia durante a compila��o de assets
export RAILS_ENV=production
export RAILS_SERVE_STATIC_FILES=true 
export NODE_OPTIONS="--max-old-space-size=1536"

# Criar pastas necess�rias
mkdir -p tmp/pids
mkdir -p public/assets

# Compila��o simplificada de assets
echo "Compilando assets..."
SECRET_KEY_BASE=dummyvalue bundle exec rake assets:precompile --trace

# Migrar e semear o banco de dados
bundle exec rake db:migrate
bundle exec rake db:seed