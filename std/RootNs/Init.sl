private variable gotoprompt = 0;

private define failed_rout (err_type)
{
  gotoprompt = 1;

  variable
    err = exception_to_array (),
    failed_wind = CW.name,
    buffer = CW.buffers[CW.cur.frame],
    buffname = buffer.fname,
    st = stat_file (buffname);

  writefile ([sprintf ("ERROR IN WINDOW %s", failed_wind), err_type,
    repeat ("_", COLUMNS), err], root.windows[mytypename].msgbuf;mode = "a");
 
  ifnot (NULL == st)
    () = utime (buffname, st.st_atime, _time ());
 
  try
    CW.drawwind ();
  catch AnyError:
    {
    CW = root.windows[mytypename];
    CW.drawwind (;"refresh");
    }
}

private define exec ()
{
  variable
    ref,
    argv = _NARGS > 2 ? __pop_list (_NARGS - 2) : {},
    file = (),
    self = ();

  try
    {
    () = evalfile (file, "root");
    ref = __get_reference ("root->main");

    (@ref) (self, __push_list (argv);;__qualifiers ());
    }
  catch ParseError:
    failed_rout ("Parse Error");
  catch Return:
    return __get_exception_info.object;
  catch Break:{}
  catch GotoPrompt:
    gotoprompt = 1;
  catch AnyError:
    failed_rout ("Runtime Error");
  finally
    eval ("define main ();", "root");

  if (gotoprompt)
    {
    gotoprompt = 0;
    CW.gotoprompt ();
    }
}

private define call ()
{
  variable
    argv = _NARGS > 2 ? __pop_list (_NARGS - 2) : {},
    func = (),
    self = (),
    file = self.keys[func][0],
    qualifiers = struct {@self.keys[func][1], @__qualifiers};

  self.exec (file, __push_list (argv);;qualifiers);
}

private define topline (self)
{
  variable
    def = sprintf ("WIND: [%s], MODE: [%s], PID: [%d]",
        CW.name, CW.cur.mode, ROOT_PID),
    len = strlen (def),
    str = strftime ("[%a %d %b %I:%M:%S]"),
    spaces = COLUMNS - len - strlen (str);

  str = sprintf ("%s%s%s", def, spaces ? repeat (" ", spaces) : "", str);

  srv->write_str_at (str, COLOR.topline, TOPROW, 0);

  CW.img[TOPROW].col = 0;
  CW.img[TOPROW].clr = COLOR.topline;
  CW.img[TOPROW].str = str;
}

private define settermsize (self)
{
  variable
    retval,
    fp = popen ("stty size", "r");

  () = fgets (&retval, fp);

  () = pclose (fp);

  retval = strtok (retval);

  (LINES, COLUMNS) = integer (retval[0]), integer (retval[1]);

  AVAILABLE_LINES = LINES - 3;
  PROMPTROW = LINES - 2;
  MSGROW = LINES - 1;
}

private define addhistory (self)
{
  self.exec (sprintf ("%s/history/Init", path_dirname (__FILE__));;__qualifiers ());
}

private define addreadline (self)
{
  return self.exec (sprintf ("%s/readline/Init", path_dirname (__FILE__))
    ;;__qualifiers ());
}

private define addwind (self, name, type)
{
  variable
    types,
    retval,
    tmpdir,
    istype,
    datadir = qualifier ("datadir"),
    blacklist = ["ved"],
    typedir = qualifier ("typedir");

  if (NULL == typedir)
    {
    foreach ([STDTYPESDIR, USRTYPESDIR, PERSTYPESDIR])
      {
      typedir = ();
      types = listdir (typedir);
      istype = wherefirst (sprintf ("%s.slc", type) == types);
      ifnot (NULL == istype)
        break;
      }
    }
  else
    {
    types = listdir (typedir);
    istype = wherefirst (sprintf ("%s.slc", type) == types);
    }

  if (NULL == istype)
    {
    srv->send_msg_and_refresh (sprintf ("window type %s: doesn't exists", type), -1);
    return NULL;
    }

  if (any (name == blacklist))
    {
    srv->send_msg (sprintf ("%s: is reserved for internal use", name), -1);
    return NULL;
    }

  if ('_'  == name[0])
    {
    srv->send_msg (sprintf ("%s: cannot start with a dash", name), -1);
    return NULL;
    }

  if (length (root.windnames))
    if (any (name == list_to_array (root.windnames)))
      {
      srv->send_msg (sprintf ("window %s: already exists", name), -1);
      return NULL;
      }

  tmpdir = sprintf ("%s/%s", TEMPDIR, name);

  if (-1 == access (tmpdir, F_OK))
    {
    if (-1 == mkdir (tmpdir))
      {
      srv->send_msg (sprintf ("Cannot create application directory %s, ERRNO: %s",
        tmpdir, errno_string (errno)), -1);
      return NULL;
      }
    }
  else
    ifnot (isdirectory (tmpdir))
      {
      srv->send_msg (sprintf ("%s: is not a directory", tmpdir), -1);
      return NULL;
      }
    else
      if (-1 == access (tmpdir, R_OK|W_OK))
        {
        srv->send_msg (sprintf ("%s: You dont't have the required permissions", tmpdir), -1);
        return NULL;
        }
 
  ifnot (NULL == datadir)
    if (-1 == access (datadir, F_OK))
      if (-1 == mkdir (datadir))
        {
        srv->send_msg_and_refresh (sprintf ("Inited %s Failed: cannot create datadir: %s",
          type, datadir), -1);
        return NULL;
        }

  root.windows[name] = self.exec (sprintf ("%s/wind/Init", path_dirname (__FILE__)),
    name, type;;__qualifiers ());
 
  retval = self.exec (sprintf ("%s/%s", typedir, types[istype]), name;;__qualifiers ());
 
  if (NULL == retval)
    assoc_delete_key (root.windows, name);
  else
    {
    writefile (qualifier ("msgarray",
      [sprintf ("%s window messages", name), repeat ("_", COLUMNS)]),
      root.windows[name].msgbuf);

    list_append (root.windnames, name);
    }
  
  IMG = root.windows[name].img;

  return retval;
}

define init ()
{
  variable self = struct
    {
    app,
    lib,
    func,
    user,
    wrappers,
    exec = &exec,
    call = &call,
    topline = &topline,
    settermsize = &settermsize,
    addwind = &addwind,
    addhistory = &addhistory,
    addreadline = &addreadline,
    windows = Assoc_Type[Struct_Type],
    windnames = {}
    };
 
  self.lib =self.exec (sprintf ("%s/lib/Init", path_dirname (__FILE__)));
  self.func = self.exec (sprintf ("%s/func/Init", path_dirname (__FILE__)));

  self.settermsize ();
  
  if (NULL == listdir ("/proc/acpi/battery/")
    && (NULL == listdir ("/sys/class/power_supply") ||
     0 == length(listdir ("/sys/class/power_supply"))))
    keys->cmap.battery = NULL;

  if (DEBUG)
    self.exec (sprintf ("%s/Init_dbg", path_dirname (__FILE__)));

  return self;
}

