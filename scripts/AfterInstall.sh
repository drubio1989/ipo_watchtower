#!/bin/bash
cd /home/ubuntu/ipo_watchtower
source /etc/profile.d/rvm.sh
rvm use 2.7.2
bundle install --path vendor/bundle
# Hack fix to remove system bundle
rm /home/ubuntu/bin/bundle
RAILS_ENV=production bundle exec rails db:migrate
