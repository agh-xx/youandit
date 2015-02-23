define main (self)
{
  variable
    dir,
    bat,
    charging,
    remain,
    capacity,
    sysorproc = access ("/proc/acpi/battery/", F_OK);

  if (-1 == sysorproc)
    {
    dir = "/sys/class/power_supply";
    bat = listdir (dir);

    bat = NULL == bat ? NULL :
    array_map (String_Type, &sprintf, "%s/%s/%s", dir, bat[1],
      ["capacity", "status"]);

    if (NULL == bat)
      throw Return, " ", ["No Battery, nothing to show", string (1)];

    charging = readfile (bat[1])[0];
    capacity = readfile (bat[0])[0];
    remain = (Integer_Type == _slang_guess_type (capacity)) ?
      sprintf ("%.0f%%", integer (capacity)) : "0%";
    }
  else
    {
    dir = "/proc/acpi/battery/";
    bat = listdir (dir)[0];

    bat = NULL == bat ? NULL :
    array_map (String_Type, &sprintf, "%s/%s/%s", dir, bat,
      ["state", "info"]);

    if (NULL == bat)
      throw Return, " ", ["No Battery, nothing to show", string (1)];

    variable
      line_state = readfile (bat[0]; end = 5)[[2:]],
      line_info = readfile (bat[1]; end = 3)[-1];

    charging = strtok (line_state[0])[-1];
    capacity = strtok (line_state[2])[-2];
    remain = (Integer_Type == _slang_guess_type (capacity)) ?
      sprintf ("%.0f%%", 100.0 / integer (strtok (line_info)[-2])
          * integer (capacity)) : "0%";
    }
 
  if (qualifier_exists ("dont_goto_prompt"))
    throw Return, " ", [sprintf ("[Battery is %S, remaining %S]", charging, remain),
      sprintf ("%d", 'C' == charging[0] ? 0 : -1)];

  srv->send_msg_and_refresh (sprintf ("[Battery is %S, remaining %S]", charging, remain),
    'C' == charging[0] ? 0 : -1);
 
  throw GotoPrompt;
}
