private define doquit ()
{
  send_msg (" ", 0);
  exit_me (0);
}

static define quit ()
{
  variable
    file,
    flags = MODIFIED,
    args = __pop_list (_NARGS - 1),
    write_on_exit = args[0];
 
  ifnot (write_on_exit)
    doquit ();

  if (1 == length (args) || (2 == length (args) && cw_._fname == args[1]))
    {
    file = cw_._fname;
    flags = cw_._flags;
    }
  else
    {
    file = args[1];
    ifnot (access (file, F_OK))
      {
      send_msg_dr ("file exists, press q to quit without saving", 1,
        cw_.ptr[0], cw_.ptr[1]);
      if ('q' == get_char ())
        doquit ();

      srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);
      return;
      }

    if (-1 == access (file, W_OK))
      {
      send_msg_dr ("file is not writable, press q to quit without saving", 1,
        cw_.ptr[0], cw_.ptr[1]);
      if ('q' == get_char ())
        doquit ();

      srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);
      return;
      }
    }

  if (flags & MODIFIED)
    ifnot (0 == s_.writefile (file))
      {
      send_msg_dr (sprintf ("%s, press q to quit without saving", errno_string (errno)),
        1, NULL, NULL);
      if ('q' == get_char ())
        doquit ();

      srv->gotorc_draw (cw_.ptr[0], cw_.ptr[1]);
      return;
      }

  doquit ();
}
