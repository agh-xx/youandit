srv->cls;
srv->write_str_at (sprintf ("%s%s", HEADER,
  repeat (" ", COLUMNS - strlen (HEADER))), 0, 0, 0);
