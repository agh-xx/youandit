define main ()
{
  variable slsh = which ("slsh");

  if (TTY_Inited)
    {
    flush_input ();
    reset_tty ();
    }
 
  srv->cls ();
  srv->refresh ();

  variable exit_code = system (slsh);

  init_tty (-1, 0, 0);
 
  CW.drawwind ();
  root.topline ();

  srv->send_msg (sprintf ("slsh returned %d", exit_code), exit_code ? 1 : 0);
  srv->refresh ();

  throw GotoPrompt;
}
