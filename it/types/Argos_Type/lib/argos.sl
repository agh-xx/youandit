private variable
  mydir = path_dirname (__FILE__),
  myname = path_basename_sans_extname (__FILE__);

  () = evalfile (sprintf ("%s/fetch", mydir), myname);
  () = evalfile (sprintf ("%s/extract", mydir), myname);

define build ()
{
}

define install ()
{

}

define main ()
{
  variable
    func = NULL,
    args = {},
    retval,
    i,
    ia,
    c = cmdopt_new ();

  c.add ("func", &func;type = "string");

  i = c.process (__argv, 1);
 
 
  _for ia (i, __argc - 1)
    list_append (args, __argv[ia]);

  func = __get_reference (sprintf ("%s->%s", myname, func));
 
  retval =  (@func) (__push_list (args));

  return retval;
}
