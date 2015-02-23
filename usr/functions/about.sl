define main ()
{
  variable
    retval,
    fname,
    index,
    savejs = 0,
    docs = Assoc_Type[String_Type, "null"],
    argv = __pop_list (_NARGS - 1);

  argv = list_to_array (argv, String_Type);

  ifnot (length (argv))
    {
    srv->send_msg ("ARG ERROR, a filename is needed", -1);
    throw GotoPrompt;
    }
  
  docs["--me"] = sprintf ("%s/about_me/me.abt", DATASHAREDIR);
  docs["--develop"] = sprintf ("%s/about_me/develop.abt", DATASHAREDIR);

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
  else
    savejs = 1;

  index = proc->is_arg ("--savejs", argv);
  ifnot (NULL == index)
    savejs = 1; 

  retval = proc->edVi (fname, savejs);

  CW.drawwind (;reread_buf);
  throw GotoPrompt;
}
