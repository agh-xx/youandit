define main (self, frame)
{
  if (self.frames - 1 < self.minframes)
    {
    srv->send_msg (sprintf
        ("frames will be less than minframes: %d", self.minframes), -1);
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;

    throw GotoPrompt;
    }

  variable cur = self.cur.frame;

  if (String_Type == typeof (frame))
    frame = atoi (frame);

  if (frame + 1 > self.frames)
    {
    srv->send_msg (sprintf
        ("frame: %d > than current frames: %d (frames numbered from 0)",
         frame, self.frames), -1);

    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;

    throw GotoPrompt;
    }
  
  if (frame <= self.cur.frame)
    self.cur.frame --;

  if (0 > self.cur.frame)
    self.cur.frame = 0;

  self.buffers[frame] = NULL;
  self.buffers = self.buffers[wherenot (_isnull (self.buffers))];

  variable buf = self.buffers[self.cur.frame];

  ifnot (NULL == self.cur.mainbuf)
    self.cur.mainbuf = buf.fname;
 
  ifnot (NULL == self.cur.mainbufframe)
    self.cur.mainbufframe = self.cur.frame;

  self.frames--;

  self.drawwind (;;struct {@__qualifiers (), reread_buf});

  srv->send_msg (sprintf ("frame: %d deleted", frame), 0);
 
  if (qualifier_exists ("dont_goto_prompt"))
    throw Break;

  throw GotoPrompt;
}
