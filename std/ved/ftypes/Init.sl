public variable
  cf_,
  rl_,
  rlf_,
  count = 0,
  IMG,
  REG = Assoc_Type[String_Type],
  UNDO = String_Type[0],
  UNDOSET = {},
  undolevel = 0,
  clinef = Assoc_Type[Ref_Type],
  clinec,
  pagerf = Assoc_Type[Ref_Type],
  pagerc,
  is_wrapped_line = 0;

typedef struct
  {
  _i,
  _ii,
  _len,
  _chr,
  _type,
  _fname,
  _flags,
  _maxlen,
  _indent,
  _linlen,
  _avlins,
  _findex,
  _index,
  ptr,
  rows,
  cols,
  clrs,
  lins,
  lnrs,
  vlins,
  lines,
  st_,
  } Frame_Type;

typedef struct
  {
  _type,
  _shiftwidth,
  ved,
  draw,
  write_nstr,
  write_str_at,
  write_nstr_dr,
  line,
  quit,
  getlines,
  writefile,
  parsearray,
  } Ftype_Type;

typedef struct
  {
  _row,
  _col,
  _chr,
  _lin,
  _ind,
  lnrs,
  argv,
  cmp_lnrs,
  com,
  } Rline_Type;

private define getlines (s)
{
  variable indent = repeat (" ", cf_._indent);
  if (-1 == access (cf_._fname, F_OK) || 0 == cf_.st_.st_size)
    {
    cf_.st_.st_size = 0;
    return [sprintf ("%s\000", indent)];
    }

  return array_map (String_Type, &sprintf, "%s%s", indent, readfile (cf_._fname));
}

private define quit (t)
{
  () = evalfile (sprintf ("%s/share/%s", path_dirname (__FILE__), _function_name ()), t);

  return __get_reference (sprintf ("%s->%s", t, _function_name ()));
}

private define write_nstr_dr (t)
{
  () = evalfile (sprintf ("%s/share/%s", path_dirname (__FILE__), _function_name ()), t);

  return __get_reference (sprintf ("%s->%s", t, _function_name ()));
}

private define write_nstr (t)
{
  () = evalfile (sprintf ("%s/share/%s", path_dirname (__FILE__), _function_name ()), t);

  return __get_reference (sprintf ("%s->%s", t, _function_name ()));
}

private define write_str_at (t)
{
  () = evalfile (sprintf ("%s/share/%s", path_dirname (__FILE__), _function_name ()), t);

  return __get_reference (sprintf ("%s->%s", t, _function_name ()));
}

private define writetofile (t)
{
  () = evalfile (sprintf ("%s/share/%s", path_dirname (__FILE__), _function_name ()), t);

  return __get_reference (sprintf ("%s->%s", t, _function_name ()));
}

private define ved (t)
{
  () = evalfile (sprintf ("%s/%s", path_dirname (__FILE__), _function_name ()), t);

  return __get_reference (sprintf ("%s->%s", t, _function_name ()));
}

private define draw (t)
{
  () = evalfile (sprintf ("%s/%s/%s", path_dirname (__FILE__), t, _function_name ()), t);

  return __get_reference (sprintf ("%s->%s", t, _function_name ()));
}

define init (ftype)
{
  % TO DO the checks
  variable type = @Ftype_Type;
 
  type._type = ftype;
  type._shiftwidth = 4;
  type.getlines = &getlines;
  type.ved = ved (ftype);
  type.draw = draw (ftype);
  type.write_nstr = write_nstr (ftype);
  type.write_nstr_dr = write_nstr_dr (ftype);
  type.write_str_at = write_str_at (ftype);
  type.quit = quit (ftype);
  type.writefile  = writetofile (ftype);

  return type;
}
