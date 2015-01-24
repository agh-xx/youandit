private variable
  line = 2,
  msges = String_Type[0];

define print_in_new_window (str)
{
  variable i;

  str = sprintf ("%s%s", str, repeat (" ", COLUMNS - strlen (str)+1));
  if (line == PROMPTROW - 1)
    {
    msges = [msges[[1:]], str];
    _for i (0, length (msges) - 1)
      srv->write_str_at (substr (msges[i], 2, -1), msges[i][0] - 48, i+2, 0);
    }
  else
    {
    msges = [msges, str];
    srv->write_str_at (substr (str, 2, -1), str[0] - 48, line, 0);
    line++;
    }
}

define f_print_norm (str)
{
  if (qualifier_exists ("print_in_msg_line"))
    srv->send_msg (str, 0);
  else if (PRINT_IN_NEW_WINDOW)
    print_in_new_window (sprintf ("0%s", str));

  srv->refresh;
 
  ifnot (qualifier_exists ("dont_write_to_stdout"))
    () = fprintf (STDOUTFP, "%s\n", strtrim_end (str));
}

define f_print_err (str)
{
  if (qualifier_exists ("print_in_msg_line"))
    srv->send_msg (str, -1);
  else if (PRINT_IN_NEW_WINDOW)
    print_in_new_window (sprintf ("1%s", str));

  srv->refresh;

  ifnot (qualifier_exists ("dont_write_to_stdout"))
    () = fprintf (STDOUTFP, "%s\n", strtrim_end (str));

  () = fprintf (STDERRFP, "%s\n", strtrim_end (str));
}

define f_print_warn (str)
{
  if (qualifier_exists ("print_in_msg_line"))
    srv->send_msg (str, 1);
  else if (PRINT_IN_NEW_WINDOW)
    print_in_new_window (sprintf ("3%s", str));

  srv->refresh;

  ifnot (qualifier_exists ("dont_write_to_stdout"))
    () = fprintf (STDOUTFP, "%s\n", strtrim_end (str));

  () = fprintf (STDERRFP, "%s\n", strtrim_end (str));
}

define f_highlight (color, row, col, dr, dc)
{
  srv->set_color_in_region (color, row, col, dr, dc);
}

highlight = &f_highlight;
print_in_new_wind = &print_in_new_window;
print_norm = &f_print_norm;
print_warn = &f_print_warn;
print_err = &f_print_err;
