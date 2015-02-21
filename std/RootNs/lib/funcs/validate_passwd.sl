define main (self, passwd)
{
  variable
    pid,
    fp,
    stdinr,
    stdinw,
    stdoutw,
    stderrw,
    status;
 
  () = system (sprintf ("%s -K 2>/dev/null", SUDO_EXEC));

  srv->send_msg_and_refresh ("Validate password, please wait", 1);
 
  (stdinr, stdinw) = pipe ();
 
  fp = fdopen (stdinw, "w");
  () = fprintf (fp, "%s\n", passwd);
  () = fclose (fp);
 
  pid = fork ();

  stdoutw = open ("/dev/null", O_WRONLY|O_NOCTTY|O_APPEND);
  stderrw = open ("/dev/null", O_WRONLY|O_NOCTTY|O_APPEND);

  () = dup2_fd (stdinr, 0);
  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);

  if ((0 == pid) && -1 == execv (SUDO_EXEC, ["sudo", "-S", "ls"]))
    {
    srv->send_msg ("", 0);
    throw Return, " ", NULL;
    }

  status = waitpid (pid, 0);
  srv->send_msg ("", 0);
  throw Return, " ", status.exit_status ? NULL : 0;
}
