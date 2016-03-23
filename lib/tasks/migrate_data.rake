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
    result = result.gsub('varchar(500)', 'text')
    result = result.gsub('varchar(300)', 'text')
    result = result.gsub('datetime', 'timestamp')
    result = result.gsub('CHARACTER SET utf8', '')
    result = result.gsub('ENGINE=InnoDB', '')
    result = result.gsub('DEFAULT CHARSET=latin1', '')
    result = result.gsub(/AUTO_INCREMENT=\d+/, '')
    result = result.gsub('AUTO_INCREMENT', '')
    result = result.gsub(/^\s+KEY\s.+,$/, "CHECK (1=1),")
    result = result.gsub(/^\s+KEY\s.+$/, "CHECK (1=1)")
    result = result.gsub(/^\s+UNIQUE KEY\s.+,$/, "CHECK (1=1),")
    result = result.gsub(/^\s+UNIQUE KEY\s.+$/, "CHECK (1=1)")
    result = result.gsub(/ALTER TABLE[^;]+;/, '')
    result = result.gsub("'0000-00-00 00:00:00'", 'NULL')
    result = result.gsub('\r\n', ' ')
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

  DB.run "SET statement_timeout TO 60000;"
  
  DB.run "CREATE OR REPLACE FUNCTION convert_latin1(latin1_text text) RETURNS text AS $$
    BEGIN
      RETURN TRIM(convert_from(convert_to(latin1_text, 'latin-1'), 'utf-8'));
    EXCEPTION
      WHEN OTHERS THEN RETURN latin1_text;
    END;
  $$ LANGUAGE plpgsql;"

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
      convert_latin1(email) AS email,
      convert_latin1(last_email) AS secondary_email,
      oauth_uid AS facebook_uid,
      md5(random()::text) AS encrypted_password,
      convert_latin1(nome) AS first_name,
      convert_latin1(sobrenome) AS last_name,
      (CASE WHEN latitude IS NOT NULL AND latitude <> '' THEN cast(latitude as float) ELSE null END) AS latitude,
      (CASE WHEN longitude IS NOT NULL AND longitude <> '' THEN cast(longitude as float) ELSE null END) AS longitude,
      (convert_latin1(endereco) || ', ' || convert_latin1(numero)) AS address_name,
      convert_latin1(endereco) AS address_thoroughfare,
      convert_latin1(numero) AS address_sub_thoroughfare,
      convert_latin1(bairro) AS address_sub_locality,
      convert_latin1(cidade) AS address_locality,
      convert_latin1(uf) AS address_administrative_area,
      convert_latin1(pais) AS address_country,
      convert_latin1(cep) AS address_postal_code,
      convert_latin1(complemento) AS address_complement,
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

  import_demands = true
  print "Looking for 'demands' file..."
  import_demands = false unless File.exists?(@path + "/hm_rn_pedidos.sql")
  puts (import_demands ? "found!" : "not found.")
  if import_demands
    import_file('hm_rn_pedidos')
    puts "  Deleting demands with user not found"
    DB.run "DELETE FROM hm_rn_pedidos WHERE id_usuario NOT IN (SELECT old_id FROM users)"
    puts "  Migrating data from temporary tables"
    DB.run "INSERT INTO demands (
      old_id,
      user_id,
      state,
      name,
      description,
      latitude,
      longitude,
      radius,
      created_at,
      updated_at
    )
    SELECT
      id_pedido AS old_id, 
      (SELECT id from users WHERE old_id = id_usuario) AS user_id,
      (CASE WHEN status = 'cancelado' THEN 'canceled' ELSE (CASE WHEN status = 'pendente' OR status = 'iniciado' OR status = 'emprestado' THEN 'active' ELSE 'completed' END) END) AS state,
      convert_latin1(nome) AS name,
      convert_latin1(descricao) AS description,
      (SELECT latitude from users WHERE old_id = id_usuario) AS latitude,
      (SELECT longitude from users WHERE old_id = id_usuario) AS longitude,
      1 AS radius,
      tempo_registro AS created_at,
      (CASE WHEN tempo_devolucao IS NOT NULL THEN tempo_devolucao ELSE (CASE WHEN tempo_aceito IS NOT NULL THEN tempo_aceito ELSE tempo_registro END) END) AS updated_at
    FROM
      hm_rn_pedidos
    "
  end

  import_messages = true
  print "Looking for 'transactions' and 'messages' file..."
  import_messages = false unless File.exists?(@path + "/hm_rn_pedidos_mensagens.sql")
  puts (import_messages ? "found!" : "not found.")
  if import_messages
    import_file('hm_rn_pedidos_mensagens')
    puts "  Deleting messages with user not found"
    DB.run "DELETE FROM hm_rn_pedidos_mensagens WHERE id_usuario NOT IN (SELECT old_id FROM users)"
    puts "  Deleting messages with demand not found"
    DB.run "DELETE FROM hm_rn_pedidos_mensagens WHERE id_pedido NOT IN (SELECT old_id FROM demands)"
    puts "  Migrating transactions data from temporary tables"
    DB.run "INSERT INTO transactions (
      old_id,
      demand_id,
      user_id
    )
    SELECT
      hm_rn_pedidos_mensagens.id_pedido_convite AS old_id, 
      (SELECT id FROM demands WHERE old_id = hm_rn_pedidos_mensagens.id_pedido) AS demand_id, 
      (SELECT id from users WHERE old_id = hm_rn_pedidos_mensagens.id_usuario) AS user_id
    FROM
      hm_rn_pedidos_mensagens, hm_rn_pedidos
    WHERE
      hm_rn_pedidos_mensagens.id_pedido = hm_rn_pedidos.id_pedido AND
      hm_rn_pedidos_mensagens.id_usuario <> hm_rn_pedidos.id_usuario
    GROUP BY
      old_id, demand_id, user_id
    "
    puts "  Deleting messages with transaction not found"
    DB.run "DELETE FROM hm_rn_pedidos_mensagens WHERE id_pedido_convite NOT IN (SELECT old_id FROM transactions)"
    puts "  Migrating messages data from temporary tables"
    DB.run "INSERT INTO messages (
      old_id,
      transaction_id,
      user_id,
      text,
      created_at,
      updated_at
    )
    SELECT
      hm_rn_pedidos_mensagens.id_mensagem AS old_id, 
      (SELECT id FROM transactions WHERE old_id = id_pedido_convite) AS transaction_id,
      (SELECT id from users WHERE old_id = id_usuario) AS user_id,
      convert_latin1(hm_rn_pedidos_mensagens.mensagem) AS text,
      hm_rn_pedidos_mensagens.tempo_registro AS created_at,
      hm_rn_pedidos_mensagens.tempo_registro AS updated_at
    FROM
      hm_rn_pedidos_mensagens
    "
    puts "  Updating transactions last message text"
    DB.run "UPDATE transactions SET last_message_text = (SELECT text FROM messages WHERE transaction_id = transactions.id ORDER BY created_at DESC LIMIT 1)"
  end

end
