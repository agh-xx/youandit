private define del_line ()
{
  variable
    i_,
    i = v_lnr ('.'),
    line = v_lin ('.');

  if (0 == cw_._len && (0 == v_linlen ('.') || " " == line))
    return 1;

  cw_.lines[i] = NULL;
  cw_.lines = cw_.lines[wherenot (_isnull (cw_.lines))];
  cw_._len--;
  
  cw_._i = cw_._ii;
  
  cw_.ptr[1] = cw_._indent;

  if (cw_.ptr[0] == cw_.vlins[-1] && 1 <length (cw_.vlins))
    cw_.ptr[0]--;

  cw_.st_.st_size -= strbytelen (line);

  cw_._flags = cw_._flags | MODIFIED;

  if (cw_._i > cw_._len)
    cw_._i = cw_._len;

  return 0;
}

%private define del_word ()
%{
%  variable
%    end,
%    start,
%    col = w_.ptr[1],
%    i = v_lnr ('.'),
%    line = v_lin ('.'),
%    len = strlen (line);
%  
%  if (isblank (line[col]))
%    return;
%
%  ifnot (col - cw_._indent)
%    start = cw_._indent;
%  else
%    {
%    while (col--, 0 == isblank (line[col]));
%    start = col + 1;
%    }
% 
%  while (col++, col < len && 0 == isblank (line[col]));
%    end = col - 1;
%
%  line = sprintf ("%s%s", substr (line, 1, start), substr (line, end + 2, -1)); 
%  
%  ifnot (s_._flags & MODIFIED)
%    s_._flags = s_._flags | MODIFIED;
%  
%  w_.lins[w_.ptr[0] - 2] = line;
%  s_.p_.lins[i] = line;
%  w_.ptr[1] = start;
%  s_.st_.st_size -= len - strbytelen (line);
% 
%  s_.encode ();
%
%  srv->write_nstring_dr (line, COLUMNS, 0, [w_.ptr[0], 0, w_.ptr[0], w_.ptr[1]]);
%}
%
private define del_chr ()
{
  variable
    col = cw_.ptr[1],
    i = v_lnr ('.'),
    line = v_lin ('.'),
    len = strlen (line),
    blen = strbytelen (line);

  if ((0 == cw_.ptr[1] - cw_._indent && 'X' == cw_._chr) || 0 > len - cw_._indent)
    return;
 
  if ('x' == cw_._chr)
    {
    line = substr (line, 1, col) + substr (line, col + 2, - 1);
    if (cw_.ptr[1] == strlen (line))
      cw_.ptr[1]--;
    }
  else
    if (0 < cw_.ptr[1] - cw_._indent)
      {
      line = substr (line, 1, col - 1) + substr (line, col + 1, - 1);
      cw_.ptr[1]--;
      }

  if (cw_.ptr[1] - cw_._indent < 0)
    cw_.ptr[1] = cw_._indent;

  cw_.lins[cw_.ptr[0] - cw_.rows[0]] = line;
  cw_.lines[i] = line;

  cw_.st_.st_size -= blen - strbytelen (line);
 
  cw_._flags = cw_._flags | MODIFIED;
  
  srv->write_nstring_dr (line, COLUMNS, 0, [cw_.ptr[0], 0, cw_.ptr[0], cw_.ptr[1]]);
}

private define del ()
{
  cw_._chr = get_char ();
  
  send_msg_dr ("delete? d[delete line]|w[ord]", 0, NULL, NULL);

  if (any (['d', 'w' == cw_._chr]))
    {
    if ('d' == cw_._chr)
      {
      if (1 == del_line ())
        return;

      s_.draw ();
      }
%% will change to W and del_Word
%    if ('w' == cw_._chr)
%      del_word ();
    }

  send_msg_dr (" ", 0, cw_.ptr[0], cw_.ptr[1]);
}

private define edit_line ()
{
  variable
    prev_l,
    next_l,
    col = cw_.ptr[1],
    i = v_lnr ('.'),
    line = v_lin ('.'),
    len = strlen (line);

  ifnot (i)
    prev_l = "";
  else
    prev_l = v_lin (cw_.ptr[0] - 1);

  if (i == cw_._len)
    next_l = "";
  else
    next_l = strjoin (cw_.lines[i+1]);
  
  if ('C' == cw_._chr) 
    line = substr (line, 1, col);
  else if ('a' == cw_._chr)
    cw_.ptr[1]++;
  else if ('A' == cw_._chr)
    cw_.ptr[1] = len;
 
  cw_.st_.st_size -= strbytelen (line);

  srv->write_nstring_dr (line, COLUMNS, 0, [cw_.ptr[0], 0, cw_.ptr[0], cw_.ptr[1]]);

  rlf_.getline (&line, prev_l, next_l);
 
  cw_._flags = cw_._flags | MODIFIED;
  
  cw_.lins[cw_.ptr[0] - cw_.rows[0]] = line;
  cw_.lines[i] = line;

  cw_.st_.st_size += strbytelen (line);
}

%pf[string ('o')] = &newline;
%pf[string ('O')] = &newlineO;
pagerf[string ('d')] = &del;
pagerf[string ('x')] = &del_chr;
pagerf[string ('X')] = &del_chr;
pagerf[string ('C')] = &edit_line;
pagerf[string ('i')] = &edit_line;
pagerf[string ('a')] = &edit_line;
pagerf[string ('A')] = &edit_line;
%pf[string (keys->CTRL_u)] = &redo;
%pf[string ('u')] = &undo;
%pf[string ('>')] = &indent_out;
%pf[string ('<')] = &indent_in;
