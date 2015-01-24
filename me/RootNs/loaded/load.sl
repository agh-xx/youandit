define load (ns, function, dons)
{
  variable
    orig_ns = ns;

  ns = sprintf ("%s/%s", path_dirname (__FILE__), ns);

  if (access (ns, F_OK))
    return [sprintf ("(load) %s: no such namespace", orig_ns)], -1;
 
  function = sprintf ("%s/%s.slc", ns, function);
  if (access (function, F_OK))
    return
       [sprintf ("(load) %s: no such function", path_basename_sans_extname (function))], -1;

  try
    {
    () = evalfile (function, "load");
    variable main = __get_reference ("load->main");
 
    if (NULL == main)
      return [sprintf
        ("(load) %s: no main function", path_basename_sans_extname (function))], -1;

    (@main) (orig_ns, dons;;__qualifiers ());
    }
  catch ParseError:
    return
    [sprintf ("(load) %s: ParseError", path_basename_sans_extname (function)),
      exception_to_array ()], -1;
  finally:
    eval ("define main ();", "load");
 
  return 0;
}
