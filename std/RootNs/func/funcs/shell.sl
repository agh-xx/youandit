define main ()
{
  variable
    shells = ["bash", "dash", "zsh", "sh"],
    sh = 2 == _NARGS ? () : "zsh";

  if (NULL == which (sh))
    {
    srv->send_msg (sprintf (
      "%s: hasn't been found in PATH, or is not an executable", sh), -1);
    throw GotoPrompt;
    }
 
  ifnot (any (shells == sh))
    {
    srv->send_msg (sprintf (
      "%s: Is not allowed, use one of: %s", sh, strjoin (shells, ",")), -1);
    throw GotoPrompt;
    }
 
  if (TTY_Inited)
    {
    flush_input ();
    reset_tty ();
    }
 
  srv->cls ();
  srv->refresh ();

  variable exit_code = system (sh);

  init_tty (-1, 0, 0);
 
  CW.drawwind ();
  root.topline ();

  srv->send_msg (sprintf ("%s returned %d", sh, exit_code), exit_code ? 1 : 0);
  srv->refresh ();

  throw GotoPrompt;
}
