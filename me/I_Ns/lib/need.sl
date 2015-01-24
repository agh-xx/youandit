private variable LOADED = Assoc_Type[Int_Type, 0];

private define lib_exists (lib)
{
  return wherefirst_eq  (
    array_map (Integer_Type, &access,
    array_map (String_Type, &sprintf, "%s/%s.slc", strchop (get_slang_load_path, ':', 0), lib),
    F_OK), 0);
}

define need ()
{
  variable
    file,
    ns = current_namespace ();

  if (1 == _NARGS)
    file = ();

  if (2 == _NARGS)
    (file, ns) = ();

  if (NULL == ns || "" == ns)
    ns = "Global";
  
  if (LOADED[sprintf ("%s.%s", ns, file)])
    return;

  if (NULL == lib_exists (file))
    throw ParseError,  sprintf ("%s: library doesn't exists in %s\n", file, get_slang_load_path ());

  try
    {
    () = evalfile (file, ns);
    }
  catch ParseError:
    throw ParseError, __get_exception_info.message;
  
  LOADED[sprintf ("%s.%s", ns, file)] = 1;
}
