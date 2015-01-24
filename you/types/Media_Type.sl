private variable mytypedir = sprintf ("%s/%s", path_dirname (__FILE__),
  path_basename_sans_extname  (__FILE__));

private define setinfoline (self, buf, frame, len)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), buf, frame, len
      ;;__qualifiers ());
}

private define addframe (self)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ());;__qualifiers ());
}

private define executeargv (self, argv)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), argv;;__qualifiers ());
}

private define readline (self)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ());;__qualifiers ());
}

private define writetofifo (self, str)
{
  variable
    fp,
    isrunning = NULL == self.pid ? -1 : pid_status (self.pid);

  if (-1 == isrunning)
    {
    () = waitpid (self.pid, 0);
    isrunning = 0;
    }

  ifnot (isrunning)
    if (strncmp (str, "loadlist", strlen ("loadlist")))
      return;
    else
      if (-1 == self.exec (sprintf ("%s/mplayer_proc", mytypedir),
        self.outputfile, self.msgbuf))
        {
        srv->send_msg ("Failed to create mplayer process", -1);
        return;
        }

  fp = fopen (self.fifo, "w");
  () = fprintf (fp, "%s\n", str);
  () = fclose (fp);

  sleep (0.2);
}

private define atexit (self)
{
  self.quit ();
}

private define setsoundcard_crouton (self)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()));
}

private define setsoundcard ()
{
  variable
    card = NULL,
    self;

  if (2 == _NARGS)
    card = ();

  self = ();

  self.exec (sprintf ("%s/%s", mytypedir, _function_name ()), card;;__qualifiers ());
}

private define getinfo (self)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ());;__qualifiers ());
}

private define getcurplaying (self)
{
  self.exec (sprintf ("%s/%s", mytypedir, _function_name ());;__qualifiers ());
}

private define quit (self)
{
  self.writetofifo ("quit");
 
  if (NULL == self.pid)
    return;
 
  variable status = pid_status (self.pid);

  if (1 == status)
    () = kill (self.pid, SIGKILL);
  else if (-1 == status)
    () = waitpid (self.pid, 0);
}

private define stop (self)
{
  self.writetofifo ("stop");
}

