typedef struct
  {
  chr,
  lnr,
  prev_l,
  next_l,
  modified,
  } Insert_Type;

variable insfuncs = struct
  {
  cr,
  esc,
  bol,
  eol,
  up,
  left,
  down,
  right,
  del_prev,
  del_next,
  ins_char,
  completeline,
  };

define insert ();

private define ins_char (s, line)
{
  @line = substr (@line, 1, cf_._index) + char (s.chr) +  substr (@line, cf_._index + 1, - 1);

  cf_._index++;

  s.modified = 1;

  if (strlen (@line) < cf_._maxlen || cf_.ptr[1] < cf_._maxlen)
    {
    cf_.ptr[1]++;
    s_.write_nstr (@line, 0, cf_.ptr[0]);
    draw_tail (;chr = s.chr);
    return;
    }

  is_wrapped_line = 1;
  cf_._findex++;

  variable
    lline,
    len = strlen (@line);

  if (cf_.ptr[1] == cf_._maxlen)
    {
    lline = substr (@line, cf_._findex + 1, -1);
    s_.write_nstr (lline, 0, cf_.ptr[0]);
    draw_tail (;chr = s.chr);
    return;
    }
 
  lline = substr (@line, cf_._findex + 1, -1);
  s_.write_str_at (lline, 0, cf_.ptr[0], cf_.ptr[1]);

  cf_.ptr[1]++;
  draw_tail (;chr = s.chr);
}

insfuncs.ins_char = &ins_char;

private define del_prev (s, line)
{
  variable
    lline,
    len;

  ifnot (cf_._index - cf_._indent)
    {
    ifnot (s.lnr)
      return;

   if (cf_.ptr[0] != cf_.rows[0])
     cf_.ptr[0]--;
   else
     cf_._ii--;

    s.lnr--;

    cf_._index = strlen (cf_.lines[s.lnr]);
    cf_.ptr[1] = cf_._index > cf_._maxlen ? cf_._maxlen : cf_._index;

    if (s.lnr == cf_._len)
      @line = cf_.lines[s.lnr];
    else
      @line = cf_.lines[s.lnr] + @line;
 
    cf_.lines[s.lnr] = @line;
    cf_.lines[s.lnr + 1] = NULL;
    cf_.lines = cf_.lines[wherenot (_isnull (cf_.lines))];
    cf_._len--;

    cf_._i = cf_._ii;

    s_.draw ();

    len = strlen (@line);
    if (len > cf_._maxlen)
      {
      cf_._findex = len - cf_._maxlen;
      cf_.ptr[1] = cf_._maxlen - (len - cf_._index);
      is_wrapped_line = 1;
      }
    else
      cf_._findex = cf_._indent;

    lline = substr (@line, cf_._findex + 1, cf_._maxlen);

    s_.write_nstr (lline, 0, cf_.ptr[0]);
    draw_tail (;chr = decode (substr (@line, cf_._index + 1, 1))[0]);
    s.modified = 1;
    return;
    }

  @line = substr (@line, 1, cf_._index - 1) + substr (@line, cf_._index + 1, - 1);

  len = strlen (@line);
 
  cf_._index--;

  ifnot (cf_.ptr[1])
    {
    if (cf_._index > cf_._maxlen)
      {
      cf_.ptr[1] = cf_._maxlen;
      cf_._findex = len - cf_._maxlen;
      lline = substr (@line, cf_._findex + 1, -1);
      s_.write_nstr (lline, 0, cf_.ptr[0]);
      draw_tail (;chr = decode (substr (@line, cf_._index, 1))[0]);
      return;
      }

    cf_._findex = cf_._indent;
    cf_.ptr[1] = len;
    s_.write_nstr (@line, 0, cf_.ptr[0]);
    draw_tail (;chr = decode (substr (@line, cf_._index, 1))[0]);
    is_wrapped_line = 0;
    return;
    }

  cf_.ptr[1]--;

  if (cf_._index == len)
    s_.write_str_at (" ", 0, cf_.ptr[0], cf_.ptr[1]);
  else
    {
    lline = substr (@line, cf_._index + 1, -1);
    s_.write_str_at (lline, 0, cf_.ptr[0], cf_.ptr[1]);
    }

  draw_tail (;chr = decode (substr (@line, cf_._index, 1))[0]);

  s.modified = 1;
}

