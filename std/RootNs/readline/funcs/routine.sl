define main (self)
{
  if (any (keys->cmap.backspace == self.cur.chr))
    {
    if (self.cur.col > 1)
      self.delete_at ();
 
    throw Break;
    }

  if (any (keys->cmap.left == self.cur.chr))
    {
    if (self.cur.col > 1)
      self.cur.col--;

    throw Break;
    }

  if (any (keys->cmap.right == self.cur.chr))
    {
    if (self.cur.col <= strlen (self.cur.line))
      self.cur.col++;

    throw Break;
    }

  if (any (keys->cmap.home == self.cur.chr))
    {
    self.cur.col = 1;

    throw Break;
    }

  if (any (keys->cmap.end == self.cur.chr))
    {
    self.cur.col = strlen (self.cur.line) + 1;

    throw Break;
    }

  if (any (keys->cmap.delete == self.cur.chr))
    {
    if (self.cur.col <= strlen (self.cur.line))
      ifnot (self.cur.col == strlen (strjoin (self.cur.argv[[:self.cur.index]], " ")) + 1)
        self.delete_at (;is_delete);
      else
        if (self.cur.index < length (self.cur.argv) - 1)
          {
          self.cur.argv[self.cur.index] += self.cur.argv[self.cur.index+1];
          self.cur.argv[self.cur.index+1] = NULL;
          self.cur.argv = self.cur.argv[wherenot (_isnull (self.cur.argv))];
          }

    throw Break;
    }

  variable
    len,
    col;

  if (any ([keys->cmap.delword] == self.cur.chr))
    {
    ifnot (self.cur.index)
      col = self.cur.col;
    else
      {
      len = strlen (strjoin (self.cur.argv[[:self.cur.index - 1]], " "));
      col = self.cur.col - len - 1;
      }

    ifnot (self.cur.index)
      {
      if (1 == length (self.cur.argv) && 0 == strlen (self.cur.argv[0]))
          throw Break;

      self.cur.argv[0] = substr (self.cur.argv[0], col, -1);
      self.cur.col = 1;
      }
    else
      {
      len = strlen (strjoin (self.cur.argv[[:self.cur.index - 1]], " "));
      col = self.cur.col - len - 1;

      self.cur.col = len + 1;

      if (length (self.cur.argv) == self.cur.index + 1)
        {
        self.cur.argv = [self.cur.argv[[:self.cur.index - 1]],
          substr (self.cur.argv[self.cur.index], col, -1)];
        }
      else
        {
        self.cur.argv = [self.cur.argv[[:self.cur.index - 1]],
          substr (self.cur.argv[self.cur.index], col, -1),
          self.cur.argv[[self.cur.index + 1:]]];
        }
      }

    throw Break;
    }

  if (any ([keys->cmap.deltoend] == self.cur.chr))
    {
    if (1 == length (self.cur.argv) && 0 == strlen (self.cur.argv[0]))
      throw Break;
 
    ifnot (self.cur.index)
      col = self.cur.col;
    else
      {
      len = strlen (strjoin (self.cur.argv[[:self.cur.index - 1]], " "));
      col = self.cur.col - len - 1;
      }

    self.cur.argv[self.cur.index] = substr (self.cur.argv[self.cur.index], 1, col - 1);
    self.cur.argv = self.cur.argv[[:self.cur.index]];
    throw Break;
    }

 
  if (' ' == self.cur.chr)
    {
    if (qualifier_exists ("insert_ws"))
      {
      self.insert_at ();
      throw Break;
      }

    ifnot (self.cur.index)
      {
      if (1 == self.cur.col)
        if (qualifier_exists ("accept_ws"))
          {
          self.insert_at ();
          throw Break;
          }
        else
          throw Break;
 
      ifnot (length (self.cur.argv) - 1)
        self.cur.argv = [
          substr (self.cur.argv[0], 1, self.cur.col - 1),
          substr (self.cur.argv[0], self.cur.col, -1)];
      else
        self.cur.argv = [
          substr (self.cur.argv[0], 1, self.cur.col - 1),
          substr (self.cur.argv[0], self.cur.col, -1),
          self.cur.argv[[1:]]];

      self.cur.col ++;
      throw Break;
      }

    if (' ' == srv->char_at () && '-' != self.cur.argv[self.cur.index][0])
      {
      if (self.cur.index == length (self.cur.argv) - 1)
        (self.cur.argv = [self.cur.argv, ""], self.cur.col ++);
      else if (strlen (strjoin (self.cur.argv[[:self.cur.index]], " ")) == self.cur.col - 1)
        (self.cur.argv = [self.cur.argv[[:self.cur.index]], "", self.cur.argv[[self.cur.index+1:]]],
        self.cur.col ++);
      else
        self.insert_at ();
      }
    else
      {
      len = strlen (strjoin (self.cur.argv[[:self.cur.index - 1]], " "));
      col = self.cur.col - len - 1;

      % make a function for getting pattern, which the next condition is all about,
      % also get filename, so this could be solved if the arg type is pat|fname
      % for now disallow space
      if ('-' == self.cur.argv[self.cur.index][0])
        {
        if (self.cur.index == length (self.cur.argv) - 1)
          self.cur.argv = [
          self.cur.argv[[:self.cur.index - 1]],
          substr (self.cur.argv[self.cur.index], 1, col - 1),
          substr (self.cur.argv[self.cur.index], col, -1)];
        else
          self.cur.argv = [
          self.cur.argv[[:self.cur.index - 1]],
          substr (self.cur.argv[self.cur.index], 1, col - 1),
          substr (self.cur.argv[self.cur.index], col, -1),
          self.cur.argv[[self.cur.index + 1:]]];
        }
      else
        {
        if (self.cur.index == length (self.cur.argv) - 1)
          self.cur.argv = [
          self.cur.argv[[:self.cur.index - 1]],
          substr (self.cur.argv[self.cur.index], 1, col - 1),
          substr (self.cur.argv[self.cur.index], col, -1)];
        else
          self.cur.argv = [
          self.cur.argv[[:self.cur.index - 1]],
          substr (self.cur.argv[self.cur.index], 1, col - 1),
          substr (self.cur.argv[self.cur.index], col, -1),
          self.cur.argv[[self.cur.index + 1:]]];
        }

      self.cur.col ++;
      throw Break;
      }
    }

  if (' ' < self.cur.chr <= 126 || 902 <= self.cur.chr <= 974)
    self.insert_at ();

  throw Break;
}
