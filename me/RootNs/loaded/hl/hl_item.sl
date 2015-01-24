define main (ns, dons)
{
  variable
    file = sprintf ("%s/%s/", path_dirname (__FILE__),
      path_basename_sans_extname (__FILE__));
 
  variable
    formar = qualifier ("form_ar", 1);
 
  if (formar)
    file += "formar";
  else
    file += "not_formar";

  if (dons)
    () = evalfile (file, ns);
  else
    () = evalfile (file);
}