insfuncs.del_prev = &del_prev;

private define del_next (s, line)
{
  ifnot (cf_._index - cf_._indent)
    if (1 == strlen (@line))
      if (" " == @line)
        {
        if (s.lnr < cf_._len)
          {
          @line += cf_.lines[s.lnr + 1];
          cf_.lines[s.lnr + 1 ] = NULL;
          cf_.lines = cf_.lines[wherenot (_isnull (cf_.lines))];
          cf_._len--;
          cf_._i = cf_._ii;
          s_.draw ();
          s.modified = 1;
          s_.write_nstr (@line, 0, cf_.ptr[0]);
          draw_tail (;chr = decode (substr (@line, cf_._index + 1, 1))[0]);
          }

        return;
        }
      else
        {
        @line = " ";
        s_.write_nstr (@line, 0, cf_.ptr[0]);
        draw_tail (;chr = decode (substr (@line, cf_._index + 1, 1))[0]);
        s.modified = 1;
        return;
        }

  if (cf_._index == strlen (@line))
    {
    if (s.lnr < cf_._len)
      {
      @line += cf_.lines[s.lnr + 1];
      cf_.lines[s.lnr + 1 ] = NULL;
      cf_.lines = cf_.lines[wherenot (_isnull (cf_.lines))];
      cf_._len--;
      cf_._i = cf_._ii;
      s_.draw ();
      s.modified = 1;
      if (is_wrapped_line)
        s_.write_nstr (substr (@line, cf_._findex + 1, -1), 0, cf_.ptr[0]);
      else
        s_.write_nstr (@line, 0, cf_.ptr[0]);
      draw_tail (;chr = decode (substr (@line, cf_._index + 1, 1))[0]);
      }

    return;
    }

  @line = substr (@line, 1, cf_._index) + substr (@line, cf_._index + 2, - 1);

  if (is_wrapped_line)
    s_.write_nstr (substr (@line, cf_._findex + 1, -1), 0, cf_.ptr[0]);
  else
    s_.write_nstr (@line, 0, cf_.ptr[0]);
 
  s_.write_nstr (@line, 0, cf_.ptr[0]);
  draw_tail (;chr = decode (substr (@line, cf_._index + 1, 1))[0]);
  s.modified = 1;
}

insfuncs.del_next = &del_next;

private define eol (s, line)
{
  variable
    lline,
    len = strlen (@line);
 
  cf_._index = len;

  if (len > cf_._maxlen)
    {
    cf_._findex = len - cf_._maxlen;
    lline = substr (@line, cf_._findex + 1, -1);
 
    s_.write_nstr (lline, 0, cf_.ptr[0]);

    cf_.ptr[1] = cf_._maxlen;
    is_wrapped_line = 1;
    }
  else
    cf_.ptr[1] = len;

  draw_tail (;chr = decode (substr (@line, cf_._index + 1, 1))[0]);
}

insfuncs.eol = &eol;

private define bol (s, line)
{
  cf_._findex = cf_._indent;
  cf_._index = cf_._indent;
  cf_.ptr[1] = cf_._indent;
  s_.write_nstr (@line, 0, cf_.ptr[0]);
  draw_tail (;chr = decode (substr (@line, cf_._index + 1, 1))[0]);
  is_wrapped_line = 0;
}

insfuncs.bol = &bol;

private define completeline (s, line, comp_line)
{
  if (is_wrapped_line)
    return;

  if (cf_._index < strlen (comp_line) - cf_._indent)
    {
    @line = substr (@line, 1, cf_._index + 1) +
      substr (comp_line, cf_._index + 2 + cf_._indent, 1) +
      substr (@line, cf_._index + 2, - 1);

    cf_._index++;

    if (cf_.ptr[1] + 1 < cf_._maxlen)
      cf_.ptr[1]++;

    draw_tail (;chr = decode (substr (@line, cf_._index + 1, 1))[0]);
    s.modified = 1;
    }
}

