# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the
# db with db:setup).
#
# Seeding can occur multiple times during the execution of a single Rake task
# because it applies to all your app environments (eg: test and development).
# An instance of the current database connection is available as `DB`.

DB.run "DELETE FROM versions"
DB.run "INSERT INTO versions (number, platform, expiry) VALUES ('0.0.1', 'ios', '#{DateTime.now + 365}')"
DB.run "INSERT INTO versions (number, platform, expiry) VALUES ('0.0.1', 'android', '#{DateTime.now + 365}')"
