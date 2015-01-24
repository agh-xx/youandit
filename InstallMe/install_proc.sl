() = evalfile ("fswalk");
() = evalfile ("cmdopt");

define sigint_handler (sig)
{
  () = fputs ("Proccess (installation) interrupted by the user\n", stderr);
  exit (1);
}

signal (SIGINT, &sigint_handler);

variable
  ROOTDIR,
  SOURCEDIR,
  ARE_WE_BUILDING_MODULES,
  MODULES = [
    "getkey", "pcre", "fork", "fcntl", "sysconf", "rand", "iconv", "slsmg",
    "socket", "curl"],
  SMODULESDIR = (
    SMODULESDIR = String_Type[length (MODULES)],
    SMODULESDIR[*] = "C/UpStream",
    SMODULESDIR[0] = "C/getkey",
    SMODULESDIR),
  INSTALL_MODULESDIR = String_Type[length (MODULES)],
  CC,
  CCARG = "-shared -fPIC -g -O2 -lm",
  EXTRAARG = (EXTRAARG = String_Type[length (MODULES)], EXTRAARG[*] = "", EXTRAARG),
  EXCLUDEFILESBASENAME = ["TODO", "stackfile.sl", "i_root.sl", ".gitignore"],
  EXCLUDEFILESFULLPATH = [""],
  EXCLUDEDIRS = ["C", "InstallMe", ".git", "about_me"];

EXTRAARG[wherefirst ("pcre" == MODULES)] = "-lpcre";
EXTRAARG[wherefirst ("curl" == MODULES)] = "-lcurl";
SMODULESDIR[wherefirst ("curl" == MODULES)] = "C/curl";

define isdirectory (file)
{
  variable st = stat_file (file);
  return NULL == st ? 0 : stat_is ("dir", st.st_mode);
}

define exception_to_array ()
{
  return strtok (sprintf ("Caught an exception:%s\n\
    Message:     %s\n\
    Object:      %S\n\
    Function:    %s\n\
    Line:        %d\n\
    File:        %s\n\
    Description: %s\n\
    Error:       %d\n",
    _push_struct_field_values (__get_exception_info ())), "\n");
}

define copyfile (source, dest)
{
  % NO CHECKING (IT SHOULD WORK)
  variable
    buf,
    source_fp = fopen (source, "rb"),
    dest_fp = fopen (dest, "wb");

  while (-1 != fread (&buf, String_Type, 1024, source_fp))
    if (-1 == fwrite(buf, dest_fp))
      {
      () = fprintf (stderr, "SHEET! (S[T]ORRY)\nERRNO: %s\n", errno_string (errno));
      exit (1);
      }
}

define compilemodules (module, sourcedir, installdir, extraarg)
{
  () = fprintf (stdout, "Trying to compile %s module ... ", module);

  if (-1 == chdir (sprintf ("%s/%s",  SOURCEDIR, sourcedir)))
    {
    () = fprintf (stderr,
      "failed\n%s: cannot change to sources directory ERRNO: %s\n",
      sourcedir, errno_string (errno));
    exit (1);
    }

  () = system (sprintf ("%s %s %s %s-module.c -o %s-module.so",
     CC, CCARG, extraarg, module, module));

  if (-1 == access (installdir, F_OK))
    if (-1 == mkdir (installdir))
      {
      () = fprintf (stderr, "failed\n%s: failed to create directory\n ERRNO: %s\n",
        installdir, errno_string (errno));
      exit (1);
      }
 
  if (-1 == rename (sprintf ("%s/%s/%s-module.so", SOURCEDIR, sourcedir, module),
      sprintf ("%s/%s-module.so", installdir, module)))
    {
    () = fprintf (stderr, "failed\n%s/%s/%s-module.so: failed to move\n",
     ROOTDIR, sourcedir, module);
    exit (1);
    }

   () = fprintf (stdout, "done\n");
}

define file_callback (file, st)
{
  if (any (path_basename (file) == EXCLUDEFILESBASENAME))
    return 1;

  if (any (file == EXCLUDEFILESFULLPATH))
    return 1;

  variable
    ref,
    newfile = sprintf ("%s/%s", ROOTDIR, file),
    ext = path_extname (file);
 
  if (0 == strlen (ext) || ".sl" != ext)
    {
    copyfile (file, newfile);
    return 1;
    }

  try
    byte_compile_file (sprintf ("%s/%s", SOURCEDIR, file), 0);
  catch AnyError:
    {
    () = array_map (Integer_Type, &fprintf, stderr, "%s\n",
      [sprintf ("Compiling slang sources ... failed\nFailed to compile %s", file), exception_to_array]);
    exit (1);
    }
 
  if (-1 == rename (sprintf ("%s/%sc", SOURCEDIR, file), sprintf ("%sc", newfile)))
    {
    () = fprintf (stderr, "Compiling slang sources ... failed\n%sc: failed to move\n", file);
    exit (1);
    }

  return 1;
}

define dir_callback (dir, st)
{
  if (any (dir == EXCLUDEDIRS))
    return 0;

  variable newdir = sprintf ("%s/%s", ROOTDIR, dir);

  ifnot (access (newdir, F_OK))
    return 1;
 
  if (-1 == mkdir (newdir))
    {
    () = fprintf (stderr, "%s: mkdir failed\nErrno: %s", newdir, errno_string (errno));
    exit (1);
    }

  return 1;
}

define main ()
{
  variable
    i,
    fs,
    stdmoduledir,
    usrmoduledir,
    c = cmdopt_new ();

  c.add ("cc", &CC;type = "string");
  c.add ("rootdir", &ROOTDIR;type = "string");
  c.add ("sourcedir", &SOURCEDIR;type = "string");
  c.add ("stdmoduledir", &stdmoduledir;type= "string");
  c.add ("usrmoduledir", &usrmoduledir;type= "string");
  c.add ("are_we_building_modules", &ARE_WE_BUILDING_MODULES;type = "int");

  () = c.process (__argv, 1);
 
  INSTALL_MODULESDIR[*] = stdmoduledir;
  INSTALL_MODULESDIR[wherefirst ("curl" == MODULES)] = usrmoduledir;
  INSTALL_MODULESDIR[wherefirst ("iconv" == MODULES)] = usrmoduledir;

  if (-1 == chdir (SOURCEDIR))
    {
    () = fprintf (stderr, "%s: cannot change to sources directory ERRNO: %s\n",
       SOURCEDIR, errno_string (errno));
    exit (1);
    }

  fs = fswalk_new (&dir_callback, &file_callback);
 
  () = fprintf (stdout, "Trying to compile slang sources\n");
 
  fs.walk ("me");
  fs.walk ("you");
  fs.walk ("she");

  () = fprintf (stdout, "Compiling slang sources ... done\n");
 
  if (ARE_WE_BUILDING_MODULES)
    array_map (Void_Type, &compilemodules, MODULES, SMODULESDIR, INSTALL_MODULESDIR, EXTRAARG);

  exit (0);
}

main ();
