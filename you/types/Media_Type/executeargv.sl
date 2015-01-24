define main (self, argv)
{
  variable
    i,
    fp,
    files,
    info,
    index,
    lyric,
    retval,
    playlist,
    routine = 1,
    ar = String_Type[0],
    refreshlyric = NULL,
    bufa = self.buffers[0],
    bufb = self.buffers[1];

  ifnot ("closeshell" == argv[0])
    self.cur.command = argv[0];

  try
    {
    switch (argv[0])
 
      {
      case "i": self.getinfo ();
      }
 
      {
      case "RefreshLyrics":

      self.lyrics = listdir (self.lyricsdir);
      refreshlyric = 1;
      }

      {
      case "r": refreshlyric = 1;
      }

      {
      case "l":
 
      if (-1 == access (self.playlistfile, F_OK))
        throw Break;

      playlist = array_map (String_Type, &path_basename_sans_extname,
        readfile (self.playlistfile));

      info = self.getcurplaying ();

      ifnot (NULL == info)
        {
        index = wherefirst (info.fname == playlist);
        ifnot (NULL == index)
          playlist[index] += "  *****";
        }

      root.lib.printtostdout (playlist; header =
        sprintf ("Viewing Playlist (length %d)", length (playlist)));
      }
 
      {
      case "tooglesoundcard":

      if (1 == length (self.soundcards))
        {
        srv->send_msg ("There is only one soundcard in this system", -1);
        throw Break;
        }
 
      self.cur.soundcard++;
      if (self.cur.soundcard == length (self.soundcards))
        self.cur.soundcard = 0;

      self.cur.soundchannel = self.soundchannels[self.cur.soundcard];

      variable vers = self.exec (sprintf ("%s/check_vers", path_dirname (__FILE__)));

      if (1 == vers)
        self.argv = [which ("mplayer"),
          "-utf8",
          "-slave",
          "-idle",
          "-fs",
          "-msglevel", "all=-1:global=5",
          "-input", sprintf ("file=%s", self.fifo),
          "-input", sprintf ("nodefault-bindings:conf=%s", self.conf),
          "-ao", sprintf ("alsa:device=hw=%d.0", self.cur.soundcard)];
      else
        self.argv = [which ("mplayer"),
          "--slave",
          "--idle",
          "--fs",
          "--msglevel=all=-1:global=5",
          sprintf ("--input=file=%s", self.fifo),
          sprintf ("--input=nodefault-bindings:conf=%s", self.conf),
          sprintf ("--ao=alsa:device=hw=%d.0", self.cur.soundcard)];

      self.quit ();
      }

      {
      case "stop":

      self.stop ();
      throw Break;
      }
 
      {
      case "m":
        self.mute = self.mute ? 0 : 1;
        self.writetofifo (sprintf ("mute %d", self.mute));
        throw Break;
      }

      {
      case "mediapause":
      self.writetofifo ("pause");
      throw Break;
      }

      {
      case "kill": root.func.call ("windowdelete");
      }

      {
      case "n" || case "p":
      self.writetofifo (sprintf ("pt_step %s1", argv[0] == "n" ? "" : "-"));
      sleep (0.1);
      refreshlyric = 1;
      }

      {
      case "0" || case "2" || case "1" || case "9":
 
      () = popen (sprintf ("%s %d%%%s 2>/dev/null", self.amixerargv,
        any (["0", "9"] == argv[0]) ? 8 : 1,
        any (["0", "2"] == argv[0]) ? "+" : "-"), "w");

      srv->send_msg (sprintf ("volune %s",
        any (["0", "2"] == argv[0]) ? "raised" : "lowered"), 0);
      refreshlyric = 1;
      }

      {
      case "f" || case "F": self.writetofifo (
        sprintf ("seek +%d", argv[0] == "f" ? 4 : 14));
      }

      {
      case "PGUP" || case "PGDWN": self.writetofifo (
        sprintf ("seek %s200", argv[0] == "PGUP" ? "+" : "-"));
      }

      {
      case "b" || case "B": self.writetofifo (
        sprintf ("seek -%d", argv[0] == "b" ? 4 : 14));
      }

      {
      case "a" || case "v":

      if (2 > length (argv))
        {
        srv->send_msg ("It takes a directory, or a filename as argument", -1);
        throw Break;
        }

      files = [argv[[1:]]];

      _for i (0, length (files) - 1)
        if (-1 == access (files[i], F_OK|R_OK))
          files[i] = NULL;
 
      files = files[wherenot (_isnull (files))];

      _for i (0, length (files) - 1)
        if (isdirectory (files[i]))
          ar = [ar, array_map (String_Type, &path_concat, files[i], listdir (files[i]))];
        else
          ar = [ar, files[i]];

      _for i (0, length (ar) - 1)
        ifnot (any (self.mediaext == path_extname (ar[i])))
          ar[i] = NULL;
 
      ar = ar[wherenot (_isnull (ar))];
 
      ifnot (length (ar))
        {
        srv->send_msg ("No Media file found to play", -1);
        throw Break;
        }
 
      if (argv[0] == "a")
        ar = ar[array_sort (ar)];
      else
        if (1 < length (ar))
          ar = ar[root.lib.rand_int_ar_uniq (0, length (ar) - 1, length (ar))];

      writefile (ar, self.playlistfile);

      self.lyrics = listdir (self.lyricsdir);
      self.writetofifo (sprintf ("loadlist %s", self.playlistfile));
      refreshlyric = 1;
      }

      {
      case "closeshell":

      self.framedelete (2;dont_goto_prompt);
      self.cur.frame = 0;
      self.dim[1].infolinecolor = COLOR.info;
      self.dim[0].infolinecolor = COLOR.activeframe;
      self.writeinfolines ();
      throw Break;
      }

      {
      throw Break;
      }
    }
  catch Break:
    routine = NULL;
  catch AnyError:
    root.lib.printtostdout (exception_to_array);
  finally:
    {
    ifnot (NULL == routine)
      {
      sleep (0.2);
      info = self.getcurplaying ();
      ifnot (NULL == info)
        {
        variable
          seconds = info.len mod 60,
          leftm = (info.len - info.pos) / 60,
          lefts = (info.len - info.pos) mod 60;

        writefile ([
          sprintf ("Playing : %s", info.fname),
          sprintf ("Duration: %d seconds, %d minutes%s", info.len, info.len / 60,
           seconds ? sprintf (", %d seconds", seconds) : ""),
          sprintf ("Time Pos: %d", info.pos),
          sprintf ("Left    : %d minutes, %d seconds", leftm, lefts)],
          bufb.fname);
        }
 
      if (refreshlyric && NULL != info)
        ifnot (NULL == self.lyrics)
          {
          lyric = wherenot (strncmp (self.lyrics, info.fname, strlen (info.fname)));
          if (length (lyric))
            {
            self.cur.lyric = path_basename_sans_extname (self.lyrics[lyric[0]]);
            lyric = readfile (sprintf ("%s/%s", self.lyricsdir, self.lyrics[lyric[0]]));
            }
          else
            {
            self.cur.lyric = NULL;
            lyric = [" "];
            % Lets add it to a todo file
            writefile (info.fname, self.todolyricfile;mode = "a+");
            }

          writefile (lyric, bufa.fname);
          self.drawframe (0;reread_buf);
          }

      self.drawframe (1;reread_buf);
      self.setinfoline (NULL, 0, NULL);
      self.writeinfolines ();
      }

    self.gotoprompt ();
    }
}
