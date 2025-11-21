

String getSoundPath(String path){
  List<String> parts = path.split('.');
  return ["mp3", "wav", "ogg", "flac"].contains(parts.last) ? path : "The file isn't readable";
}

/*class Sound{
  Sound({required this.path}){
    if (path == "") {
      print("The file isn't readable");
    }
    album = f.getAudioTags(path).album;
    artist = f.getAudioTags(path).artist;
    year = f.getAudioTags(path).year;
    genre = f.getAudioTags(path).genre;
    title = f.getAudioTags(path).title;
    duration = f.getAudioTags(path).duration;
    
  }
  Future<void> initializeMetadata() async {
    Metadata meta = await MetadataRetriever.fromFile(File(path));
    print("mm ${meta.trackName.toString()}");
    album = meta.albumName.toString() != "" ? meta.albumName.toString() : "Unknown";
    artist = meta.trackArtistNames != null ? meta.trackArtistNames!.join(", ") : "Unknown";
    year = meta.year != null ? meta.year!.toInt() : -1;
    genre = meta.genre.toString() != "" ? meta.genre.toString() : "Unknown";
    title = meta.trackName.toString() != "" ? meta.trackName.toString() : "Unknown";
    duration = meta.trackDuration != null ? meta.trackDuration!~/1000 : 00;
    print("$album $artist $title $genre $year $duration");
  }

  final String path;
  late final String album;
  late final String genre;
  late final String title;
  late final String artist;
  late final int year;
  late final int duration;
  late final int id;
  bool isInitialized = false;
}*/