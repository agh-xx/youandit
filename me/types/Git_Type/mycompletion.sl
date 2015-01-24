define main (self, retval, command)
{
  variable
    ar,
    cur,
    fmt,
    start;

  if (any (["branchchange", "branchdelete", "merge"] == command))
    {
    cur = CW.cur.branch;
    ar = CW.cur.branches[wherenot (cur == CW.cur.branches)];
    ifnot (length (ar))
      {
      srv->send_msg ("There is only one branch", -1);
      self.cur.argv[0] = "";
      self.cur.col = 1;
      self.parse_args ();
      self.my_prompt ();
      throw Return, " ", 1;
      }
 
    fmt = sprintf ("%%-%ds void git branch", max (strlen (ar)));
    ar = array_map (String_Type, &sprintf, fmt, ar);
    @retval = self.argcompletion (;file = NULL,
       args = ar, arg = length (self.cur.argv) < 2 ? "." : self.cur.argv[-1],
       base = length (self.cur.argv) < 2 ? self.cur.line[[:-2]] : strjoin (self.cur.argv[[:-2]], " "));
    throw Return, " ", 0;
    }

  if (any (["reposet", "rmrepofromdb"] == command))
    {
    ar = CW.repos;
    fmt = sprintf ("%%-%ds void git available repository", max (strlen (ar)));
    ar = array_map (String_Type, &sprintf, fmt, ar);

    @retval = self.argcompletion (;args = ar, arg = "/", base = self.cur.line[[:-2]]);
    throw Return, " ", 0;
    }

  if ("add" == command)
    {
    start = ' ' == self.cur.line[-1]
      ? NULL == CW.cur.repo
        ? " "
        : CW.cur.repo
      : length (self.cur.argv) > 1
        ? self.cur.argv[-1]
        : CW.cur.repo;
 
    if (1 < length (self.cur.argv))
      {
      self.cur.argv[1] = NULL == start ? " " : start;
      self.cur.col = 5 + strlen (self.cur.argv[1]);
      self.parse_args ();
      self.my_prompt ();
      }

    @retval = self.filenamecompletion (start);
    throw Return, " ", 0;
    }
 
  @retval = 0;
  throw Return, " ", 0;
}
