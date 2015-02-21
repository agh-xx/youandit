define main ()
{
  root.topline ();
  srv->send_msg ("Please enter a valid expression", 0);
  srv->write_prompt (NULL, 1;prompt_char = ">");

  variable
    i,
    str,
    res,
    line,
    found,
    framelen = 10,
    session = String_Type[10],
    histfile = sprintf ("%s/data/%s/.history.txt", path_dirname (__FILE__),
      path_basename_sans_extname (__FILE__)),
    histar = -1 == access (histfile, F_OK) ? String_Type[0] : readfile (histfile);

  session[0] = "debug console";

  _for i (1, framelen - 1)
    session[i] = "";
 
  srv->clear_frame (framelen, PROMPTROW - framelen - 1, PROMPTROW - 1, COLOR.out, 0);
  srv->write_ar_at ([repeat ("_", COLUMNS), session], COLOR.out, [PROMPTROW - framelen - 1: PROMPTROW - 1], 0);
  srv->write_prompt (NULL, 1;prompt_char = ">");

  forever
    {
    line = (@CW.readline.getsingleline) (CW.readline;
      dont_draw, prompt_char = ">", histar = histar);
 
    ifnot (strlen (line))
      continue;
 
    CW.drawwind (;dont_reread);
    srv->clear_frame (framelen, PROMPTROW - framelen, PROMPTROW - 1, COLOR.out, 0);
    srv->write_ar_at ([repeat ("_", COLUMNS), session], COLOR.out, [PROMPTROW - framelen - 1: PROMPTROW - 1], 0);
    srv->refresh ();

    histar = [line, histar[wherenot (histar == line)]];

    if (line == "q")
      break;

    try
      {
      res = eval (line);

      str = (str = line + ":" + string (res), str + repeat (" ", COLUMNS - strlen (str)));

      found = 0;
      _for i (1, framelen - 1)
        ifnot (strlen (session[i]))
          {
          session[i] = str;
          found = 1;
          break;
          }

      ifnot (found)
        session = [session[[1:]], str];
      }
    catch AnyError:
      srv->send_msg ("Error in expression: " + __get_exception_info.message, -1);

    root.topline ();
 
    srv->clear_frame (framelen, PROMPTROW - framelen, PROMPTROW - 1, COLOR.out, 0);
    srv->write_ar_at ([repeat ("_", COLUMNS), session], COLOR.out, [PROMPTROW - framelen - 1: PROMPTROW - 1], 0);
    srv->write_prompt (NULL, 1;prompt_char = ">");
    }

  writefile (histar, histfile);
  writefile (histar, strreplace (histfile, BINDIR, SOURCEDIR));

  srv->send_msg ("", 0);
  srv->write_prompt (NULL, 1;);
  CW.drawwind ();
  throw GotoPrompt;
}
