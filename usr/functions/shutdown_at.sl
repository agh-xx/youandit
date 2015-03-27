define main ()
{
  variable
    pid,
    arg,
    when,
    passwd,
    status,
    retval,
    seconds,
    % a more rand'ed' name
    passwd_f = sprintf ("%s/_%ddown.txt", TEMPDIR, _time),
    args = __pop_list (_NARGS - 1);

  ifnot (length (args))
    {
    srv->send_msg ("You need to specify an action, use the tab completion", -1);
    throw GotoPrompt;
    }
 
  arg = args[0];

  if ("--when" == substr (arg, 1, 6))
    {
    if (NULL == getenv ("SHUTDOWN_AT_WHEN"))
      {
      srv->send_msg ("No shutdown action has scheduled", 1);
      throw GotoPrompt;
      }
 
    srv->send_msg (sprintf (
      "The computer will close at: %s", getenv ("SHUTDOWN_AT_WHEN")), 1);

    throw GotoPrompt;
    }

  if ("--killlastaction" == substr (arg, 1, 16))
    {
    if (NULL == getenv ("SHUTDOWN_AT_PID"))
      {
      srv->send_msg ("No shutdown action has scheduled", 1);
      throw GotoPrompt;
      }
 
    () = sock->send_str_ar_get_bit (PROC_SOCKET, ["bgkillpid"]);
    () = sock->send_int_get_bit (PROC_SOCKET, getenv ("SHUTDOWN_AT_PID"));
    () = sock->send_bit_get_int (PROC_SOCKET, 0);
 
    srv->send_msg ("Killed scheduled shutdown", 0);

    putenv ("SHUTDOWN_AT_PID");
    putenv ("SHUTDOWN_AT_WHEN");

    throw GotoPrompt;
    }

  ifnot ("--minutes=" == substr (arg, 1, 10))
    {
    srv->send_msg ("You need to specify minutes, use the --minutes=int option", -1);
    throw GotoPrompt;
    }
 
  ifnot (NULL == getenv ("SHUTDOWN_AT_PID"))
    {
    srv->send_msg ("There is already a scheduled action, use the --killlastaction switch", -1);
    throw GotoPrompt;
    }
 
  arg = strchop (arg, '=', 0)[1];
 
  ifnot (strlen (arg))
    {
    srv->send_msg ("You need to provide minutes", -1);
    throw GotoPrompt;
    }

  ifnot (Integer_Type == _slang_guess_type (arg))
    {
    srv->send_msg ("the specified minutes should be an integer", -1);
    throw GotoPrompt;
    }

  seconds = atoi (arg) * 60;
 
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

  writefile (passwd, passwd_f);
 
  when = ctime (_time + seconds);

  pid = proc->call (["shutdown_at", passwd_f, string (seconds),
      "--bg", "--nocl", "--constant",
      sprintf ("--execdir=%s/scripts", path_dirname (__FILE__)),
      sprintf ("--msgfname=%s", CW.msgbuf),
      sprintf ("--mainfname=%s", "/dev/null")]);

  putenv (sprintf ("SHUTDOWN_AT_PID=%d", pid));
  putenv (sprintf ("SHUTDOWN_AT_WHEN=%s", when));

  srv->send_msg (sprintf ("The computer will close at: %s", when), 0);
  throw GotoPrompt;
}
