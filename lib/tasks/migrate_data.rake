desc "Migrate data from .sql files exported from old MySQL database"
task :migrate_data do

  require 'fileutils'
  require_relative '../application'

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
    puts "  Deleting users with duplicate email"
    DB.run "DELETE FROM hm_rn_usuarios WHERE email IN (SELECT email FROM hm_rn_usuarios GROUP BY email HAVING COUNT(*) > 1) AND (CASE WHEN last_logon IS NOT NULL THEN last_logon ELSE '1900-01-01'::timestamp END) NOT IN (SELECT MAX(last_logon) FROM hm_rn_usuarios WHERE email IN (SELECT email FROM hm_rn_usuarios GROUP BY email HAVING COUNT(*) > 1) GROUP BY email);"
    puts "  Deleting users with duplicate facebook uid"
    DB.run "DELETE FROM hm_rn_usuarios WHERE oauth_uid IN (SELECT oauth_uid FROM hm_rn_usuarios WHERE oauth_uid IS NOT NULL GROUP BY oauth_uid HAVING COUNT(*) > 1) AND (CASE WHEN last_logon IS NOT NULL THEN last_logon ELSE '1900-01-01'::timestamp END) NOT IN (SELECT MAX(last_logon) FROM hm_rn_usuarios WHERE oauth_uid IN (SELECT oauth_uid FROM hm_rn_usuarios WHERE oauth_uid IS NOT NULL GROUP BY oauth_uid HAVING COUNT(*) > 1) GROUP BY oauth_uid);"
    puts "  Migrating data from temporary tables"
    DB.run "INSERT INTO users (
      old_id,
      email,
      secondary_email,
      facebook_uid,
      encrypted_password,
      first_name,
      last_name,
      latitude,
      longitude,
      address_name,
      address_thoroughfare,
      address_sub_thoroughfare,
      address_sub_locality,
      address_locality,
      address_administrative_area,
      address_country,
      address_postal_code,
      address_complement,
      uploaded_image_url,
      created_at,
      updated_at
    )
    SELECT
      hm_rn_usuarios.id_usuario AS old_id,
      email,
      last_email AS secondary_email,
      oauth_uid AS facebook_uid,
      md5(random()::text) AS encrypted_password,
      nome AS first_name,
      sobrenome AS last_name,
      (CASE WHEN latitude IS NOT NULL AND latitude <> '' THEN cast(latitude as float) ELSE null END) AS latitude,
      (CASE WHEN longitude IS NOT NULL AND longitude <> '' THEN cast(longitude as float) ELSE null END) AS longitude,
      (endereco || ', ' || numero) AS address_name,
      endereco AS address_thoroughfare,
      numero AS address_sub_thoroughfare,
      bairro AS address_sub_locality,
      cidade AS address_locality,
      uf AS address_administrative_area,
      pais AS address_country,
      cep AS address_postal_code,
      complemento AS address_complement,
      (CASE WHEN user_pic IS NOT NULL AND user_pic <> '' THEN ('http://www.temacucar.com/_static/uploads/avatar/' || user_pic) ELSE null END) AS uploaded_image_url,
      data_cadastro AS created_at,
      (CASE WHEN last_logon IS NOT NULL THEN last_logon ELSE data_cadastro END) AS updated_at
    FROM
      hm_rn_usuarios_contas, 
      hm_rn_usuarios
    WHERE 
      hm_rn_usuarios_contas.id_usuario = hm_rn_usuarios.id_usuario AND 
      email IS NOT NULL AND email <> '';"
  end

end
