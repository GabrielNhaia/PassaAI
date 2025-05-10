#!/usr/bin/env bash
# exit on error
set -o errexit

# Instalar depend�ncias
bundle install

# Configurar o ambiente para evitar problemas de concorr�ncia durante a compila��o de assets
export RAILS_ENV=production
export NODE_OPTIONS=--max_old_space_size=4096
export RAILS_SERVE_STATIC_FILES=true 

# Limpar assets existentes e compilar novamente com configura��o de concorr�ncia personalizada
bundle exec rake assets:clobber
RAILS_MAX_THREADS=2 bundle exec rake assets:precompile
bundle exec rake assets:clean

# Migrar e semear o banco de dados
bundle exec rake db:migrate
bundle exec rake db:seed