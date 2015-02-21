define main (self)
{
  variable
    ans,
    buf = CW.buffers[CW.cur.frame];
 
  if (qualifier_exists ("messages"))
    writefile ([""], CW.msgbuf);
  else
    if ("Shell_Type" == CW.type)
      {
      writefile ([" "], buf.fname);
      CW.drawframe (CW.cur.frame);
      }
    else
      {
      ans = root.lib.ask (["do you want to clear the screen?", "[y/n/escape to abort]"],
        ['y', 'n'];header = "QUESTION FROM CLEAR FUNCTION");

      if ('y' == ans)
        {
        writefile ([" "], buf.fname);
        CW.drawframe (CW.cur.frame);
        }
      }

  throw GotoPrompt;
}
