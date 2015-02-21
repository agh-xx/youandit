define main ()
{
  variable retval = proc->edVi (sprintf ("%s/about_me/me.abt", DATASHAREDIR));
  % CODE SHOULD CHANGE
  %variable
  %  f = FTYPES["abt"],
  %  init = f.init (f._type_);

  %init._fname_ = sprintf ("%s/about_me/about.abt", DATADIR);
  %init._in = init._fname_ + ".json";

  %if (NULL == init.parse (init._fname_, init._fname_ + ".json"))
  %  {
  %  srv->send_msg (init.msg, -1);
  %  throw Return, "", -1;
  %  }

  %init.pager ();
  CW.drawwind ();
  throw GotoPrompt;
}
