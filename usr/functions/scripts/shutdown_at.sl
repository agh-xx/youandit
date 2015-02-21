%set_import_module_path (getenv ("IMPORT_PATH"));

array_map (Void_Type, &import, ["fork", "sysconf", "fcntl"]);

%define sigalarm_handler (sig)
%{
%  sleep (0.5);
%  exit (0);
%}
%
%signal (SIGALRM, &sigalarm_handler);

define main ()
{
  variable
    passwd,
    seconds = __argv[-1],
    passwd_f = __argv[-2],
    fp = fopen (passwd_f, "r+");

  () = fgets (&passwd, fp);
  () = fseek (fp, 0, SEEK_SET);
  () = fprintf (fp, "daaflalskeedkkdhewqpodscnakladlspowewiouroirhdfhhdsds\n");
  () = fclose (fp);
  () = remove (passwd_f);

  sleep (atoi (seconds));

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

  () = dup2_fd (stdinr, 0);
  () = dup2_fd (stderrw, 2);

  if ((0 == pid) && -1 == execv ("/usr/bin/sudo",
      ["/usr/bin/sudo", "-S", "/sbin/shutdown", "-h", "now"]))
    return 1;

  return 0;
}
