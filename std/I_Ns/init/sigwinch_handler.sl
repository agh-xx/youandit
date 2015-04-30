% REDO
define sigwinch_handler ();

define sigwinch_handler (sig)
{
  % LOOP FOR ALL THE WINDOWS TO SET THE NEW SIZES and draw

  % FOR NOW
  root.settermsize ();

  if (18 > AVAILABLE_LINES)
    root->exit_me (1, "I DONT REALLY WANT TO CONTINUE WITH LESS THAN 18 LINES");

  if (82 > COLUMNS)
    root->exit_me (1, "I DONT REALLY WANT TO CONTINUE WITH LESS THAN 82 COLUMNS");

  variable
    i,
    cw = root.windows[CW.name];

  _for i (0, length (root.windnames) -1)
    {
    if (cw.name == root.windnames[i])
      continue;
    CW = root.windows[root.windnames[i]];
    CW.drawwind (;dont_draw, reread_buf);
    }

  CW = cw;
  CW.drawwind ();

  signal (sig, &sigwinch_handler);
}

signal (SIGWINCH, &sigwinch_handler);
