define main (self)
{
  self.writetofifo ("get_audio_codec\nget_audio_bitrate\nget_video_codec\nget_video_bitrate\nget_video_resolution\nget_meta_title\nget_meta_artist\nget_meta_album\nget_meta_year\nget_meta_comment\nget_meta_track\nget_meta_genre\n");
  variable ar = readfile (self.outputfile);
  ar = ar[[length (ar) - 12:]];
  ar = array_map (String_Type, &substr, ar, 5, -1);
 
  root.lib.printtostdout (ar;header = "MEDIA INFORMATION");
}
