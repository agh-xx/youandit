private define findtag (line, col, delim)
{
  variable
    i,
    c,
    tag = "",
    found = NULL;

  ifnot (strlen (line))
    return NULL;
 
  if (col < 0)
    return NULL;
 
  _for i (col, 0, -1)
    {
    c = line[i];
    if (c == delim)
      {
      found = 1;
      break;
      }

    tag = char (c) + tag;
    }
 
  if (NULL == found)
   return NULL;

  if (col + 1 == strlen (line))
   if (line[col] != delim)
    return NULL;
   else
     return tag;
 
  found = NULL;

  _for i (col + 1, strlen (line) -1)
    {
    c = line[i];
    if (c == delim)
      {
      found = 1;
      break;
      }

    tag += char (c);
    }

  if (NULL == found)
   return NULL;

  return tag;
}

private define addtags (dir, s)
{
  variable
    i,
    tag,
    file,
    tags = sprintf ("%s/tags.txt", dir);

  ifnot (access (tags, F_OK|R_OK))
    tags = readfile (tags);
  else
    tags = String_Type[0];

  if (NULL == tags)
    tags = String_Type[0];

  _for i (0, length (tags) - 1)
    {
    tag = strchop (tags[i], '\t', 0);

    if (3 == length (tag))
      {
      file = _$ (tag[1]);

      ifnot (access (file, F_OK|R_OK))
        s.tags[tag[0]] = [file, tag[2]];
      }
    }
}

variable Ftype_Type = struct
  {
  dir,
  pager,
  findtag = &findtag,
  addtags = &addtags,
  tags = Assoc_Type[Array_Type],
  stack = {},
  };

() = evalfile (sprintf ("%s/abt_ftype", path_dirname (__FILE__)));
