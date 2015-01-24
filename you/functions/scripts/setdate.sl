define gethwclock ()
{
  variable
    fp,
    ref,
    pid,
    stdoutr,
    stdoutw,
    stderrr,
    stderrw,
    status;

  (stdoutr, stdoutw) = pipe ();
  (stderrr, stderrw) = pipe ();
 
  pid = fork ();

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);

  if ((0 == pid) && -1 == execv ("/sbin/hwclock", ["/sbin/hwclock", "-r"]))
    return;

  status = waitpid (pid, 0);

  fp = fdopen (stdoutr, "r");
  () = fgets (&ref, fp);
  () = fclose (fp);

  (@print_norm) (sprintf ("Hardware clock is: %s", ref));
}

define sethwclock ()
{
  variable
    status,
    pid = fork ();

  if ((0 == pid) && -1 == execv ("/sbin/hwclock", ["/sbin/hwclock", "--systohc"]))
    return;

  status = waitpid (pid, 0);
}

define main ()
{
  (@print_norm) ("Setting Date and Hardware Clock";dont_write_to_stdout, print_in_msg_line);

  gethwclock ();

  variable
    fp,
    ref,
    tim = __argv[-1],
    pid,
    stdoutr,
    stdoutw,
    stderrr,
    stderrw,
    status;

  (stdoutr, stdoutw) = pipe ();
  (stderrr, stderrw) = pipe ();
 
  pid = fork ();

  () = dup2_fd (stdoutw, 1);
  () = dup2_fd (stderrw, 2);

  if ((0 == pid) && -1 == execv ("/bin/date", ["/bin/date", tim]))
    return 1;

  status = waitpid (pid, 0);

  fp = fdopen (stdoutr, "r");
  () = fgets (&ref, fp);
  () = fclose (fp);

  (@print_norm) (sprintf ("Set date to: %s", ref));
  (@print_norm) ("Changing hardware clock, wait 2 seconds ...";
    dont_write_to_stdout, print_in_msg_line);

  sethwclock ();

  sleep (2);
 
  gethwclock ();

  return 0;
}
