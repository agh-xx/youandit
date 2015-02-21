define main ()
{
  variable
    chr,
    ar = [['A':'Z'], ['a':'z']],
    msg = qualifier ("msg", "Please enter an English char");

  srv->send_msg (msg, 0);

  srv->write_prompt (NULL, 0;prompt_char = "");
 
  chr = input->en_getch ();
 
  while (0 == any (chr == ar))
    chr = input->en_getch;
 
  srv->send_msg ("", 0);
  srv->write_prompt (NULL, 0;prompt_char = "");

  throw Return, " ", chr;
}
