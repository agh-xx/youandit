define main ()
{
  variable name, self;
  ifnot (2 == _NARGS)
    name = CW.name;
  else
    name = ();

  if (any ([mytypename, maintypename] == name))
    {
    srv->send_msg (sprintf ("You can't delete the %s window", name), -1);
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;
    throw GotoPrompt;
    }

  self = CW;

  variable index = wherefirst (name == list_to_array (root.windnames));
  if (NULL == index)
    {
    srv->send_msg (sprintf ("%s: no such window", name), -1);
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;
    throw GotoPrompt;
    }

  if (1 == length (root.windnames))
    {
    srv->send_msg ("There is only one Window", -1);
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;
    throw GotoPrompt;
    }

  ifnot (NULL == struct_field_exists (self, "atexit"))
    self.atexit ();
 
  self.history.write ();

  list_delete (root.windnames, index);
  assoc_delete_key (root.windows, name);

  srv->send_msg (sprintf ("%s: Window deleted", name), 0);

  if (self.name == name)
    name = 0 == index ? root.windnames[0] : root.windnames[index-1];
  else
    {
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;
    throw GotoPrompt;
    }

  root.func.call ("windowgoto", name;;__qualifiers ());
}
