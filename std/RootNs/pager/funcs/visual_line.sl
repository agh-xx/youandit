define main (self, row, col, buf, frame, frame_size, len)
{
  variable
    i,
    ia = 0,
    chr,
    lines,
    retval,
    ups = 0,
    downs = 0,
    keep_lines = NULL,
    ar = Integer_Type[length (buf.ar)],
    finish = [033, '"', 'y', 'Y', 'd', 'D'],
    linenr = buf.indices[wherefirst_eq (buf.rows, buf.pos[0])];

  ar[linenr] = COLOR.hlchar;

  srv->send_msg (
    "VisualLinewiseMode, esc aborts, y|Y|d|D (sets|appends unamed register), \" to set reg", 0);
  srv->set_color_in_region (COLOR.hlchar, row, 0, 1, COLUMNS);
  srv->refresh;

  chr = input->en_getch;

  while (0 == any (chr == finish))
    {
    if (any ([keys->UP, 'k'] == chr))
      {
      retval = self.exec (sprintf ("%s/vis_go_up", path_dirname (__FILE__)),
        buf.pos[0], col, buf, frame);

      if (-1 == retval)
        {
        chr = input->en_getch;
        continue;
        }

      ups++;
      }

    if (any ([keys->DOWN, 'j'] == chr))
      {
      retval = self.exec (sprintf ("%s/vis_go_down", path_dirname (__FILE__)),
        buf.pos[0], col, buf, frame);

      if (-1 == retval)
        {
        chr = input->en_getch;
        continue;
        }

      downs++;
      }

    ar[where (ar)] = 0;

    if (ups == downs)
      ar[linenr] = COLOR.hlchar;
    else if (ups > downs)
      ar[[linenr - (ups - downs):linenr]] = COLOR.hlchar;
    else
      ar[[linenr:linenr + (downs - ups)]] = COLOR.hlchar;

    srv->clear_frame (frame_size, self.dim[frame].rowfirst,
        self.dim[frame].rowlast, COLOR.normal, 0);

    srv->write_ar_at (buf.ar[buf.indices], COLOR.normal, buf.rows, 0);

    srv->refresh;
    chr = input->en_getch;
  }

  if (033 == chr)
    {
    srv->send_msg_and_refresh ("", 0);
    srv->clear_frame (frame_size, self.dim[frame].rowfirst,
        self.dim[frame].rowlast, COLOR.normal, 0);
 
    srv->write_ar_at (buf.ar[buf.indices], COLOR.normal, buf.rows, 0);
    srv->gotorc (buf.pos[0], buf.pos[1]);
    srv->refresh ();
    throw Break;
    }

  if (ups == downs)
    lines = [linenr];
  else if (ups > downs)
    lines =  [linenr - (ups - downs):linenr];
  else
    lines = [linenr:linenr + (downs - ups)];

  if ('d' == chr)
    {
    keep_lines = Integer_Type[@len - length (lines) + 1];

    _for i (0, @len)
      ifnot (any (i == lines))
        {
        keep_lines[ia] = i;
        ia++;
        }
    }

  if (any (['y', 'd'] == chr))
    REGS["\""] = buf.ar[lines];

  if (any (['Y', 'D'] == chr))
    if (assoc_key_exists (REGS, "\""))
      REGS["\""] = [REGS["\""], buf.ar[lines]];
    else
      REGS["\""] = buf.ar[lines];

  if ('"' == chr)
    {
    chr = root.lib.get_engl_chr (;msg =
      "Please enter an english char to store the register, NOTE: uppercase appends");
    if (any (chr == ['A':'Z']))
      if (assoc_key_exists (REGS, char (chr)))
        REGS[char (chr)] = [REGS[char (chr)], buf.ar[lines]];
      else
        REGS[char (chr)] = buf.ar[lines];
    else
      REGS[char (chr)] = buf.ar[lines];

    srv->send_msg_and_refresh ("[d/y] delete|yank", 0);
    chr = input->en_getch;
    while (0 == any (chr == ['d', 'y']))
      chr = input->en_getch;
    }

  if ('d' == chr)
    {
    ifnot (length (keep_lines))
      buf.ar = [""];
    else
      buf.ar = buf.ar[keep_lines];

    @len = length (buf.ar) - 1;
 
    self.set (buf, frame, @len; setline, setpos, setind, setrows);
    }

  srv->send_msg ("", 0);
  self.drawframe (frame);
  srv->refresh ();
}
