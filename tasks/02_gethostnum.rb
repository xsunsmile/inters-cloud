#!/usr/bin/ruby

require 'rubygems'
require 'sqlite3'

if ARGV.size == 0
	exit 0
end

dbpath = ARGV.shift
hostnum=0

db = SQLite3::Database.new(dbpath)
db.transaction do
	sql="select value from cluster where prop='instances_num';"
	hostnum=db.get_first_value(sql)
	sql="update cluster set value=(select value from cluster where prop='instances_num')+1 where prop='instances_num';"
	db.execute(sql)
end
db.close

puts hostnum
