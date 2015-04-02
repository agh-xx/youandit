typedef struct
  {
  fg,
  pid,
  env,
  argv,
  stdin,
  stdout,
  stderr,
  status,
  retval,
  cleanup,
  connect,
  execfunc,
  } ProcType;

typedef struct
  {
  in,
  out,
  file,
  mode,
  keep,
  read,
  write,
  wr_flags,
  } DescrType;

private define parse_flags (fd)
{
  variable
    MODE_FLAGS = Assoc_Type[Integer_Type],
    WR_FLAGS = Assoc_Type[Integer_Type];

  WR_FLAGS[">"] = O_WRONLY|O_CREAT;
  WR_FLAGS[">|"] = O_WRONLY|O_TRUNC;
  WR_FLAGS[">>"] = O_WRONLY|O_APPEND;

  ifnot (NULL == fd.wr_flags)
    {
    ifnot (assoc_key_exists (WR_FLAGS, fd.wr_flags))
      fd.wr_flags = WR_FLAGS[">"];
    else
      fd.wr_flags = WR_FLAGS[fd.wr_flags];
    }
  else
    if (-1 == access (fd.file, F_OK))
      fd.wr_flags = WR_FLAGS[">"];
    else
      fd.wr_flags = WR_FLAGS[">|"];
 
  MODE_FLAGS["0600"] = S_IWUSR|S_IRUSR;

  ifnot (NULL == (fd.mode))
    {
    ifnot (assoc_key_exists (MODE_FLAGS, fd.mode))
      fd.mode = MODE_FLAGS["0600"];
    else
      fd.mode = MODE_FLAGS[fd.mode];
    }
  else if (fd.wr_flags & O_CREAT)
    fd.mode = MODE_FLAGS["0600"];
}

private define open_file (fd, fp)
{
  fd.keep = dup_fd (fileno (fp));
 
  parse_flags (fd);
 
  ifnot (NULL == fd.mode)
    fd.write = open (fd.file, fd.wr_flags, fd.mode);
  else
    fd.write = open (fd.file, fd.wr_flags);

  () = dup2_fd (fd.write, _fileno (fp));
}

private define close_fd (fd, fp)
{
  () = _close (_fileno (fd.write));
  () = dup2_fd (fd.keep, _fileno (fp));
}

private define open_fd (fd, fp)
{
  fd.keep = dup_fd (fileno (fp));

  (fd.read, fd.write) = pipe ();

  () = dup2_fd (fd.write, _fileno (fp));
}

private define _pipe (fd, fp)
{
  fd.keep = dup_fd (fileno (fp));
 
  (fd.read, fd.write) = pipe ();

  () = write (fd.write, fd.in);

  () = close (fd.write);
 
  () = dup2_fd (fd.read, _fileno (fp));
}

private define _open (fd, fp)
{
  ifnot (NULL == fd.file)
    open_file (fd, fp);
  else
    open_fd (fd, fp);
}

private define cleanup (s)
{
  ifnot (NULL == s.stdout)
    {
    close_fd (s.stdout, stdout);

    if (NULL == s.stdout.file)
      s.stdout.out = read_fd (s.stdout.read);
    }

  ifnot (NULL == s.stderr)
    {
    close_fd (s.stderr, stderr);

    if (NULL == s.stderr.file)
      s.stderr.out = read_fd (s.stderr.read);
    }
 
  ifnot (NULL == s.stdin)
    close_fd (s.stdin, stdin);
}

private define connect_to_socket (s, sockaddr)
{
  variable
    i = -1,
    sock = socket (PF_UNIX, SOCK_STREAM, 0);

  forever
    {
    i++;
    if (5000 < i)
      return NULL;

    try
      connect (sock, sockaddr);
    catch AnyError:
      continue;

    break;
    }
  
  return sock;
}

private define dopid (s)
{
  ifnot (NULL == s.stdin)
    _pipe (s.stdin, stdin);

  ifnot (NULL == s.stdout)
    _open (s.stdout, stdout);

  ifnot (NULL == s.stderr)
    _open (s.stderr, stderr);

  s.pid = fork ();
}

define init (in, out, err, argv)
{
  variable
    proc = @ProcType;

  if (in)
    proc.stdin = @DescrType;

  if (out)
    proc.stdout = @DescrType;

  if (err)
    proc.stderr = @DescrType;

  proc.argv = argv;
  proc.fg = qualifier_exists ("isbg") ? 0 : 1;
  proc.cleanup = &cleanup;
  proc.connect = &connect_to_socket;

  return proc;
}

define exec (s)
{
  dopid (s);

  ifnot (NULL == s.env)
    {
    if ((0 == s.pid) && -1 == execve (s.argv[0], s.argv, s.env))
      return -1;
    }
  else
    if ((0 == s.pid) && -1 == execv (s.argv[0], s.argv))
      return -1;
  
  if (s.fg)
    {
    s.status = waitpid (s.pid, 0);
    s.cleanup ();
    }

  return 0;
}
