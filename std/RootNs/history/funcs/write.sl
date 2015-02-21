define main (self)
{
  ifnot (length (self.list))
      throw Break;

  writefile (self.list, self.file);
  writefile (self.list, strreplace (self.file, BINDIR, SOURCEDIR));

  throw Break;
}
