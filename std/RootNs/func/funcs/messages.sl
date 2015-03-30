define main (self)
{
  ifnot (access (CW.msgbuf, F_OK))
    (@CW.gotopager) (CW, CW.msgbuf);
  else
    srv->send_msg ("NO MESSAGES", 0);

  throw GotoPrompt;
}
