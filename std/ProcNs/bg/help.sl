define _usage ()
{
  variable
    if_opt_err = _NARGS ? () : " ",
    helpfile = qualifier ("helpfile", sprintf ("%s/help.txt", INFODIR)),
    ar = _NARGS ? [if_opt_err] : String_Type[0];

  if (NULL == helpfile)
    {
    () = fprintf (STDERRFP, "No Help file available for %s", __argv[0]);
    EXIT_CODE = 1;
    ifnot (length (ar))
      exit_me ();
    }

  ifnot (access (helpfile, F_OK))
    ar = [ar, readfile (helpfile)];

  ifnot (length (ar))
    {
    () = fprintf (STDERRFP, "Empty Help file for %s", __argv[0]);
    EXIT_CODE = 1;
    exit_me ();
    }

  () = array_map (Integer_Type, &fprintf, STDOUTFP, "%s\n", ar);
 
  EXIT_CODE = _NARGS;

  exit_me ();
}

define info ()
{
  variable
    info_ref = NULL,
    infofile = qualifier ("infofile", sprintf ("%s/desc.txt", INFODIR)),
    ar;

  if (NULL == infofile || -1 == access (infofile, F_OK))
    {
    () = fprintf (STDERRFP, "No info file available for %s", __argv[0]);
    EXIT_CODE = 1;
    exit_me ();
    }

  ar = readfile (infofile);
 
  () = array_map (Integer_Type, &fprintf, STDOUTFP, "%s\n", ar);
 
  exit_me ();
}
