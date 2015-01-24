define main (self, buf, linenr, prompt_char)
{
  self.index = @linenr;
  self.dothesearch (;;__qualifiers ());

  if (self.retval)
    {
    @linenr = self.linenr;
    srv->send_msg (sprintf ("row %d col %d|%s", @linenr, self.start,
       (@CW.getbufline) (CW, buf, qualifier ("file", buf.fname), @linenr)), 0);
    srv->set_color_in_region (COLOR.info, MSGROW,
        strlen (sprintf ("row %d col %d|", @linenr + 1, self.start)) + self.start, 1,
        self.end - self.start);
    }
  else
    srv->send_msg ("", 0);

  srv->write_prompt (self.pattern, strlen (self.pattern) + 1; prompt_char = prompt_char);
}
