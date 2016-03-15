require 'fileutils'
require_relative '../application'

desc "Migrate data from .sql files exported from old MySQL database"
task :migrate_data do

  def process_sql(sql)
    result = sql
    result = result.gsub('SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";', '')
    result = result.gsub('SET time_zone = "+00:00";', '')
    result = result.gsub(/tinyint\(\d+\)/, 'integer')
    result = result.gsub(/int\(\d+\)/, 'integer')
    result = result.gsub('longtext', 'text')
    result = result.gsub('datetime', 'timestamp')
    result = result.gsub('CHARACTER SET utf8', '')
    result = result.gsub('ENGINE=InnoDB', '')
    result = result.gsub('DEFAULT CHARSET=latin1', '')
    result = result.gsub(/AUTO_INCREMENT=\d+/, '')
    result = result.gsub('AUTO_INCREMENT', '')
    result = result.gsub(/^\s+KEY\s.+,$/, "CHECK (1=1),")
    result = result.gsub(/^\s+KEY\s.+$/, "CHECK (1=1)")
    result = result.gsub(/ALTER TABLE[^;]+;/, '')
    result = result.gsub('`', '')
    return result
  end

  def import_file(name, write_new_file = false)
    file_path = "#{@path}/#{name}.sql"
    puts "  #{name}"
    if write_new_file
      puts "    Backing up"
      FileUtils.cp(file_path, "#{@path}/#{name}.#{DateTime.now.strftime('%Y%m%d%H%M%S')}.sql")
    end
    puts "    Opening file"
    sql = File.open(file_path, "rb").read
    puts "    Processing SQL"
    sql = process_sql(sql)
    if write_new_file
      puts "    Writing SQL file"
      File.write(file_path, sql)
    end
    puts "    Droping old temporary table"
    DB.run "DROP TABLE IF EXISTS #{name}"
    puts "    Importing temporary table"
    DB.run sql
  end

  @path = File.expand_path("../../../db/migrate_data/", __FILE__)

  import_users = true
  print "Looking for 'users' files..."
  import_users = false unless File.exists?(@path + "/hm_rn_usuarios.sql")
  import_users = false unless File.exists?(@path + "/hm_rn_usuarios_contas.sql")
  puts (import_users ? "found!" : "not found.")
  if import_users
    import_file('hm_rn_usuarios')
    import_file('hm_rn_usuarios_contas')
  end

end
