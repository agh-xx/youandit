private variable LOADED = Assoc_Type[Integer_Type, 0];

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

  try
    {
    () = evalfile (file, ns);
    }
  catch OpenError:
    throw ParseError, sprintf ("%s: couldn't be found", file);
  catch ParseError:
    throw ParseError, sprintf ("file %s: %s func: %s lnr: %d", path_basename (file),
      __get_exception_info.message, __get_exception_info.function,
      __get_exception_info.line);
 
  LOADED[sprintf ("%s.%s", ns, file)] = 1;
}
