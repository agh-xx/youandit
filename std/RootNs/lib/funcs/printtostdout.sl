define main (self, msg)
{
  variable
    len = length (msg),
    orig = msg,
    chr;

  msg = self.printout (msg, 1, &len;;__qualifiers ());

  if (len)
    {
    srv->send_msg_and_refresh ("Press any key except tab to exit, press tab to scroll", 2);

    chr = (@getch);

    while (9 == chr)
      {
      len = length (msg);
      msg = self.printout (msg, 1, &len;;__qualifiers ());
      ifnot (len)
        msg = orig;
      chr = (@getch);
      }
    }
  else
    {
    if (qualifier_exists ("just_print"))
      throw Break;

    srv->send_msg_and_refresh ("Press any key to exit", 0);
    () = (@getch);
    }

  srv->send_msg (NULL, 0);
 
  ifnot (qualifier_exists ("dont_draw"))
    if (__is_initialized (&CW))
      CW.drawwind (;reread_buf);

  throw Break;
}
