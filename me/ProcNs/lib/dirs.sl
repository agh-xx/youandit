variable
  STDNS = sprintf ("%s/me", ROOTDIR),
  USRNS = sprintf ("%s/you", ROOTDIR),
  PERSNS = sprintf ("%s/she", ROOTDIR),
  SOURCEDIR = sprintf ("%s/../sources", ROOTDIR),
  STDLIBDIR = sprintf ("%s/lib", STDNS),
  USRLIBDIR = sprintf ("%s/lib", USRNS),
  COREDIR = sprintf ("%s/commands/scripts", STDNS),
  USRCOMMANDSDIR = sprintf ("%s/commands/scripts", USRNS),
  PERSCOMMANDSDIR = sprintf ("%s/commands/scripts", PERSNS),
  TMPDIR = sprintf ("%s/tmp/%d", ROOTDIR, ROOT_PID),
  BGDIR = sprintf ("%s/_pids/bg", TMPDIR);
