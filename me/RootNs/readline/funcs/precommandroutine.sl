define main (self, command, retval, init)%retval is a pointer and commandroutine takes a pointer
{
  ifnot (NULL != command)
    throw Return, " ", 0;

  ifnot (any (command ==
    ["bgkillpid", "windownew", "windownewdontfocus", "windowgoto", "windowdelete"]))
    throw Return, " ", 0;
 
  @init = 1;

  ifnot (length (self.cur.argv) - 1)
    throw Return, " ", 1;

  throw Return, " ", self.commandroutine (command, retval);
}
