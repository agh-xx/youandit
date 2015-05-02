define seltoX ();
variable vedloop;

ifnot (NULL == DISPLAY)
  ifnot (NULL == which ("xclip"))
    ineed ("seltoX");

ineed ("screenmangmnt");
ineed ("vedfuncs");
ineed ("writetofile");
ineed ("diff");
ineed ("undo");
ineed ("viewer");
ineed ("search");
ineed ("rline");
ineed ("visual_mode");
ineed ("ed");

pagerc = array_map (Integer_Type, &integer, assoc_get_keys (pagerf));

set_img ();

