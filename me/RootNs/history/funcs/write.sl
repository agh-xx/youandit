define main (self)
{
  ifnot (length (self.list))
      throw Break;

  writefile (self.list, self.file);
  writefile (self.list, strreplace (self.file, ROOTDIR, SOURCEDIR));

  throw Break;
}
