define main (self)
{
  variable frame;

  srv->cls ();

  self.setframesize (;frame_size = qualifier ("frame_size", self.frame_size));
  self.setwindim ();

  _for frame (0, self.frames - 1)
    self.drawframe (frame;;__qualifiers ());

  if (qualifier_exists ("refresh"))
    srv->refresh ();
}
