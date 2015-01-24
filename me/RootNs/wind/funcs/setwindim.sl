define main (self)
{
  variable
    frame,
    start = 1;

  self.dim = Struct_Type[self.frames];

  _for frame (0, self.frames - 1)
    {
    self.dim[frame] = struct
      {
      rowfirst = start,
      rowlast =  self.frames_size[frame] + start - 1,
      infoline = self.frames_size[frame] + start,
      infolinecolor = self.cur.frame == frame ? COLOR.activeframe :
        COLOR.info
      };

    start += self.frames_size[frame] + 1;
    }
}
