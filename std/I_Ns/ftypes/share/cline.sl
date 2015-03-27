private define quit ()
{
  if (rl_.c_.argv[0] == "q!")
    if (s_._flags & MODIFIED)
      s_._flags = s_._flags xor MODIFIED;

  exit_me ();
}

private define write_file ()
{
  ifnot (_NARGS)
    s_.writefile ();
  else
    {
    variable file = ();
    variable fp = fopen (file, "w");
    variable i;
    variable line;

    if (typeof (s_.p_.lins[0]) == List_Type)
      _for i (0, length (s_.p_.lins) - 1)
        {
        line = strjoin (list_to_array (s_.p_.lins[i]));
        line = substr (line, s_._indent + 1, -1);
        () = fprintf (fp, "%s\n", line);
        }
    else
      _for i (0, length (s_.p_.lins) - 1)
        {
        line = strjoin (s_.p_.lins[i]);
        line = substr (line, s_._indent + 1, -1);
        () = fprintf (fp, "%s\n", line);
        }
    }
}

private define write_quit ()
{
  s_.writefile ();
  exit_me ();
}

cf["w"] = &write_file;
cf["q"] = &quit;
cf["wq"] = &write_quit;
cf["q!"] = &quit;

com = assoc_get_keys (cf);
