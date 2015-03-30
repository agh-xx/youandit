private variable
  col,
  lnr,
  found,
  search_type,
  histindex = NULL,
  history = {};

private define exit_rout ()
{
  srv->gotorc (cw_.ptr[0], cw_.ptr[1]);
  write_msg (" ", PROMPTCLR);
  srv->write_ar_nstr_at ([" "], [0], [PROMPTROW], [0], COLUMNS);
  draw_tail ();
}

private define search_backward (str)
{
  variable
    i,
    ar,
    pat,
    cols,
    match,
    wrapped = 0,
    clrs = Integer_Type[0],
    rows = Integer_Type[4];
 
  rows[*] = MSGROW;

  try
    {
    pat = pcre_compile (str, PCRE_UTF8);
    }
  catch ParseError:
    {
    write_msg_dr ("error compiling pcre pattern", PROMPTROW, col);
    return;
    }
  
  i = lnr;

  while (i > -1 || (i > lnr && wrapped))
    if (pcre_exec (pat, cw_.lines[i]))
      {
      match = pcre_nth_match (pat, 0);
      ar = [
        sprintf ("row %d|", lnr + 1),
        substrbytes (cw_.lines[i], 1, match[0]),
        substrbytes (cw_.lines[i], match[0] + 1, match[1] - match[0]),
        substrbytes (cw_.lines[i], match[1] + 1, -1)];
      cols = strlen (ar[[:-2]]);
      cols = [0, array_map (Integer_Type, &int, cumsum (cols))];
      clrs = [0, 0, PROMPTCLR, 0];
      lnr = i;
      srv->write_ar_nstr_dr (ar, clrs, rows, cols, [PROMPTROW, col], COLUMNS);
      found = 1;
      return;
      }
    else
      ifnot (i)
        if (wrapped)
          break;
        else
          {
          i = cw_._len;
          wrapped = 1;
          }
      else
        i--;
  
  found = 0;
  write_msg_dr ("Nothing found", PROMPTROW, col);
}

private define search_forward (str)
{
  variable
    i,
    ar,
    pat,
    cols,
    match,
    wrapped = 0,
    clrs = Integer_Type[0],
    rows = Integer_Type[4];
 
  rows[*] = MSGROW;

  try
    {
    pat = pcre_compile (str, PCRE_UTF8);
    }
  catch ParseError:
    {
    write_msg_dr ("error compiling pcre pattern", PROMPTROW, col);
    return;
    }
  
  i = lnr;
  
  while (i <= cw_._len || (i < lnr && wrapped))
    if (pcre_exec (pat, cw_.lines[i]))
      {
      match = pcre_nth_match (pat, 0);
      ar = [
        sprintf ("row %d|", lnr + 1),
        substrbytes (cw_.lines[i], 1, match[0]),
        substrbytes (cw_.lines[i], match[0] + 1, match[1] - match[0]),
        substrbytes (cw_.lines[i], match[1] + 1, -1)];
      cols = strlen (ar[[:-2]]);
      cols = [0, array_map (Integer_Type, &int, cumsum (cols))];
      clrs = [0, 0, PROMPTCLR, 0];
      srv->write_ar_nstr_dr (ar, clrs, rows, cols, [PROMPTROW, col], COLUMNS);

      lnr = i;
      found = 1;
      return;
      }
    else
      if (i == cw_._len)
        if (wrapped)
          break;
        else
          {
          i = 0;
          wrapped = 1;
          }
      else
        i++;
  
  found = 0;
  write_msg_dr ("Nothing found", PROMPTROW, col);
}

define search ()
{
  variable
    origlnr,
    dothesearch,
    type,
    typesearch,
    chr,
    pchr,
    str,
    pat = "";

  lnr = v_lnr ('.');
  
  origlnr = lnr;

  type = keys->BSLASH == cw_._chr ? "forward" : "backward";
  pchr = type == "forward" ? "/" : "?";
  str = pchr;
  col = 1;
  
  typesearch = type == "forward" ? &search_forward : &search_backward;
  write_prompt (str, PROMPTROW, col);
  
  forever
    {
    dothesearch = 0;
    chr = get_char ();

    if (033 == chr)
      {
      exit_rout ();
      break;
      }
    
    if ((' ' <= chr < 64505) &&
        0 == any (chr == [keys->rmap.backspace, keys->rmap.delete,
        [keys->UP:keys->RIGHT], [keys->F1:keys->F12]]))
      {
      if (col == strlen (pat) + 1)
        pat += char (chr);
      else
        pat = substr (pat, 1, col - 1) + char (chr) + substr (pat, col, -1);

      col++;
      dothesearch = 1;
      }
    
    if (any (chr == keys->rmap.backspace) && strlen (pat)) 
      if (col - 1)
        {
        if (col == strlen (pat) + 1)
          pat = substr (pat, 1, strlen (pat) - 1);
        else
          pat = substr (pat, 1, col - 2) + substr (pat, col, -1);
        
        lnr = origlnr;

        col--;
        dothesearch = 1;
        }

    if (any (chr == keys->rmap.delete) && strlen (pat)) 
      {
      ifnot (col - 1)
        (pat = substr (pat, 2, -1), dothesearch = 1);
      else if (col != strlen (pat) + 1)
        (pat = substr (pat, 1, col - 1) + substr (pat, col + 1, -1),
         dothesearch = 1);
      }
    
    if (any (chr == keys->rmap.changelang))
      {
      (@pagerf[string (chr)]);
      write_msg_dr (" ", PROMPTROW, col);
      continue;
      }

    if (any (chr == keys->rmap.left) && col != 1)
      col--;
    
    if (any (chr == keys->rmap.right) && col != strlen (pat) + 1)
      col++;
    
    if ('\r' == chr)
      {
      if (found)
        {
        list_insert (history, pat);
        if (NULL == histindex)
          histindex = 0;

        cw_._i = lnr;
        cw_.ptr[0] = cw_.rows[0];
        cw_.ptr[1] = 0;
        s_.draw ();
        }

      exit_rout ();
      break;
      }
    
    if (chr == keys->UP)
      ifnot (NULL == histindex)
        {
        pat = history[histindex];
        if (histindex == length (history) - 1)
          histindex = 0;
        else
          histindex++;

        col = strlen (pat) + 1;
        str = pchr + pat;
        write_prompt (str, PROMPTROW, col);
        (@typesearch) (pat);
        continue;
        }

    if (chr == keys->DOWN)
      ifnot (NULL == histindex)
        {
        pat = history[histindex];
        ifnot (histindex)
          histindex = length (history) - 1;
        else
          histindex--;

        col = strlen (pat) + 1;
        str = pchr + pat;
        write_prompt (str, PROMPTROW, col);
        (@typesearch) (pat);
        continue;
        }

    if (chr == keys->CTRL_n)
      {
      if (type == "forward")
        if (lnr == cw_._len)
          lnr = 0;
        else
          lnr++;
      else
        ifnot (lnr)
          lnr = cw_._len;
        else
          lnr--;

      (@typesearch) (pat);
      }

    str = pchr + pat;
    write_prompt (str, PROMPTROW, col);

    if (dothesearch)
      (@typesearch) (pat);
    }
}

pagerf[string (keys->BSLASH)] = &search;
pagerf[string (keys->QMARK)] = &search;
