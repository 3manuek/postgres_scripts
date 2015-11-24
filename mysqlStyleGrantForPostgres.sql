CREATE OR REPLACE FUNCTION addRemoteUser(
  username text,
  iptarget text DEFAULT '0.0.0.0/0',
  dbtarget text DEFAULT 'all',
  passtext text DEFAULT 'CHANGEME',
  methodauth text DEFAULT 'md5')
  RETURNS boolean
AS $$
  import os
  hbaLine = "host " + str(dbtarget) + "\t" + str(username) + "\t" + str(iptarget) + "\t" + str(methodauth)
  createuser = "CREATE USER " + str(username) + " WITH PASSWORD '" + str(passtext) + "'"

  hbaFilePath = plpy.execute("select setting from pg_settings where name = 'hba_file'", 1)
  hs = open(hbaFilePath[0]['setting'],"a")
  hs.write(hbaLine + "\n")
  addUserCommand = plpy.execute(createuser, 1)
  reload = plpy.execute("select pg_reload_conf()", 1)
  hs.close()
  return True
$$ LANGUAGE plpythonu;
