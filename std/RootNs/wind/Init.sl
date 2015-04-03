private define gotopager ()
{
  variable
    args = _NARGS > 1 ?__pop_list (_NARGS - 1) : {},
    self = ();
 
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    __push_list (args);;__qualifiers ());
}

private define makeframename (self)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers);
}

private define setframes (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers);
}

private define framedelete (self, frame)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    frame;;__qualifiers ());
}

private define setwindim (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define setinfoline (self, buf, frame, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    buf, frame, len;;__qualifiers ());
}

private define set (self, buf, frame, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    buf, frame, len;;__qualifiers ());
}

private define setframesize (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define writeinfolines (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define drawframe (self, frame)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    frame;;__qualifiers ());
}

private define addframe (self)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define drawwind (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define gotoprompt (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define getbufpart (self, buf, fp, lines)
{
  variable
    b,
    i = 0,
    len = length (lines),
    line = lines[i],
    got = String_Type[length (lines)],
    ofs = int (sum (buf.ar_len[[0:lines[i] - 1]]));

  if (0 > ofs)
    ofs = 0;

  () = fseek (fp, ofs, SEEK_SET);

 while (i < len)
  {
  () = fgets (&b, fp);
  if (line == lines[i])
    {
    got[i] = strtrim_end (b, "\n");
    i++;
    }

  line++;
  }

  return got;
}

private define getbufline (self, buf, file, linenr)
{
  variable
    b,
    ofs = int (sum (buf.ar_len[[0:linenr - 1]])),
    fp = fopen (file, "r");

  if (0 > ofs)
    ofs = 0;

  () = fseek (fp, ofs, SEEK_SET);
 
  () = fgets (&b, fp);

  return strtrim_end (b, "\n");
}

private define getbuf (self, buf, file)
{
  variable
    b,
    ar = String_Type[0],
    lines = qualifier ("lines", buf.indices),
    ofs = lines[0]
      ? int (sum (buf.ar_len[[0:lines[0] - 1]]))
      : 0,
    fp = fopen (file, "r");
 
  if (0 > ofs)
    ofs = 0;

  () = fseek (fp, ofs, SEEK_SET);
 
  loop (length (lines))
    {
    () = fgets (&b, fp);
    ar = [ar, strtrim_end (b, "\n")];
    }

  return ar;
}

private define setar (self, buf, file)
{
  if (-1 == access (file, F_OK))
    {
    srv->send_msg (sprintf ("%s: %s", file, errno_string (errno)), 1);
    return NULL;
    }
 
  variable fp = fopen (file, "r");
  buf.ar_len = strbytelen (fgetslines (fp));
 
  return int (sum (buf.ar_len));
}

define main (self, name, type)
{
  throw Return, " ", struct
    {
    img = Img_Type[AVAILABLE_LINES + 1],
    dim,
    history,
    readline,
    frames_size,
    frame_size,
    frames = 0,
    type = type,
    name = name,
    maxframes = 3,
    minframes = 1,
    buffers = Frame_Type[0],
    dir = qualifier ("dir", getcwd ()),
    datadir = sprintf ("%s/%s", DATADIR, type),
    msgbuf = sprintf ("%s/%s/msg.txt", TEMPDIR, name),
    exec = self.exec,
    set = &set,
    setar = &setar,
    getbuf = &getbuf,
    addframe = &addframe,
    drawwind = &drawwind,
    setwindim = &setwindim,
    gotopager = &gotopager,
    setframes = &setframes,
    drawframe = &drawframe,
    gotoprompt = &gotoprompt,
    getbufpart = &getbufpart,
    getbufline = &getbufline,
    framedelete = &framedelete,
    setinfoline = &setinfoline,
    setframesize = &setframesize,
    makeframename = &makeframename,
    writeinfolines = &writeinfolines,
    cur = struct
      {
      mode,
      frame,
      mainbuf,
      mainbufframe,
      type
      },
    };
}
