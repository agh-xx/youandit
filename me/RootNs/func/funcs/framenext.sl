define main ()
{
  if (1 == CW.frames)
    {
    if (qualifier_exists ("dont_goto_prompt"))
      srv->send_msg_and_refresh ("There is only one frame", 1);
    else
      srv->send_msg ("There is only one frame", 1);

    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;

    throw GotoPrompt;
    }

  variable
    new = CW.frames == CW.cur.frame + 1 ? 0 : CW.cur.frame + 1;

  CW.dim[CW.cur.frame].infolinecolor = COLOR.info;

  CW.dim[new].infolinecolor = COLOR.activeframe;
  CW.writeinfolines ();
 
  if ("Shell_Type" == CW.type)
    {
    CW.cur.mainbuf = CW.buffers[new].fname;
    CW.cur.mainbufframe = new;
    }

  CW.cur.frame = new;

  if (qualifier_exists ("dont_goto_prompt"))
    throw Break;

  throw GotoPrompt;
}