insfuncs.completeline = &completeline;

private define right (s, line)
{
  variable len = strlen (@line);

  if (cf_._index + 1 > len || 0 == len)
    return;

  cf_._index++;
 
  ifnot (cf_.ptr[1] == cf_._maxlen)
    cf_.ptr[1]++;
 
  if (cf_._index + 1 > cf_._maxlen)
    {
    cf_._findex++;
    is_wrapped_line = 1;
    }
 
  variable lline;

  if (cf_.ptr[1] + 1 > cf_._maxlen)
    {
    lline = substr (@line, cf_._findex + 1, -1);
    s_.write_nstr (lline, 0, cf_.ptr[0]);
    }

  draw_tail (;chr = decode (substr (@line, cf_._index + 1, 1))[0]);
}

insfuncs.right = &right;

private define left (s, line)
{
  if (0 < cf_.ptr[1] - cf_._indent)
    {
    cf_._index--;
    cf_.ptr[1]--;
    draw_tail (;chr = decode (substr (@line, cf_._index + 1, 1))[0]);
    }
  else
    if (is_wrapped_line)
      {
      cf_._index--;
      variable lline;
      lline = substr (@line, cf_._index, -1);
      s_.write_nstr (lline, 0, cf_.ptr[0]);
      draw_tail (;chr = decode (substr (@line, cf_._index, 1))[0]);
      if (cf_._index - 1 == cf_._indent)
        is_wrapped_line = 0;
      }
}

insfuncs.left = &left;

private define down (s, line)
{
  if (s.lnr == cf_._len)
    return 0;

  cf_.lins[cf_.ptr[0] - cf_.rows[0]] = @line;
  cf_.lines[s.lnr] = @line;

  if (is_wrapped_line)
    {
    s_.write_nstr (@line, 0, cf_.ptr[0]);
    is_wrapped_line = 0;
    cf_._findex = cf_._indent;
    cf_.ptr[1] = cf_._maxlen;
    cf_._index = cf_._maxlen;
    }

  s.lnr++;

  @line = cf_.lines[s.lnr];

  variable len = strlen (@line);
 
  if (cf_._index > len)
    {
    cf_.ptr[1] = len - cf_._indent;
    cf_._index = len - cf_._indent;
    }
 
  if (cf_.ptr[0] < cf_.vlins[-1])
    {
    cf_.ptr[0]++;
    draw_tail (;chr = decode (substr (@line, cf_._index, 1))[0]);
    return 0;
    }

  cf_._i++;

  s_.draw (;chr = decode (substr (@line, cf_._index, 1))[0]);
 
  return 0;
}

insfuncs.down = &down;

private define up (s, line)
{
  variable i = v_lnr ('.');

  ifnot (s.lnr)
    return 0;

  cf_.lins[cf_.ptr[0] - cf_.rows[0]] = @line;
  cf_.lines[s.lnr] = @line;

  if (is_wrapped_line)
    {
    s_.write_nstr (@line, 0, cf_.ptr[0]);
    is_wrapped_line = 0;
    cf_._findex = cf_._indent;
    cf_.ptr[1] = cf_._maxlen;
    cf_._index = cf_._maxlen;
    }
 
  s.lnr--;
 
  @line = cf_.lines[s.lnr];
 
  variable len = strlen (@line);

  if (cf_._index > len)
    {
    cf_.ptr[1] = len - cf_._indent;
    cf_._index = len - cf_._indent;
    }
 
  if (cf_.ptr[0] > cf_.vlins[0])
    {
    cf_.ptr[0]--;
    draw_tail (;chr = decode (substr (@line, cf_._index, 1))[0]);
    return 0;
    }
 
  cf_._i = cf_._ii - 1;
 
  s_.draw (;chr = decode (substr (@line, cf_._index, 1))[0]);
 
  return 0;
}

