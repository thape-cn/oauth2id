# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
every :day, at: '12:20am', roles: [:db] do
  rake "doorkeeper:db:cleanup"
end

every :day, at: '12:22am', roles: [:db] do
  rake "sync_nc_uap:all"
end

every :day, at: '12:32am', roles: [:db] do
  rake "sync_yxt:all"
end

# Learn more: http://github.com/javan/whenever
