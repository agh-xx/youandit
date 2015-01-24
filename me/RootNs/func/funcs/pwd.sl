define main (self)
{
  srv->send_msg (sprintf ("current directory is: %s", getcwd ()), 0);
  throw GotoPrompt;
}
