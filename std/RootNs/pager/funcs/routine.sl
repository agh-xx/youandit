define main (self, buf, frame, len)
{
  root.topline ();

  srv->gotorc (buf.pos[0], buf.pos[1]);

  self.setinfoline (buf, frame, len);

  srv->write_str_at (buf.infoline, qualifier ("color", COLOR.activeframe),
    self.dim[frame].infoline, 0);

  srv->gotorc (buf.pos[0], buf.pos[1]);
  srv->refresh ();
}
