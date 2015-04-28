define main ()
{
  variable
    i,
    ii,
    tok,
    ext,
    tim,
    index,
    retval,
    passwd,
    seca = 0,
    secb = 0,
    format = "ogg",
    removesource = 0,
    input = NULL,
    output = NULL,
    end = NULL,
    start = NULL,
    issudo = NULL,
    duration = NULL,
    gotopager = 0,
    form = [23,59,59],
    secst = [60 * 60, 60, 0],
    exts = [".mp4", ".flv", ".webm", ".avi"],
    file = SCRATCHBUF,
    ffmpeg = which ("ffmpeg"),
    argv = [ffmpeg],
    args = __pop_list (_NARGS - 1);

  args = list_to_array (args, String_Type);
 
  index = proc->is_arg ("--pager", args);
  ifnot (NULL == index)
    {
    gotopager = 1;
    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }

  index = proc->is_arg ("--sudo", args);
  ifnot (NULL == index)
    {
    issudo = 1;
    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }

  index = proc->is_arg ("--tomp3", args);
  ifnot (NULL == index)
    {
    format = "mp3";
    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }

  index = proc->is_arg ("--removesource", args);
  ifnot (NULL == index)
    {
    removesource = 1;
    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }

  index = proc->is_arg ("--start=", args);
  ifnot (NULL == index)
    {
    tok = strchop (args[index], '=', 0);
    if (2 == length (tok))
      start = strchop (tok[1], ':', 0);
    else
      start = NULL;

    ifnot (NULL == start)
      ifnot (3 == length (start))
        start = NULL;
 
    ifnot (NULL == start)
      {
      _for i (0, 2)
        ifnot (start[i] == "00")
          if (1 > atoi (start[i]))
            {
            srv->send_msg (sprintf ("%s: wrong time format", strjoin (start, ":")), -1);
            throw GotoPrompt;
            }
          else
            if (atoi (start[i]) > form[i])
              {
              srv->send_msg (sprintf ("%s: wrong time format", strjoin (start, ":")), -1);
              throw GotoPrompt;
              }
            else
              seca += atoi (start[i]) * secst[i];
 
      start = strjoin (start, ":");
      }

    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }

  index = proc->is_arg ("--end=", args);
  if (NULL != index && NULL != start)
    {
    tok = strchop (args[index], '=', 0);
    if (2 == length (tok))
      end = strchop (tok[1], ':', 0);
    else
      end = NULL;

    ifnot (NULL == end)
      ifnot (3 == length (end))
        end = NULL;
 
    ifnot (NULL == end)
      {
      _for i (0, 2)
        ifnot (end[i] == "00")
          if (1 > atoi (end[i]))
            {
            srv->send_msg (sprintf ("%s: wrong time format", strjoin (end, ":")), -1);
            throw GotoPrompt;
            }
          else
            if (atoi (end[i]) > form[i])
              {
              srv->send_msg (sprintf ("%s: wrong time format", strjoin (end, ":")), -1);
              throw GotoPrompt;
              }
            else
              secb += atoi (end[i]) * secst[i];
 
      if (secb > seca)
        duration = string (secb - seca);
      }

    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }

  index = proc->is_arg ("--input=", args);
  ifnot (NULL == index)
    {
    tok = strchop (args[index], '=', 0);
    if (2 == length (tok))
      input = tok[1];

    if (-1 == access (input, F_OK))
      {
      srv->send_msg (sprintf ("%s: doesn't exists", input), -1);
      throw GotoPrompt;
      }

    if (0 == any (path_extname (input) == exts))
      {
      srv->send_msg (sprintf ("%s extension isn't supported", path_extname (input)[[1:]]), -1);
      throw GotoPrompt;
      }

    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }
  else
    {
    srv->send_msg ("--input= option is required", -1);
    throw GotoPrompt;
    }

  index = proc->is_arg ("--output=", args);
  ifnot (NULL == index)
    {
    tok = strchop (args[index], '=', 0);
    if (2 == length (tok))
      output = tok[1];
    else
      output = input;

    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }
  else
    output = input;

  output = sprintf ("%s/%s.%s", path_dirname (output), path_basename_sans_extname (output),
    format);

  ifnot (access (output, F_OK))
    {
    variable msg = sprintf ("%s: exists, overwrite? y[es]/n[o]", output);
    srv->send_msg_and_refresh (msg, 1);
    variable chr = (@getch);
    while (0 == any (['y', 'n'] == chr))
      chr = (@getch);
    if ('n' == chr)
      {
      srv->send_msg (" ", 0);
      throw GotoPrompt;
      }
    }

  format = "ogg" == format ? "libvorbis" : "libmp3lame";
  ifnot (NULL == start)
    argv = [argv, "-ss", start];

  argv = [argv, "-i", input, "-y", "-vn", "-c:a", format, "-loglevel", "info"];

  ifnot (NULL == duration)
    argv = [argv, "-t", duration, output];
  else
    argv = [argv, output];

  ifnot (NULL == issudo)
    {
    argv = [
      SUDO_EXEC, "-S", "-E",  "-C", sprintf ("%d", _fileno (SRV_SOCKET)+ 1),
      argv];

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
    }

  variable p = proc->init (NULL != issudo, 1, 1);
 
  ifnot (NULL == issudo)
    p.stdin.in = passwd;

  p.stdout.file = SCRATCHBUF;
  p.stderr.file = SCRATCHBUF;
  p.stderr.wr_flags = ">>";

  srv->send_msg_and_refresh ("press q to to stop converting", 1);

  variable status = p.execv (argv, NULL); 

  srv->send_msg_and_refresh (" ", 0);

  file = SCRATCHBUF;

  ifnot (gotopager)
    ved (file;drawonly);
  else
    ved (file);

  ifnot (status.exit_status)
    if (removesource)
      if (-1 == remove (input))
        srv->send_msg (sprintf ("%s: failed to remove, %s", path_basename (input),
          errno_string (errno)), -1);

  throw GotoPrompt;
}
