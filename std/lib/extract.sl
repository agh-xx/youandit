private define print (fd, func)
{

  variable buf = read_fd (fd);

   array_map (Void_Type, func, strtok (buf, "\n"));
}

private define untar (archive, file, verbose, tar)
{
  variable
    stderrr,
    stderrw,
    pid,
    status,
    num,
    buf,
    out_fd = verbose ? dup_fd (fileno (stdout)) : NULL,
    err_fd = dup_fd (fileno (stderr)),
    ar = String_Type[0];

  if (verbose)
    {
    variable stdoutw, stdoutr;
    (stdoutr, stdoutw) = pipe ();
    () = dup2_fd (stdoutw, 1);
    }

  (stderrr, stderrw) = pipe ();
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (tar, [tar, sprintf ("-x%sf", verbose ? "v" : ""),
        archive, "--strip-components=1"]))
    return -1;

  status = waitpid (pid, 0);

  ifnot (status.exit_status)
    if (verbose)
      {
      () = _close (_fileno (stdoutw));
      () = dup2_fd (out_fd, 1);
      (@print_out) (sprintf ("extracting %s", file));
      print (stdoutr, print_out);
      }

  () = _close (_fileno (stderrw));
  () = dup2_fd (err_fd, 2);

  if (status.exit_status)
    {
    (@print_err) (sprintf ("tar ERROR while unpacking %s", file));
    print (stderrr, print_err);
    }
 
  () = remove (archive);

  return status.exit_status;
}

private define func_z (archive, verbose, type)
{
  variable
    stdoutw,
    stderrr,
    stderrw,
    pid,
    status,
    num,
    buf,
    err_fd = dup_fd (fileno (stderr)),
    tar = which ("tar"),
    exec = which (type == ".xz" ? "xz" : type == ".bz2" ? "bzip2" : "gzip");

  if (NULL == exec)
    {
    (@print_err) (sprintf ("%s executable couldn't be found in PATH",
      type == ".xz" ? "xz" : type == ".bz2" ? "bzip2" : "gzip"));
    return -1;
    }

  if (NULL == tar)
    {
    (@print_err) ("tar executable couldn't be found in PATH");
    return -1;
    }

  (stderrr, stderrw) = pipe ();

  stdoutw = open ("archive.tar", O_RDWR|O_CREAT|O_BINARY, S_IRWXU);

  pid = fork ();

  () = dup2_fd (stderrw, 2);
  () = dup2_fd (stdoutw, 1);

  if ((0 == pid) && -1 == execv (exec, [exec, "-dc", archive]))
    return -1;

  status = waitpid (pid, 0);
 
  () = _close (_fileno (stderrw));
  () = dup2_fd (err_fd, 2);

  if (status.exit_status)
    {
    (@print_err) (sprintf ("ERROR while extracting %s", archive));
    print (stderrr, print_err);
    return -1;
    }

  return untar ("archive.tar", archive, verbose, tar);
}

private define func_unrar (archive, verbose, type)
{
  variable
    pid,
    stdoutw,
    unrar = [which ("unrar")],
    stdoutr,
    stderrr,
    stderrw,
    status,
    buf,
    err_fd = dup_fd (fileno (stderr)),
    out_fd = verbose ? dup_fd (fileno (stdout)) : NULL,
    num,
    ar = String_Type[0];

  if (NULL == unrar[0])
    {
    (@print_err) ("unrar executable couldn't be found in PATH");
    return -1;
    }

  unrar = [unrar, "e", "-y", sprintf ("-id%s", verbose ? "c" : "q"), archive];

  if (verbose)
    {
    (stdoutr, stdoutw) = pipe ();
    () = dup2_fd (stdoutw, 1);
    }

  (stderrr, stderrw) = pipe ();
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (unrar[0], unrar))
  return -1;

  status = waitpid (pid, 0);

  ifnot (status.exit_status)
    if (verbose)
      {
      () = _close (_fileno (stdoutw));
      () = dup2_fd (out_fd, 1);
      print (stdoutr, print_out);
      }

  () = _close (_fileno (stderrw));
  () = dup2_fd (err_fd, 2);

  if (status.exit_status)
    {
    (@print_err) (sprintf ("ERROR while extracting %s", archive));
    print (stderrr, print_err);
    }

  return status.exit_status;
}

private define func_unzip (archive, verbose, type)
{
  variable
    pid,
    stdoutw,
    unzip = [which ("unzip")],
    stdoutr,
    stderrr,
    stderrw,
    err_fd = dup_fd (fileno (stderr)),
    out_fd = verbose ? dup_fd (fileno (stdout)) : NULL,
    status,
    buf,
    num,
    ar = String_Type[0];

  if (NULL == unzip[0])
    {
    (@print_err) ("unzip executable couldn't be found in PATH");
    return -1;
    }

  unzip = [unzip, sprintf ("-%suo", verbose ? "" : "q"), archive];

  if (verbose)
    {
    (stdoutr, stdoutw) = pipe ();
    () = dup2_fd (stdoutw, 1);
    }

  (stderrr, stderrw) = pipe ();
  () = dup2_fd (stderrw, 2);
 
  pid = fork ();

  if ((0 == pid) && -1 == execv (unzip[0], unzip))
  return -1;

  status = waitpid (pid, 0);

  ifnot (status.exit_status)
    if (verbose)
      {
      () = _close (_fileno (stdoutw));
      () = dup2_fd (out_fd, 1);
      print (stdoutr, print_out);
      }

  () = _close (_fileno (stderrw));
  () = dup2_fd (err_fd, 2);

  if (status.exit_status)
    {
    (@print_err) (sprintf ("ERROR while extracting %s", archive));
    print (stderrr, print_err);
    }

  return status.exit_status;
}

define extract (archive, verbose, dir, strip)
{
  variable
    type = path_extname (archive),
    retval,
    methods = [&func_z, &func_z, &func_z, &func_z, &func_unzip, &func_unrar],
    method,
    newdir,
    bsname = path_basename_sans_extname (archive),
    saveddir = getcwd ();

  ifnot (saveddir == dir)
    if (-1 == chdir (dir))
      {
      (@print_err) (sprintf ("couldn't change directory to: %s", dir));
      return -1;
      }
 
  if (NULL == strip)
    {
    % it could be different than the actual name stored in archive
    if (1 < length (strchop (bsname, '-', 0)))
      {
      bsname = strchop (bsname, '-', 0);
      newdir = bsname[0];
      if (2 < length (strchop (strjoin (bsname[[1:]]), '.', 0)))
        newdir += sprintf ("-%s", strjoin (strchop (strjoin (bsname[[1:]]), '.', 0)[[0:1]], "."));
      }
    % easy fallback (I don't really care), this program is based in unix standards
    else
      {
      newdir = bsname;
      while (1 < length (strchop (newdir, '.', 0)))
        newdir = path_basename_sans_extname (newdir);
      }

    if (-1 == mkdir (newdir))
      {
      (@print_err) (sprintf ("couldn't create directory: %s, errno: %s",
        newdir, errno_string (errno)));

      return -1;
      }

    () = chdir (newdir);
    }

  ifnot (any (type == [".xz", ".bz2", ".zip", ".gz", ".tgz", ".rar"]))
    {
    (@print_err) (sprintf ("%s: Unkown type", type));
    return -1;
    }
 
  method = methods[where (type == [".xz", ".gz", ".tgz", ".bz2", ".zip", ".rar"])[0]];
  retval = (@method) (archive, atoi (verbose), type);
 
  ifnot (saveddir == dir)
    () = chdir (saveddir);
 
  return retval;
}
