define main ()
{
  variable
    retval,
    fname,
    docs = Assoc_Type[String_Type, "null"],
    argv = __pop_list (_NARGS - 1);

  ifnot (length (argv))
    {
    srv->send_msg ("ARG ERROR", -1);
    throw GotoPrompt;
    }

  docs["--me"] = sprintf ("%s/about_me/me.abt", DATASHAREDIR);
  docs["--develop"] = sprintf ("%s/about_me/develop.abt", DATASHAREDIR);
  docs["--aera"] = sprintf ("%s/about_ag/aera.abt", DATADIR);

  fname = docs[argv[0]];

  if ("null" == fname)
    {
    if (-1 == access (argv[0], F_OK))
      {
      srv->send_msg (sprintf ("%s: No such filename", argv[0]), -1);
      throw GotoPrompt;
      }

    if (-1 == access (argv[0], R_OK))
      {
      srv->send_msg (sprintf ("%s: Is not readable", argv[0]), -1);
      throw GotoPrompt;
      }

    if (isdirectory (argv[0]))
      {
      srv->send_msg (sprintf ("%s: Is a directory", argv[0]), -1);
      throw GotoPrompt;
      }

    fname = argv[0];
    }

  retval = proc->edVi (fname);
  CW.drawwind (;reread_buf);
  throw GotoPrompt;
}
