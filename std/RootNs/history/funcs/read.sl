define main (self)
{
  variable ar = readfile (self.file);
  if (NULL == ar || 0 == length (ar))
    throw Break;

  ar = ar[where (strlen (ar))];
 
  if (length (ar))
    self.list = ar;

  throw Break;
}
