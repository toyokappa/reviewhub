#!/bin/bash
RAILS_ENV=${RAILS_ENV} bundle exec sidekiq -q default -q mailers
