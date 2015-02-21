define main (self)
{
  ifnot (access (CW.msgbuf, F_OK))
    (@CW.gotopager) (CW;;struct {@__qualifiers, iamreal, file = CW.msgbuf});
  else
    srv->send_msg ("NO MESSAGES", 0);

  throw GotoPrompt;
}
