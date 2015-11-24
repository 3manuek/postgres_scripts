--
-- NOT FOR PRODUCTION
-- This function needs a lot of work and is only an example for the 
-- current thread: http://dba.stackexchange.com/questions/121732/restrict-postgres-roles-by-ip-address-outside-of-the-pg-hba-conf-file/122008#122008

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
  grantuser = "GRANT connect ON DATABASE " + str(dbtarget) + " TO " + str(username)
  hbaFilePath = plpy.execute("select setting from pg_settings where name = 'hba_file'", 1)
  hs = open(hbaFilePath[0]['setting'],"a")
  hs.write(hbaLine + "\n")
  addUserCommand = plpy.execute(createuser, 1)
  grantUserCommand = plpy.execute(grantuser, 1)
  reload = plpy.execute("select pg_reload_conf()", 1)
  hs.close()
  return True
$$ LANGUAGE plpythonu;
