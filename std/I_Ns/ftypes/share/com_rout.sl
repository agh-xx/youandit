private define delete_at (s)
{
  variable
    i,
    arglen,
    len = 0;

  ifnot (qualifier_exists ("is_delete"))
    s.c_._col--;
 
  _for i (0, s.c_._ind)
    {
    arglen = strlen (s.c_.argv[i]);
    len += arglen + 1;
    }
 
  len = s.c_._col - (len - arglen);

  if (0 > len)
    {
    if (arglen)
      s.c_.argv[i-1] += s.c_.argv[i];
 
    s.c_.argv[i] = NULL;
    s.c_.argv = s.c_.argv[wherenot (_isnull (s.c_.argv))];
    }
  else
    ifnot (len)
      s.c_.argv[i] = substr (s.c_.argv[i], 2, -1);
    else
      if (len + 1 == arglen)
        s.c_.argv[i] = substr (s.c_.argv[i], 1, len);
      else
        s.c_.argv[i] = substr (s.c_.argv[i], 1, len) +
          substr (s.c_.argv[i], len + 2, -1);
}

rl_.delete_at = &delete_at;

private define routine (s)
{
  if (any (keys->rmap.backspace == s.c_._chr))
    {
    if (s.c_._col > 1)
      s.delete_at ();
 
    return;
    }

  if (any (keys->rmap.left == s.c_._chr))
    {
    if (s.c_._col > 1)
      {
      s.c_._col--;
      srv->gotorc_draw (s.c_._row, s.c_._col);
      }

    return;
    }

  if (any (keys->rmap.right == s.c_._chr))
    {
    if (s.c_._col < strlen (s.c_._lin))
      {
      s.c_._col++;
      srv->gotorc_draw (s.c_._row, s.c_._col);
      }

    return;
    }

  if (any (keys->rmap.home == s.c_._chr))
    {
    s.c_._col = 1;
    srv->gotorc_draw (s.c_._row, s.c_._col);

    return;
    }

  if (any (keys->rmap.end == s.c_._chr))
    {
    s.c_._col = strlen (s.c_._lin);
    srv->gotorc_draw (s.c_._row, s.c_._col);

    return;
    }

  if (any (keys->rmap.delete == s.c_._chr))
    {
    if (s.c_._col <= strlen (s.c_._lin))
      ifnot (s.c_._col == strlen (strjoin (s.c_.argv[[:s.c_._ind]], " ")) + 1)
        s.delete_at (;is_delete);
      else
        if (s.c_._ind < length (s.c_.argv) - 1)
          {
          s.c_.argv[s.c_._ind] += s.c_.argv[s.c_._ind+1];
          s.c_.argv[s.c_._ind+1] = NULL;
          s.c_.argv = s.c_.argv[wherenot (_isnull (s.c_.argv))];
          }

    return;
    }

  if (' ' == s.c_._chr)
    {
    if (qualifier_exists ("insert_ws"))
      {
      s.insert_at ();
      return;
      }

    ifnot (s.c_._ind)
      {
      if (1 == s.c_._col)
        if (qualifier_exists ("accept_ws"))
          {
          s.insert_at ();
          return;
          }
        else
          return;
 
      ifnot (length (s.c_.argv) - 1)
        s.c_.argv = [
          substr (s.c_.argv[0], 1, s.c_._col - 1),
          substr (s.c_.argv[0], s.c_._col, -1)];
      else
        s.c_.argv = [
          substr (s.c_.argv[0], 1, s.c_._col - 1),
          substr (s.c_.argv[0], s.c_._col, -1),
          s.c_.argv[[1:]]];

      s.c_._col++;
      return;
      }

    if (' ' == srv->char_at ())
      {
      if (s.c_._ind == length (s.c_.argv) - 1)
        (s.c_.argv = [s.c_.argv, ""], s.c_._col++);
      else if (strlen (strjoin (s.c_.argv[[:s.c_._ind]], " ")) == s.c_._col - 1)
        (s.c_.argv = [s.c_.argv[[:s.c_._ind]], "", s.c_.argv[[s.c_._ind + 1:]]],
        s.c_._col++);
      else
        s.insert_at ();

      return;
      }
    }

  if (' ' < s.c_._chr <= 126 || 902 <= s.c_._chr <= 974)
    s.insert_at ();
}

rl_.rout = &routine;

private define insert_at (s)
{
  variable
    i,
    arglen,
    len = 0,
    chr = char (qualifier ("chr", s.c_._chr));

  s.c_._col++;

  _for i (0, s.c_._ind)
    {
    arglen = strlen (s.c_.argv[i]);
    len += arglen + 1;
    }

  len = s.c_._col - (len - arglen);

  if (s.c_._col == len)
    s.c_.argv[i] += chr;
  else
    ifnot (len)
      if (i > 0)
        s.c_.argv[i-1] += chr;
      else
        s.c_.argv[i] = chr + s.c_.argv[i];
    else
      s.c_.argv[i] = sprintf ("%s%s%s", substr (s.c_.argv[i], 1, len - 1), chr,
        substr (s.c_.argv[i], len, -1));
}

rl_.insert_at = &insert_at;
