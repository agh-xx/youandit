private variable Features;

ifnot (__is_initialized (&Features))
  Features = Assoc_Type[Int_Type, 0];

private define pop_feature_namespace (nargs)
{
  variable
    f,
    ns = current_namespace ();
   
  if (nargs == 2)
    ns = ();

  f = ();

  if ((ns == NULL) or (ns == ""))
    ns = "Global";

  return strcat (ns, ".", f);
}

define _featurep ()
{
  variable f = pop_feature_namespace (_NARGS);
  return Features[f];
}

define provide ()
{
   variable f = pop_feature_namespace (_NARGS);
   Features[f] = 1;
}

define require ()
{
  variable
   feat = NULL,
   file,
   ns = current_namespace ();

  switch (_NARGS)
   {
   case 1:
	 feat = ();
	 file = feat;
   }

   {
   case 2:
	 (feat, ns) = ();
	 file = feat;
   }

   {
   case 3:
	 (feat, ns, file) = ();
   }
  
  if (NULL == feat)
    return;

  if (_featurep (feat, ns))
    return;

  if (ns == NULL)
    () = evalfile (file);
  else
    () = evalfile (file, ns);

  if (feat == file)
    provide (file, ns);
  else if (_featurep (feat, ns))
    (@print_err) (sprintf ("feature %s not provided by %s", feat, file));
}
