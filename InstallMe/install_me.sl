% the following function will be redefined later again

define which (executable)
{
  variable
    ar,
    path;

  path = getenv ("PATH");
  path = strchop (path, path_get_delimiter (), 0);
  path = array_map (String_Type, &path_concat, path, executable);
  path = path [wherenot (array_map (Integer_Type, &isdirectory, path))];

  ar = wherenot (array_map (Integer_Type, &access, path, X_OK));

  if (length (ar))
    return path[ar][0];
  else
    return NULL;
}

if (NULL == which ("stty"))
  {
  () = fputs ("stty executable hasn't been found in PATH\n", stderr);
  exit (1);
  }

if (NULL == which ("ps"))
  {
  () = fputs ("ps executable hasn't been found in PATH\n", stderr);
  exit (1);
  }

if (NULL == which ("sudo"))
  {
  () = fputs ("sudo executable hasn't been found in PATH\n", stderr);
  exit (1);
  }

import ("fork");

$2 = which ("cc");

if (NULL == $2)
  {
  () = fputs ("You don't have cc installed, cannot compile sources\n", stderr);
  exit (1);
  }

$3 = which ("slsh");

$4 = fork ();

if ((0 == $4) && -1 == execv ($3, [$3,
  sprintf ("%s/InstallMe/install_proc.sl", SOURCEDIR),
  sprintf ("--rootdir=%s", ROOTDIR),
  sprintf ("--bindir=%s", BINDIR),
  sprintf ("--sourcedir=%s", SOURCEDIR),
  sprintf ("--stdmoduledir=%s/std", MODULEDIR),
  sprintf ("--usrmoduledir=%s/usr", MODULEDIR),
  sprintf ("--persmoduledir=%s/local", MODULEDIR),
  sprintf ("--are_we_building_modules=%d", $1 ? 0 : 1),
  sprintf ("--cc=%s", $2)]))
  {
  () = kill ($4, SIGKILL);
  () = fputs ("failed to create install proccess\n", stderr);
  exit (1);
  }

$1 = waitpid ($4, 0);

if ($1.exit_status)
  {
  () = fputs ("failed to compile and install myself\n", stderr);
  exit ($1.exit_status);
  }

array_map (Void_Type, &__uninitialize, [&$1, &$2, &$3, &$4]);
