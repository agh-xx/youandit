define main (self)
{
  if (2 == length (root.windnames) && CW.name != "root")
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
 
  cur = 0 == cur ? len : cur - 1;
 
  name = windnames[cur];
 
  while (name == "root")
    {
    cur = cur == 0 ? len : cur - 1;
    name = windnames[cur];
    }

  CW = root.windows[name];

  CW.drawwind ();

  () = chdir (CW.dir);

  if (qualifier_exists ("dont_goto_prompt"))
    throw Break;

  throw GotoPrompt;
}
