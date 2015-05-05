ifnot (is_defined ("vedloop"))
  {
  variable vedloop;
  variable getchar_lang;

  ineed ("screenmangmnt");
  ineed ("vedfuncs");
  ineed ("viewer");

  ifnot (DRAWONLY)
    {
    import ("fork");
    import ("pcre");
    
    ineed ("input");
    ineed ("std");
    ineed ("proc", "proc");
    ineed ("writetofile");
    ineed ("diff");
    ineed ("undo");
    ineed ("search");
    ineed ("rline");
    ineed ("visual_mode");
    ineed ("ed");

    ifnot (NULL == DISPLAY)
      ifnot (NULL == which ("xclip"))
        ineed ("seltoX");
    }

  pagerc = array_map (Integer_Type, &integer, assoc_get_keys (pagerf));
  }
