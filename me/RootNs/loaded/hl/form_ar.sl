define main (ns, dons)
{
  variable
    file = sprintf ("%s/%s/", path_dirname (__FILE__),
      path_basename_sans_extname (__FILE__));

  variable
    barpointer = qualifier ("barpointer", 0);

  if (barpointer)
    file += "barpointer.slc";
 
  if (dons)
    () = evalfile (file, ns);
  else
    () = evalfile (file);
}
