define main (self)
{
  variable
    cw,
    name,
    retval,
    passwd;

  ifnot (qualifier_exists ("force"))
    {
    retval = root.lib.ask (["do you want to reboot the machine?", "[y/n/escape to abort]"],
      ['y', 'n'];header = "QUESTION FROM REBOOT FUNCTION");
    if ('n' == retval || 033 == retval)
      {
      srv->send_msg ("Aborting ...", 0);
      throw GotoPrompt;
      }
    }

  passwd = root.lib.getpasswd ();

  ifnot (strlen (passwd))
    {
    srv->send_msg ("Password is an empty string. Aborting ...", -1);
    throw GotoPrompt;
    }

  retval = root.lib.validate_passwd (passwd);

  if (NULL == retval)
    {
    srv->send_msg ("This is not a valid password", -1);
    throw GotoPrompt;
    }

  _for name (0,length (root.windnames)-1)
    {
    cw = root.windows[root.windnames[name]];
    cw.history.write ();
    }

  () = evalfile (sprintf ("%s/I_Ns/lib/rm_tmp_dir", STDNS), "exit");
  (@__get_reference ("exit->rm_tmpdir"));

  variable
    pid,
    stdinr,
    stdinw,
    stderrr,
    stderrw,
    status;

  (stdinr, stdinw) = pipe ();
  (stderrr, stderrw) = pipe ();
 
  () = write (stdinw, passwd + "\n");
  () = close (stdinw);
 
  pid = fork ();

  dup2_fd (stdinr, 0);
  dup2_fd (stderrw, 2);

  if ((0 == pid) && -1 == execv (SUDO_EXEC, ["sudo", "-S", "/sbin/shutdown", "-r", "now"]))
    {
    srv->send_msg ("Could't reboot the machine", -1);
    throw GotoPrompt;
    }

  throw GotoPrompt;
}
