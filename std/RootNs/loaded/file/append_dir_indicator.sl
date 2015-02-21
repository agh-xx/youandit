define main (ns, dons)
{
  variable
    file = sprintf ("%s/%s/", path_dirname (__FILE__),
      path_basename_sans_extname (__FILE__));

  variable
    modify_ar = qualifier ("modify_ar", 0);

  ifnot (modify_ar)
    file += "dontmodifyar.slc";
 
  if (dons)
    () = evalfile (file, ns);
  else
    () = evalfile (file);
}
