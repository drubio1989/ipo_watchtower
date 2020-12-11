#!/bin/sh
cd /home/ubuntu
RAILS_ENV=production bundle install --path vendor/bundle
RAILS_ENV=production bundle exec rails db:migrate
