define init_proc (in, out, err, argv)
{
  variable
    Proc_Type = @Init_ProcType;

  if (in)
    Proc_Type.stdin = @Init_DescrType;

  if (out)
    Proc_Type.stdout = @Init_DescrType;

  if (err)
    Proc_Type.stderr = @Init_DescrType;

  Proc_Type.argv = argv;

  return Proc_Type;

}

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

  () = write (fd.write, fd.str);

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

define sysproc (s)
{
  ifnot (NULL == s.stdin)
    _pipe (s.stdin, stdin);

  ifnot (NULL == s.stdout)
    _open (s.stdout, stdout);

  ifnot (NULL == s.stderr)
    _open (s.stderr, stderr);

  s.pid = fork ();

  if ((0 == s.pid) && -1 == execv (s.argv[0], s.argv))
    return -1;

  s.status = waitpid (s.pid, 0);

  ifnot (NULL == s.stdout)
    {
    close_fd (s.stdout, stdout);

    if (NULL == s.stdout.file)
      s.stdout.ar = read_fd (s.stdout.read);
    }

  ifnot (NULL == s.stderr)
    {
    close_fd (s.stderr, stderr);

    if (NULL == s.stderr.file)
      s.stderr.ar = read_fd (s.stderr.read);
    }
 
  ifnot (NULL == s.stdin)
    close_fd (s.stdin, stdin);

  return 0;
}
