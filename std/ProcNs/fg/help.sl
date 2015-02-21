define _usage ()
{
  variable
    if_opt_err = _NARGS ? () : " ",
    helpfile = qualifier ("helpfile", sprintf ("%s/help.txt", INFODIR)),
    ar = _NARGS ? [if_opt_err] : String_Type[0];

  if (NULL == helpfile)
    {
    (@print_out) (sprintf ("No Help file available for %s", __argv[0]));
    ifnot (length (ar))
      exit (1);
    }

  ifnot (access (helpfile, F_OK))
    ar = [ar, readfile (helpfile)];

  ifnot (length (ar))
    {
    (@print_out) (sprintf ("No Help file available for %s", __argv[0]));
    exit (1);
    }

  printtostdout (ar;header = sprintf ("Help for %s", __argv[0]));

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
    (@print_out) (sprintf ("No Info file available for %s", __argv[0]));
 
    EXIT_CODE = 1;
    exit_me ();
    }

  ar = readfile (infofile);
  printtostdout (ar;header = sprintf ("Information for %s", __argv[0]));
 
  exit_me ();
}
