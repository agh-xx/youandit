define main ()
{
  variable
    name,
    self,
    index;

  ifnot (2 == _NARGS)
    {
    srv->send_msg ("wrong number of args, a window name is required", -1);
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;

    throw GotoPrompt;
    }

  name = ();
  self = CW;

  index = wherefirst (name == list_to_array (root.windnames));
  if (NULL == index)
    {
    srv->send_msg (sprintf ("%s: No such window", name), -1);
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;

    throw GotoPrompt;
    }

  CW = root.windows[name];
  IMG = CW.img;
  CW.drawwind (;;__qualifiers ());
 
  () = chdir (CW.dir);

  if (qualifier_exists ("dont_goto_prompt"))
    throw Break;

  throw GotoPrompt;
}
