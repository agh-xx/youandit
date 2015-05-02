ineed ("initfunctions");

set_img ();

private define _vedloop_ (s)
{
  forever
    {
    count = -1;
    cf_._chr = get_char ();
 
    if ('1' <= cf_._chr <= '9')
      {
      count = "";
 
      while ('0' <= cf_._chr <= '9')
        {
        count += char (cf_._chr);
        cf_._chr = get_char ();
        }

      count = integer (count);
      }

    if (any (pagerc == cf_._chr))
      (@pagerf[string (cf_._chr)]);
 
    if (':' == cf_._chr)
      rlf_.read ();

    if (cf_._chr == 'q')
      (@clinef["q"]) (;force);
    }
}

vedloop = &_vedloop_;

define ved (s)
{
  cf_ = @Frame_Type;
 
  cf_._maxlen = COLUMNS;
  cf_._fname = get_file ();
  cf_.st_ = stat_file (cf_._fname);
  if (NULL == cf_.st_)
    cf_.st_ = struct
      {
      st_atime,
      st_mtime,
      st_uid = getuid (),
      st_gid = getgid (),
      st_size = 0
      };

  cf_.rows = get_rows ();
  cf_._indent = 0;
  cf_._linlen = cf_._maxlen - cf_._indent;
  cf_.lines = getlines (cf_);
  cf_._flags = 0;
 
  cf_.ptr = Integer_Type[2];

  write_prompt (" ", 0);
  cf_._len = length (cf_.lines) - 1;
  cf_.cols = Integer_Type[length (cf_.rows)];
  cf_.cols[*] = 0;
  cf_.clrs = Integer_Type[length (cf_.rows)];
  cf_.clrs[*] = 0;
  cf_.clrs[-1] = INFOCLRFG;
  cf_._avlins = length (cf_.rows) - 2;
  cf_.ptr[0] = cf_.rows[0];
  cf_.ptr[1] = cf_._indent;
  cf_._findex = cf_._indent;
  cf_._index = cf_._indent;
  cf_.undo = String_Type[0];
  cf_._undolevel = 0;
  cf_.undoset = {};

  cf_._i = 0;

  s.draw ();

  variable func = get_func ();

  if (func)
    {
    count = get_count ();
    if (any (pagerc == func))
      (@pagerf[string (func)]);
    }

  if (DRAWONLY)
    return;
 
  topline_dr (" -- PAGER --");

  (@vedloop) (s);
}
