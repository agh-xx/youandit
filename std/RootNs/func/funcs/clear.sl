define main (self)
{
  variable
    i,
    ans,
    buf = CW.buffers[CW.cur.frame];
 
  if (qualifier_exists ("messages"))
    writefile ([""], CW.msgbuf);
  else
    if ("Shell_Type" == CW.type || qualifier_exists ("dont_ask"))
      {
      writefile ([" "], buf.fname);
      CW.drawframe (CW.cur.frame);
      _for i (0, length (IMG) - 1)
        IMG[i].str = NULL;
      }
    else
      {
      ans = root.lib.ask (["do you want to clear the screen?", "[y/n/escape to abort]"],
        ['y', 'n'];header = "QUESTION FROM CLEAR FUNCTION");

      if ('y' == ans)
        {
        writefile ([" "], buf.fname);
        CW.drawframe (CW.cur.frame);
        _for i (0, length (IMG) - 1)
          IMG[i].str = NULL;
        }
      }

  throw GotoPrompt;
}
