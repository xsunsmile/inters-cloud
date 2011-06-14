#!/usr/bin/ruby

require 'rubygems'
require 'sqlite3'

if ARGV.size == 0
	exit 0
end

dbpath = ARGV.shift
hostnum=0

begin
	db = SQLite3::Database.new(dbpath)
	db.busy_handler do |data, retries|
		print "in busy_handler data is ",data,"\n"
		print "retries is ",retries,"\n"
		sleep (rand * 100).ceil/100.0
		(retries<=3)
	end
	db.transaction do
		sql="select value from cluster where prop='instances_num';"
		hostnum=db.get_first_value(sql)
		sql="update cluster set value=(select value from cluster where prop='instances_num')+1 where prop='instances_num';"
		db.execute(sql)
	end
rescue => e
ensure
	db.close
end

puts hostnum
