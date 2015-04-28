private variable vis = struct
    {
    clr = 18,
    l_mode,
    l_down,
    l_up,
    c_mode,
    c_left,
    c_right,
    at_exit,
    };

private define v_unhl_line (s, index)
{
  srv->set_color_in_region (0, s.vlins[index], 0, 1, cf_._maxlen);
}

private define v_hl_ch (s)
{
  variable i;
  _for i (0, length (s.vlins) - 1)
    {
    v_unhl_line (s, i);
    srv->set_color_in_region (s.clr, s.vlins[i], s.col[i], 1, strlen (s.sel[i]));
    }

  srv->refresh ();
}

private define v_hl_line (s)
{
  variable i;
  _for i (0, length (s.vlins) - 1)
    ifnot (-1 == s.vlins[i])
      srv->set_color_in_region (s.clr, s.vlins[i], 0, 1,
        cf_._maxlen > s.linlen[i] ? s.linlen[i] : cf_._maxlen);

  srv->refresh ();
}

private define v_l_up (s)
{
  if (cf_.ptr[0] == cf_.vlins[0])
    return;
  
%  if (s.vlins[0] == cf_.rows[0])
%    return; %for now
  
  cf_.ptr[0]--;

  if (s.lnrs[-1] > s.startrow)
    {
    v_unhl_line (s, -1);
    s.lines = s.lines[[:-2]];
    s.lnrs = s.lnrs[[:-2]];
    s.vlins = s.vlins[[:-2]];
    s.linlen = s.linlen[[:-2]];
    }
  else
    {
    s.lines = [v_lin ('.'), s.lines];
    s.lnrs = [s.lnrs[0] - 1, s.lnrs];
    s.vlins = [cf_.ptr[0], s.vlins];
    s.linlen = [strlen (s.lines[0]), s.linlen];
    }

  v_hl_line (s);
}

vis.l_up = &v_l_up;

private define v_l_down (s)
{
  if (s.lnrs[-1] == cf_._len)
    if (cf_.ptr[0] == cf_.vlins[-1])
      return;

  if (cf_.ptr[0] == cf_.vlins[-1]) %for now
    return;

  cf_.ptr[0]++;

  if (s.lnrs[0] < s.startrow)
    {
    v_unhl_line (s, 0);
    s.lines = s.lines[[1:]];
    s.lnrs = s.lnrs[[1:]];
    s.vlins = s.vlins[[1:]];
    s.linlen = s.linlen[[1:]];
    }
  else
    {
    s.lines = [s.lines, v_lin ('.')];
    s.lnrs = [s.lnrs, s.lnrs[-1] + 1];
    s.vlins = [s.vlins, cf_.ptr[0]];
    s.linlen = [s.linlen, strlen (s.lines[-1])];
    }

  v_hl_line (s);
}

vis.l_down = &v_l_down;

private define v_linewise_mode (s)
{
  variable
    chr;

  v_hl_line (s);

  while (chr = get_char (), any (['y', keys->DOWN, keys->UP] == chr))
    {
    if (chr == keys->DOWN)
      {
      s.l_down ();
      continue;
      }

    if (chr == keys->UP)
      {
      s.l_up ();
      continue;
      }

    if ('y' == chr)
      {
      REG["\""] = strjoin (s.lines, "\n") + "\n";
      seltoX (strjoin (s.lines, "\n") + "\n");
      return;
      }
    }
}

vis.l_mode = &v_linewise_mode;

