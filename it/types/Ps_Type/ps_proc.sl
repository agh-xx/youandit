define main ()
{
  %sigprocmask (SIG_SETMASK, [SIGINT]);
 
  variable
    i,
    ar,
    tok,
    pid,
    out_fn,
    status,
    stdoutw,
    stdoutr,
    argv = [which ("ps"), "-e", "f", "kpgrp", "-o",
      "user,pgrp,ppid,pid,pri,pcpu,pmem,size,time,args"],
    seconds = 1,
    out_fd = dup_fd (fileno (stdout)),
    err_fd = dup_fd (fileno (stderr)),
    c = cmdopt_new (&_usage);
 
  c.add ("seconds", &seconds;type = "int");
  c.add ("out_fn", &out_fn;type = "string");
 
  () = c.process (__argv, 1);
 
    variable
      stderrw = open (STDERR, O_WRONLY|O_APPEND|O_CREAT, S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH);
      stdoutw = open (out_fn, O_WRONLY|O_TRUNC|O_CREAT, S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH);

    () = dup2_fd (stdoutw, 1);
    () = dup2_fd (stderrw, 2);

    pid = fork ();

    if ((0 == pid) && -1 == execv (argv[0], argv))
      return 1;

    status = waitpid (pid, 0);

  %  () = close (stderrw);
  %  () = _close (_fileno (stdoutw));
  %
  %  () = dup2_fd (out_fd, 1);
  %  () = dup2_fd (err_fd, 2);
 
    %ar = read_fd (stdoutr);
    %
    %ifnot (NULL == ar)
    %  {
    %  ar = strchop (ar, '\n', 0);
    %  _for i (0, length (ar) - 1)
    %    if (1 < length (strtok (ar[i])))
    %      if ("0" == strtok (ar[i])[1])
    %        ar[i] = NULL;

    %  ar = ar[wherenot (_isnull (ar))];
    % % ar = ar[array_sort (ar)];

    %  array_map (Void_Type, print_norm, ar);
    %  }
    %
    %() = _close (_fileno (stdoutr));

  return 0;
}