define main (self, name)
{
  variable
    i,
    ar,
    st,
    fp,
    retval,
    amixer,
    iscrouton = which ("croutonversion"),
    histfile = sprintf ("%s/data/.history.txt", mytypedir),
    mediacommands = [
      "0", "9", "1", "2", "v", "a", "m",
      "f", "b", "F", "B", "n", "p", "kill",
      "mediapause", "l", "closeshell",
      "stop", "r", "i", "RefreshLyrics", "tooglesoundcard"],
    sorted = array_sort (mediacommands),
    mediacommandshelp = [
      "raise volume",
      "lower volume",
      "lower volume 1",
      "raise volume 1",
      "play media file[s] in Random order (a directory is an acceptable argument)",
      "play media file[s] alphabetically (a directory is an acceptable argument)",
      "mute",
      "seek forward (small step)",
      "seek backward (small step)",
      "seek forward (big step)",
      "seek backward (big step)",
      "play next song to the playlist",
      "play prev song to the playlist",
      "kiill! IT",
      "pause playing",
      "show playlist",
      "close shell (if exists)",
      "stop player",
      "refresh display",
      "show information",
      "refresh lyrics db",
      "toogle soundcard"],
    mplayer = which ("mplayer");

  if (NULL == mplayer)
    {
    srv->send_msg_and_refresh ("mplayer is not installed", -1);
    throw Return, " ", NULL;
    }

  amixer = which ("amixer");
  if (NULL == amixer)
    {
    (mediacommands[0], mediacommands[1], mediacommands[2], mediacommands[3],
     mediacommandshelp[0], mediacommandshelp[1], mediacommandshelp[2], mediacommandshelp[3]) =
      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;

    mediacommands = mediacommands[wherenot (_isnull (mediacommands))];
    mediacommandshelp = mediacommandshelp[wherenot (_isnull (mediacommandshelp))];
    sorted = array_sort (mediacommands);
    srv->send_msg ("amixer is missing, you can't control the volume throw program", -1);
    }

  root.windows[name] = struct
    {
    @root.windows[name],
    setinfoline = &setinfoline,
    addframe = &addframe,
    atexit = &atexit,
    writetofifo = &writetofifo,
    setsoundcard = NULL == iscrouton ? &setsoundcard : &setsoundcard_crouton,
    getinfo = &getinfo,
    getcurplaying = &getcurplaying,
    stop = &stop,
    quit = &quit,
    conf = sprintf ("%s/data/input.conf", mytypedir),
    fifo = sprintf ("%s/%s/Constant_mplayer_fifo", TMPDIR, name),
    fd_fifo,
    playlistfile = sprintf ("%s/%s/playlist.txt", TMPDIR, name),
    lyricsdir = sprintf ("%s/data/lyrics", PERSNS),
    todolyricfile = sprintf ("%s/data/todo/lyrics", PERSNS),
    outputfile = sprintf ("%s/%s/output.txt", TMPDIR, name),
    pat = "^Playing.*\\056$",
    mediaext = [".mp3", ".ogg", ".mp4", ".mpg", ".avi", ".m4v", ".mkv", ".mp4", ".mov", ".flv", ".AVI"],
    soundcards = Integer_Type[0],
    mute = 0,
    soundchannels = String_Type[0],
    defaultsoundcard = 1,
    amixer = amixer,
    amixerargv,
    argv,
    pid,
    lyrics,
    cur = struct
      {
      @root.windows[name].cur,
      soundcard,
      soundchannel,
      command,
      lyric
      },
    };

  variable me = root.windows[name];

  me.minframes = 2;
  me.frame_size = 5;

  me.readline = struct
    {
    @self.addreadline (),
    help = mediacommandshelp[sorted],
    mode = "media"
    };

  me.readline.readline = &readline;
  me.readline.executeargv = {&executeargv, me.readline.executeargv};
  me.readline.commands =
    {
    mediacommands[sorted],
    COMMANDS
    };

  me.history = self.addhistory (;file=histfile);
  me.history.read ();

  me.cur.mode = "";

  st = stat_file (me.fifo);
  ifnot (NULL == st)
    {
    ifnot (stat_is ("fifo", st.st_mode))
      {
      srv->send_msg (sprintf ("%s: Is not a fifo file", me.fifo), -1);
      throw Return, " ", NULL;
      }
    }
  else
    () = mkfifo (me.fifo, 420);
 
  variable vers = me.exec (sprintf ("%s/check_vers", mytypedir));

  if (1 == vers)
    me.argv = [mplayer,
      "-utf8",
      "-slave",
      "-idle",
      "-fs",
      "-msglevel", "all=-1:global=5",
      "-input", sprintf ("file=%s", me.fifo),
      "-input", sprintf ("nodefault-bindings:conf=%s", me.conf)];
  else
    me.argv = [mplayer,
      "--slave",
      "--idle",
      "--fs",
      "--msglevel=all=-1:global=5",
      sprintf ("--input=file=%s", me.fifo),
      sprintf ("--input=nodefault-bindings:conf=%s", me.conf)];

  me.setsoundcard ();

  if (NULL == iscrouton)
    if (1 == vers)
      me.argv = [me.argv, "-ao", sprintf ("alsa:device=hw=%d.0", me.cur.soundcard)];
    else
      me.argv = [me.argv, sprintf ("--ao=alsa:device=hw=%d.0", me.cur.soundcard)];

  if (-1 == me.exec (sprintf ("%s/mplayer_proc", mytypedir), me.outputfile, me.msgbuf))
    {
    srv->send_msg ("Failed to create mplayer process", -1);
    throw GotoPrompt;
    }

  loop (2)
    me.addframe (;;__qualifiers ());

  throw Return, " ", 0;
}
