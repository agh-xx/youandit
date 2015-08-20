define main (self)
{
  ifnot (access (CW.msgbuf, F_OK))
    ved (CW.msgbuf;drawwind);
  else
    srv->send_msg ("NO MESSAGES", 0);

  throw GotoPrompt;
}
