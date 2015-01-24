define main (self)
{
  if (2 == length (root.windnames) && CW.name != mytypename)
    {
    srv->send_msg ("There is only one window", -1);
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;
    throw GotoPrompt;
    }

  variable
    name,
    windnames = list_to_array (root.windnames),
    len = length (windnames) - 1,
    cur = wherefirst (CW.name == windnames);
 
  cur = cur == len ? 0 : cur + 1;
 
  name = windnames[cur];
 
  while (name == mytypename)
    {
    cur = cur == len ? 0 : cur + 1;
    name = windnames[cur];
    }

  CW = root.windows[name];

  CW.drawwind ();

  () = chdir (CW.dir);

  if (qualifier_exists ("dont_goto_prompt"))
    throw Break;

  throw GotoPrompt;
}
