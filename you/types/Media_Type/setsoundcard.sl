define main (self, card)
{
  variable
    i = 0,
    fp,
    ref;

  forever
    {
    fp = popen (sprintf ("amixer -c %d controls 2>/dev/null", i), "r");
    () = fgets (&ref, fp);
    ifnot (strncmp (ref, "Usage", 5))
      break;
    self.soundcards = [self.soundcards, i];
    self.soundchannels = [self.soundchannels, strtok (strtok (ref, "'")[1])[0]];
    i++;
    }

  ifnot (NULL == card)
    {
    if (String_Type == typeof (card))
      card = atoi (card);

    if (card < length (self.soundcards))
      {
      self.cur.soundcard = card;
      self.cur.soundchannel = self.soundchannels[card];
      self.amixerargv = NULL == self.amixer ? NULL :
        sprintf ("%s -q %d set %s ", self.amixer, self.cur.soundcard, self.cur.soundchannel);

      throw Break;
      }
    }

  if (1 == length (self.soundcards))
    {
    self.cur.soundcard = 0;
    self.cur.soundchannel = self.soundchannels[0];
    self.amixerargv = NULL == self.amixer ? NULL :
      sprintf ("%s -q -c %d set %s ", self.amixer, self.cur.soundcard, self.cur.soundchannel);
    throw Break;
    }

  if (self.defaultsoundcard < length (self.soundcards))
    {
    self.cur.soundcard = self.defaultsoundcard;
    self.cur.soundchannel = self.soundchannels[self.defaultsoundcard];
    self.amixerargv = NULL == self.amixer ? NULL :
      sprintf ("%s -q -c %d set %s ", self.amixer, self.cur.soundcard, self.cur.soundchannel);
    throw Break;
    }

  self.cur.soundcard = length (self.soundcards) - 1;
  self.cur.soundchannel = self.soundchannels[length (self.soundcards) - 1];
  self.amixerargv = NULL == self.amixer ? NULL :
    sprintf ("%s -q -c %d set %s ", self.amixer, self.cur.soundcard, self.cur.soundchannel);
}
