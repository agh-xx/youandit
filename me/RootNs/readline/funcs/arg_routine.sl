define main (self, retval, command)
{

  ifnot (NULL == command)
    {
    variable arg = strchop (self.cur.argv[self.cur.index], '=', 0);
 
    if (any (assoc_get_keys (root.user.keys) == command) && command != "cd")
      ifnot (NULL == root.user.keys[command][3])
        {
        if (1 < length (arg))
          @retval = self.argcompletion (;arg = arg[0], pat = strjoin (arg[[1:]]),
            file = NULL, args = root.user.keys[command][3]);
        else
          @retval = self.argcompletion (;file = NULL, args = root.user.keys[command][3]);

        self.cur.mode = "user";

        throw Return, " ", 0;
        }

    if (any (assoc_get_keys (root.wrappers.keys) == command))
      ifnot (NULL == root.wrappers.keys[command][3])
        {
        if (1 < length (arg))
          @retval = self.argcompletion (;arg = arg[0], pat = strjoin (arg[[1:]]),
            file = NULL, args = root.wrappers.keys[command][3]);
        else
          @retval = self.argcompletion (;file = NULL, args = root.wrappers.keys[command][3]);

        self.cur.mode = "wrappers";

        throw Return, " ", 0;
        }
 
    if (1 < length (arg))
      @retval = self.argcompletion (;arg = arg[0], pat = strjoin (arg[[1:]]));
    else
      @retval = self.argcompletion ();

    throw Return, " ", 0;
    }

  throw Return, " ", 0;
}
