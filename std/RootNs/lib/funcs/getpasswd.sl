define main (self)
{
  variable
  str = "",
  retval;

  srv->send_msg ("Please type your password", 0);
  root.topline ();

  forever
    {
    srv->write_prompt ("", 0;prompt_char = "");

    retval = (@getch);

    if (any (keys->cmap.changelang == retval))
      {
      self.call ("change_getch");
      sleep (1);
      srv->send_msg ("Please type your password", 1);
      continue;
      }

    if (any (keys->cmap.backspace == retval))
      {
      if (strlen (str))
        str = substr (str, 1, strlen (str) - 1);

      continue;
      }

    if ('\r' == retval)
      throw Return, " ", str;

    str += char (retval);
    }
}
