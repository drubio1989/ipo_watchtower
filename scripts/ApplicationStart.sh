#!/bin/bash
cd /home/ubuntu
RAILS_ENV=production bundle install --path vendor/bundle
RAILS_ENV=production bundle exec rake db:migrate
