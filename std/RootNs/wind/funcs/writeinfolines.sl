define main (self)
{
  variable
    i,
    framename,
    ar = String_Type[0],
    lines = array_map (Integer_Type, &get_struct_field, self.dim, "infoline"),
    colors =array_map (Integer_Type, &get_struct_field, self.dim, "infolinecolor");

  _for i (0, self.frames - 1)
    {
    framename = self.buffers[i].name;
    if (NULL == framename)
      {
      ar = [ar, repeat (" ", COLUMNS)];
      continue;
      }

    ar = [ar, self.buffers[i].infoline];

    self.img[lines[i]].str = ar[-1];
    self.img[lines[i]].col = 0;
    self.img[lines[i]].clr = colors[i];
    }

  srv->write_ar_at (ar, colors, lines, 0);
}
