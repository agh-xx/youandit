define exit_me (exit_code, msg)
{
  variable
    tty_inited = __get_reference ("TTY_Inited"),
    flush = NULL != tty_inited ? __get_reference ("flush_input") : NULL,
    reset = NULL != tty_inited ? __get_reference ("reset_tty") : NULL;

  ifnot (NULL == SRV_PID)
    {
    ifnot (access (SRV_SOCKADDR, F_OK))
      (@__get_reference ("srv->quit"));

    () = kill (SRV_PID, SIGKILL);
    }

  ifnot (NULL == PROC_PID)
    () = kill (PROC_PID, SIGKILL);

  if (@tty_inited)
    {
    (@flush) ();
    (@reset) ();
    }

  () = evalfile (sprintf ("%s/rm_tmp_dir", path_dirname (__FILE__)), "exit");
  (@__get_reference ("exit->rm_tmpdir"));

  () = fprintf (exit_code ? stderr : stdout, "%sExit_Status: %d\n",
    NULL == msg ? "" : msg + "\n", exit_code);

  exit (exit_code);
}
