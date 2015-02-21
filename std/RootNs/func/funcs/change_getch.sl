define main (self)
{
  variable
    msg,
    cur = string (getchar_lang);

  if ("input->en_getch" == cur[[1:]])
    {
    getchar_lang = &input->el_getch;
    msg = "language changed from english to hellenic";
    }
  else
    {
    getchar_lang = &input->en_getch;
    msg = "language changed from hellenic to english";
    }

  srv->send_msg_and_refresh (msg, 0);

  ifnot (qualifier_exists ("goto_prompt"))
    throw Break;

  throw GotoPrompt;
}