variable l = 0;
private define v_c_left (s, cur)
{
  variable retval = p_left (s.linlen[-1]);

  if (-1 == retval)
    return;
  
  s.index[cur]--;

  if (retval)
    {
    variable lline;
    if (is_wrapped_line)
      {
      lline = substr (s.lines[cur], cf_._findex + 1, cf_._maxlen);
      s.wrappedmot--;
      }
    else
      lline = s.lines[cur];

    s_.write_nstr (lline, 0, cf_.ptr[0]);
    }


  if (cf_.ptr[1] < s.startcol[cur]) 
    s.col[cur] = cf_.ptr[1];
  else
    s.col[cur] = s.startcol[cur];

% if (cf_.ptr[1])
%   if (cf_.ptr[1] < s.startcol[cur]) 
%     if (is_wrapped_line)
%       s.col[cur] = s.startcol[cur] - s.wrappedmot;
%     else
%       s.col[cur] = cf_.ptr[1];
%   else
%     if (is_wrapped_line)
%       s.col[cur] = s.startcol[cur] - s.wrappedmot;
%     else
%      s.col[cur] = s.startcol[cur];
% else
%   if (is_wrapped_line)
%     s.col[cur] = (l++, l - strlen (s.sel[cur]) + 1);
%   else
%     s.col[cur] = cf_.ptr[1];

  %s.col[cur] = cf_.ptr[1] < s.startcol[cur] ? cf_.ptr[1] : s.startcol[cur];
 % s.col[cur] = cf_.ptr[1] < s.startcol[cur]
 %   ? is_wrapped_line
 %     ? 0 == cf_.ptr[1]
 %       ? s.startcol[cur] - s.wrappedmot
 %       : s.startcol[cur]
 %     : cf_.ptr[1]
 %   : is_wrapped_line
 %     ? s.startcol[cur] - s.wrappedmot
 %     : s.startcol[cur];
  s.col[cur] = cf_.ptr[1] < s.startcol[cur]
    ? is_wrapped_line
      ? s.startcol[cur] - s.wrappedmot
      : cf_.ptr[1]
    : is_wrapped_line
      ? s.startcol[cur] - s.wrappedmot
      : s.startcol[cur];
  s.col[cur] = cf_.ptr[1] < s.startcol[cur]
    ? is_wrapped_line
      ? s.startcol[cur] - strlen (s.sel[cur]) + 1
      : cf_.ptr[1]
    : is_wrapped_line
      ? s.startcol[cur] - s.wrappedmot
      : s.startcol[cur];

  if (s.index[cur] >= s.startindex[cur]) 
    s.sel[cur] = substr (s.sel[cur], 1, strlen (s.sel[cur]) - 1);
  else
    s.sel[cur] = substr (s.lines[cur], s.index[cur] + 1, 1) + s.sel[cur];

  debug (sprintf ("wm %d s.c %d in %d stind %d |%s|", s.wrappedmot, s.col[cur], s.index[cur], s.startindex[cur], s.sel[cur]), NULL);

  v_hl_ch (s);
}

vis.c_left = &v_c_left;

private define v_c_right (s, cur)
{
  variable retval = p_right (s.linlen[-1]);

  if (-1 == retval)
    return;
  
  s.index[cur]++; 

  if (retval)
    {
    variable lline = substr (s.lines[cur], cf_._findex + 1, cf_._maxlen);
    s_.write_nstr (lline, 0, cf_.ptr[0]);
    is_wrapped_line = 1;
    s.wrappedmot++;
    }

  s.col[cur] = cf_.ptr[1] < s.startcol[cur]
    ? cf_.ptr[1]
    : is_wrapped_line
      ? s.startcol[cur] - s.wrappedmot
      : s.startcol[cur];
  
  if (s.index[cur] <= s.startindex[cur]) 
    s.sel[cur] = substr (s.sel[cur], 2, -1);
  else
    s.sel[cur] += substr (s.lines[cur], s.index[cur] + 1, 1);

  debug (sprintf ("wm %d s.c %d in %d stind %d |%s|", s.wrappedmot, s.col[cur], s.index[cur], s.startindex[cur], s.sel[cur]), NULL);
  v_hl_ch (s);
}

vis.c_right = &v_c_right;

private define v_char_mode (s)
{
  variable
    chr,
    cur = 0;
  
  s.startcol = [s.col[0]];
  s.startindex = [s.index];
  s.index = [s.index];

  s.sel = [substr (s.lines[cur], s.index[cur] + 1, 1)];

  v_hl_ch (s);

  while (chr = get_char (), any (['y', keys->DOWN, keys->RIGHT, keys->UP, keys->LEFT]
    == chr))
    {
    if (keys->RIGHT == chr)
      {
      s.c_right (cur);
      continue;
      }

    if (keys->LEFT == chr)
      {
      s.c_left (cur);
      continue;
      }

    if ('y' == chr)
      {
      REG["\""] = strjoin (s.sel, "\n");
      seltoX (strjoin (s.sel, "\n"));
      s.index = s.startindex[cur];
      s.col = s.startcol[cur];
      return;
      }
    }

  s.index = s.startindex[cur];
  s.col = [s.startcol[cur]];
}

vis.c_mode = &v_char_mode;

private define v_atexit (s)
{
  topline ("-- pager --");

  cf_._i = cf_._ii;
  cf_.ptr[1] = s.col[0];
  cf_._index = s.index;
  
  s_.draw ();
}

vis.at_exit = &v_atexit;

private define v_init ()
{
  topline ("-- visual --");

  return struct
    {
    startrow,
    startcol,
    wrappedmot = 0,
    startindex,
    findex = cf_._findex,
    index = cf_._index,
    col = [cf_.ptr[1]],
    vlins = [cf_.ptr[0]],
    lnrs = [v_lnr ('.')],
    linlen = [v_linlen ('.')],
    lines = [v_lin ('.')],
    sel,
    @vis,
    };
}

private define vis_mode ()
{
  variable s = v_init ();
  s.startrow = s.lnrs[0];

  if (cf_._chr == 'v')
    s.c_mode ();
  else
    s.l_mode ();

  s.at_exit ();
}

pagerf[string ('v')] = &vis_mode;
pagerf[string ('V')] = &vis_mode;