insfuncs.up = &up;

private define cr (s, line)
{
  variable
    prev_l,
    next_l,
    lline;

  if (strlen (@line) == cf_.ptr[1])
    {
    cf_.lines[s.lnr] = @line;

    cf_._chr = 'o';
 
    (@pagerf[string ('o')]) (;modified);
    }
  else
    {
    lline = 0 == cf_.ptr[1] - cf_._indent ? " " : substr (@line, 1, cf_.ptr[1]);
    @line = substr (@line, cf_.ptr[1] + 1, -1);

    prev_l = lline;

    if (s.lnr + 1 >= cf_._len)
      next_l = "";
    else
      next_l = v_lin (cf_.ptr[0] + 1);

    cf_.ptr[1] = cf_._indent;
    cf_._i = cf_._ii;

    if (cf_.ptr[0] == cf_.rows[-2] && cf_.ptr[0] + 1 > cf_._avlins)
      cf_._i++;
    else
      cf_.ptr[0]++;

    ifnot (s.lnr)
      cf_.lines = [lline, @line, cf_.lines[[s.lnr + 1:]]];
    else
      cf_.lines = [cf_.lines[[:s.lnr - 1]], lline, @line, cf_.lines[[s.lnr + 1:]]];

    cf_._len++;
 
    s_.draw ();
 
    insert (line, s.lnr + 1, prev_l, next_l;modified);
    }
}

insfuncs.cr = &cr;

private define esc (s, line)
{
  if (0 < cf_.ptr[1] - cf_._indent)
    cf_.ptr[1]--;

  cf_._index--;
 
  if (s.modified)
    {
    set_modified ();
 
    cf_.lins[cf_.ptr[0] - cf_.rows[0]] = @line;
    cf_.lines[s.lnr] = @line;

    cf_.st_.st_size = calcsize (cf_.lines);
    }
 
  topline (" (ved)  -- PAGER --");
  draw_tail ();
}

insfuncs.esc = &esc;

private define getline (self, line)
{
  self = struct {@insfuncs, @self};
 
  forever
    {
    self.chr = get_char ();

    if (033 == self.chr)
      {
      self.esc (line;;__qualifiers ());
      return;
      }

    if ('\r' == self.chr)
      {
      self.cr (line;;__qualifiers ());
      return;
      }

    if (keys->UP == self.chr)
      {
      ifnot (self.up (line;;__qualifiers ()))
        continue;

      return;
      }
 
    if (keys->DOWN == self.chr)
      {
      ifnot (self.down (line;;__qualifiers ()))
        continue;

      return;
      }

    if (any (keys->rmap.left == self.chr))
      {
      self.left (line);
      continue;
      }
 
    if (any (keys->rmap.right == self.chr))
      {
      self.right (line);
      continue;
      }

    if (any (keys->CTRL_y == self.chr))
      {
      self.completeline (line, self.prev_l);
      continue;
      }

    if (any (keys->CTRL_e == self.chr))
      {
      self.completeline (line, self.next_l);
      continue;
      }

    if (any (keys->rmap.home == self.chr))
      {
      self.bol (line);
      continue;
      }

    if (any (keys->rmap.end == self.chr))
      {
      self.eol (line);
      continue;
      }

    if (any (keys->rmap.backspace == self.chr))
      {
      self.del_prev (line);
      continue;
      }

    if (any (keys->rmap.delete == self.chr))
      {
      self.del_next (line);
      continue;
      }

    if (' ' <= self.chr <= 126 || 902 <= self.chr <= 974)
      {
      self.ins_char (line);
      continue;
      }
    }
}

define insert (line, lnr, prev_l, next_l)
{
  topline_dr (" (ved)  -- INSERT --");

  variable
    self = @Insert_Type;

  self.lnr = lnr;
  self.modified = qualifier_exists ("modified");
  self.prev_l = prev_l;
  self.next_l = next_l;
 
  getline (self, line;;__qualifiers ());
}
