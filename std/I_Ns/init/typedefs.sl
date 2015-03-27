typedef struct
  {
  type, name, fname, ar_len, fp,
  firstchar, indices, linefirst,
  pos, rows, infoline, mtime,
  } Frame_Type;

typedef struct
  {
  stdin,
  stdout,
  stderr,
  status,
  pid,
  env,
  argv,
  retval,
  fg,
  cleanup,
  } Init_ProcType;

typedef struct
  {
  str,
  ar,
  file,
  wr_flags,
  mode,
  keep,
  write,
  read,
  } Init_DescrType;


typedef struct
  {
  col,
  clr,
  str,
  } Img_Type;
