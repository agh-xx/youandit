define main (self)
{
  variable rows = AVAILABLE_LINES - self.frames;

  self.frames_size = Integer_Type[self.frames];
 
  ifnot (NULL == qualifier ("frame_size"))
    {
    variable
      i,
      frame_size = qualifier ("frame_size");

    self.frames_size[0] = rows - ((self.frames - 1) * frame_size);

    _for i (1, self.frames - 1)
      self.frames_size[i] = frame_size;
    }
  else
    {
    self.frames_size[*] = rows / self.frames;
    self.frames_size[0] += rows mod self.frames;
    }
}
