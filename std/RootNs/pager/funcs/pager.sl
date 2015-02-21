define main (self)
{
  variable
    frame = qualifier ("frame", self.cur.frame),
    buf = self.buffers[frame],
    len = length (buf.ar_len) - 1,
    iamreal = qualifier_exists ("iamreal");
 
  if (self.pagerstate && 0 == iamreal)
    self.drawwind (;reread_buf, refresh);

  self.pagerstate = iamreal;

  if (iamreal)
    {
    self.drawframe (frame;;struct {@__qualifiers (), reread_buf});
 
    srv->refresh ();

    if (qualifier_exists ("goto_prompt") || qualifier_exists ("send_break"))
      {
      () = self.setar (buf, buf.fname);
      self.set (buf, frame, len;setline, setpos, setind, setrows);

      if (qualifier_exists ("send_break"))
        throw Break;

      throw GotoPrompt;
      }

    len = length (buf.ar_len) - 1;
    }

  variable
    chr,
    index,
    nrs = [keys->CTRL_f, keys->NPAGE, keys->CTRL_b, keys->PPAGE, 27,
    keys->DOWN, keys->UP, keys->LEFT, keys->RIGHT, keys->HOME, keys->END],
    key = ["pgdown", "pgdown", "pgup", "pgup", "escape",
           "go_down", "go_up", "go_left", "go_right", "HOME", "END"],
    frame_size = self.frames_size[frame];

  ifnot (NULL == qualifier ("func"))
    {
    ifnot (assoc_key_exists (self.pfuncs, qualifier ("func")))
      srv->send_msg (sprintf ("%s: No such pager function", qualifier ("func")), -1);
    else
      (@self.pfuncs[qualifier ("func")])
        (self, buf.pos[0], buf.pos[1], buf, frame, frame_size, len;; __qualifiers ());

    ifnot (qualifier_exists ("dont_send_break"))
      throw Break;
    }

  self.cur.mode = "pager";

  srv->write_prompt (NULL, 0; prompt_char = "");
  (@self.pfuncs["routine"]) (self, buf, frame, len);
 
  forever
    {
    self.pcount = 0;
    chr = (@getch);
    srv->send_msg ("", 0);
 
    if ('w' == chr)
      {
      if (NULL == qualifier ("file"))
        continue;
 
      root.func.call ("writeunamed", qualifier ("file"));
      continue;
      }

    if ('e' == chr)
      {
      root.func.call ("edthisfile", qualifier ("file");;
        struct {@__qualifiers (), dont_goto_prompt,
        linenr = buf.indices[wherefirst_eq (buf.rows, buf.pos[0])] + 1});

      root.topline ();
      srv->gotorc (buf.pos[0], buf.pos[1]);
      srv->refresh ();
      continue;
      }

    if ('\r' == chr)
      if (struct_field_exists (CW, "jumptoitem"))
        {
        CW.cur.linenr = buf.indices[wherefirst_eq (buf.rows, buf.pos[0])] + 1;
        CW.jumptoitem ("=");
        }
 
    if ('*' == chr || '#' == chr)
      {
      srv->gotorc (buf.pos[0], buf.pos[1]);
      srv->refresh ();
 
      variable
        i,
        c,
        word = "",
        line = self.getbufline (buf, qualifier ("file", buf.fname),
          buf.indices[wherefirst_eq (buf.rows, buf.pos[0])]);
 
      ifnot (strlen (line))
        continue;

      c = srv->char_at ();

      if (' ' == c)
        continue;
 
      ifnot (0 == buf.pos[1])
        while (' ' != c)
          {
          (@self.pfuncs["h"])
              (self, buf.pos[0], buf.pos[1], buf, frame, frame_size, len;);
          srv->gotorc (buf.pos[0], buf.pos[1]);
          srv->refresh ();

          c = srv->char_at ();

          if (0 == buf.pos[1])
            break;
          }
 
      if (' ' == c)
        {
        (@self.pfuncs["l"])
            (self, buf.pos[0], buf.pos[1], buf, frame, frame_size, len;);
        srv->gotorc (buf.pos[0], buf.pos[1]);
        srv->refresh ();

        c = srv->char_at ();
        if (' ' != c)
          word += char (c);
        }
      else
        word += char (c);

      while (' ' != c)
        {
        (@self.pfuncs["l"])
            (self, buf.pos[0], buf.pos[1], buf, frame, frame_size, len);
        srv->gotorc (buf.pos[0], buf.pos[1]);
        srv->refresh ();

        c = srv->char_at ();
        if (' ' != c)
          word += char (c);

        if (strlen (line) - 1 == buf.pos[1])
          break;
        }
 
      root.search.buffer (&buf.pos[0], &buf.pos[1], buf, frame, frame_size, len;
          pattern = word, dothesearch, type = '#' == chr ? "backwards" : "forward",
          file = qualifier ("file", buf.fname));
 
      (@self.pfuncs["routine"]) (self, buf, frame, len);
      continue;
      }

    if ('/' == chr)
      {
      root.search.buffer (&buf.pos[0], &buf.pos[1], buf, frame, frame_size, len;
        file = qualifier ("file", buf.fname));

      (@self.pfuncs["routine"]) (self, buf, frame, len);
      continue;
      }

    if ('?' == chr)
      {
      root.search.buffer (&buf.pos[0], &buf.pos[1], buf, frame, frame_size, len
        ;type = "backward", file = qualifier ("file", buf.fname));

      (@self.pfuncs["routine"]) (self, buf, frame, len);
      continue;
      }

    if (keys->CTRL_w == chr)
      {
      root.func.call ("framenext";dont_goto_prompt);
      if (frame == self.cur.frame)
        continue;

      buf = self.buffers[self.cur.frame];
      len = length (buf.ar_len) - 1;
      frame = self.cur.frame;
      frame_size = self.frames_size[frame];
      (@self.pfuncs["routine"]) (self, buf, frame, len);
      continue;
      }
 
    if (48 < chr < 58)
      {
      self.pcount = "";

      while (47 < chr < 58)
        {
        self.pcount += char (chr);
        chr = input->en_getch;
        }
      then
        self.pcount = integer (self.pcount);
      }

    index = where (chr == nrs);

    if (length (index))
      chr = key[index[0]];
    else
      chr = char (chr);

    if (any ([":", "escape", "q"] == chr))
      {
      if (iamreal)
        if (qualifier_exists ("drawwind"))
          self.drawwind (;reread_buf);
        else
          self.drawframe (self.cur.frame;reread_buf);

      if (qualifier_exists ("dont_goto_prompt") || qualifier_exists ("send_break_at_exit"))
        throw Break;

      CW.gotoprompt ();
      }

    if (assoc_key_exists (self.pfuncs, chr))
      {
      % With the second if statement, we miss the "go to line number 1",
      % use g to jump to linenr 1.
      % Note: go to line number 1 is gg in vim
      % Todo: the usefull commands in vim that starting with g and
      % needs implementation are gf, gF, gv

      try
        {
        if (self.pcount > 1 && "G" == chr)
          (@self.pfuncs["go_to_line"])
            (self, &buf.pos[0], &buf.pos[1], buf, frame, frame_size, len;;__qualifiers ());
        else
            (@self.pfuncs[chr])
              (self, buf.pos[0], buf.pos[1], buf, frame, frame_size, len;;__qualifiers ());

        (@self.pfuncs["routine"]) (self, buf, frame, len);
        }
      catch AnyError:
        {
        root.lib.printtostdout (exception_to_array);
        throw GotoPrompt;
        }
      }
    else
      {
      srv->send_msg (sprintf ("%s: invalid key", chr), -1);
      srv->gotorc (buf.pos[0], buf.pos[1]);
      srv->refresh ();
      }
  }
}
