define set_modified ()
{
  variable
    retval,
    d = diff (cf_.lines, cf_._fname, &retval);

  if (NULL == retval)
    {
    send_msg_dr (d, 1, cf_.ptr[0], cf_.ptr[1]);
    return;
    }
 
  if (-1 == retval)
    {
    % change
    send_msg_dr (d, 1, cf_.ptr[0], cf_.ptr[1]);
    return;
    }

  ifnot (retval)
    {
    send_msg_dr ("found no changes", 0, cf_.ptr[0], cf_.ptr[1]);
    return;
    }

  cf_._flags = cf_._flags | MODIFIED;
 
  UNDO = [UNDO, d];
  list_append (UNDOSET, [qualifier ("_i", cf_._ii), cf_.ptr[0], cf_.ptr[1]]);

  undolevel++;
}

private define undo ()
{
  ifnot (length (UNDO))
    return;

  variable
    retval,
    d = patch (UNDO[undolevel - 1], path_dirname (cf_._fname), &retval);
 
  if (NULL == retval)
    {
    send_msg_dr (d, 1, cf_.ptr[0], cf_.ptr[1]);
    return;
    }
 
  if (-1 == retval || 1 == retval)
    {
    % change
    send_msg_dr (d, 1, cf_.ptr[0], cf_.ptr[1]);
    return;
    }

  cf_.lines = strchop (d, '\n', 0);
  cf_._len = length (cf_.lines) - 1;
 
  cf_._i = UNDOSET[undolevel - 1][0];
  cf_.ptr[0] = UNDOSET[undolevel - 1][1];
  cf_.ptr[1] = UNDOSET[undolevel - 1][2];

  if (1 < undolevel)
    undolevel--;
 
  cf_._flags = cf_._flags | MODIFIED;

  s_.draw ();
}

private define redo ()
{
  if (undolevel == length (UNDO))
    return;

  variable
    retval,
    d = patch (UNDO[undolevel - 1], path_dirname (cf_._fname), &retval);
 
  if (NULL == retval)
    {
    send_msg_dr (d, 1, cf_.ptr[0], cf_.ptr[1]);
    return;
    }
 
  if (-1 == retval || 1 == retval)
    {
    % change
    send_msg_dr (d, 1, cf_.ptr[0], cf_.ptr[1]);
    return;
    }
 
  cf_.lines = strchop (d, '\n', 0);
  cf_._len = length (cf_.lines) - 1;

  cf_._i = UNDOSET[undolevel - 1][0];
  cf_.ptr[0] = UNDOSET[undolevel - 1][1];
  cf_.ptr[1] = UNDOSET[undolevel - 1][2];

  undolevel++;

  cf_._flags = cf_._flags | MODIFIED;

  s_.draw ();
}

pagerf[string ('u')] = &undo;
pagerf[string (keys->CTRL_r)] = &redo;
