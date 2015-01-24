define send_msg ()
{
  variable
    arstr = sock->send_bit_get_str_ar (SRV_FD, 0),
    ar = sock->send_bit_get_int_ar (SRV_FD, 0);

  f_send_msg (arstr[0], ar[0], ar[1], ar[2]);
 
  if (strlen (arstr[0]) && " " != arstr[0])
    {
    variable fp = fopen (arstr[1], "a+");
    () = fprintf (fp, "str |%s| color |%d| MSGROW |%d| COLUMNS |%d|\n", arstr[0], ar[0], ar[1], ar[2]);
    () = fclose (fp);
    }

  sock->send_bit (SRV_FD, 0);
}

funcs["send_msg"] = &send_msg;

define send_msg_and_refresh ()
{
  variable
    arstr = sock->send_bit_get_str_ar (SRV_FD, 0),
    ar = sock->send_bit_get_int_ar (SRV_FD, 0);

  f_send_msg (arstr[0], ar[0], ar[1], ar[2]);

  if (strlen (arstr[0]) && " " != arstr[0])
    {
    variable fp = fopen (arstr[1], "a+");
    () = fprintf (fp, "str |%s| color |%d| MSGROW |%d| COLUMNS |%d|\n", arstr[0], ar[0], ar[1], ar[2]);
    () = fclose (fp);
    }
 
  slsmg_refresh ();
  sock->send_bit (SRV_FD, 0);
}

funcs["send_msg_and_refresh"] = &send_msg_and_refresh;
