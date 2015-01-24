define main (self)
{
  self.soundcards = [0];
  self.soundchannels = [NULL];
  self.cur.soundcard = NULL;
  self.cur.soundchannel = "Master";

  self.amixerargv = NULL == self.amixer ? NULL : sprintf ("%s -q set %s ", self.amixer, self.cur.soundchannel);
  throw Break;
}
