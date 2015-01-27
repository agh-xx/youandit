private variable
  FTYPES = Assoc_Type[Struct_Type],
  WRITE_ON_EXECUTIONS = 20,
  Funcs = Assoc_Type[Array_Type],
  executions = 0,
  gotoprompt = 0;

private define profile_func (func, tim)
{
  ifnot (assoc_key_exists (Funcs, func))
    Funcs[func] = [1.0, tim, tim];
  else
    {
    Funcs[func][0]++;
    Funcs[func][1] += tim;
    Funcs[func][2] = tim;
    }
 
  variable profile_fp;

  ifnot (executions mod WRITE_ON_EXECUTIONS)
    {
    variable
      i,
      keys = assoc_get_keys (Funcs),
      sorted = array_sort (keys),
      vals = assoc_get_values (Funcs)[sorted];

    keys = keys[sorted];
 
    profile_fp = fopen (sprintf ("%s/_profile/Profile.txt", TMPDIR), "w");

    _for i (0, length (keys) - 1)
      () = fprintf (profile_fp, "%17s | %d | %-8.6f | %f\n",
        path_basename_sans_extname (keys[i]), int (Funcs[keys[i]][0]), Funcs[keys[i]][1], Funcs[keys[i]][2]);

    () = fclose (profile_fp);
    }
}

private define failed_rout (err_type)
{
  gotoprompt = 1;
  variable failed_wind = CW.name;

  CW = root.windows[mytypename];
  
  root.lib.printtostdout ([err_type, exception_to_array ()]);
  
  writefile ([sprintf ("ERROR IN WINDOW %s", failed_wind), err_type,
    repeat ("_", COLUMNS), exception_to_array ()], CW.msgbuf;mode = "a");
  
  CW.drawwind ();
}

private define exec ()
{
  variable
    ref,
    failed,
    argv = _NARGS > 2 ? __pop_list (_NARGS - 2) : {},
    file = (),
    self = (),
    func = path_basename (file);

  tic ();

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
    {
    executions ++;
    profile_func (path_basename (file), toc ());
    eval ("define main ();", "root");
    }

  if (gotoprompt)
    {
    gotoprompt = 0;
    CW.gotoprompt ();
    }
}

define main (self)
{
  self.exec = &exec;
}
