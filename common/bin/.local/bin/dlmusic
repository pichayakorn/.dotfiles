#!/bin/zsh

show_help() {
  cat << 'HELP'
Usage: dlmusic [OPTIONS] <URL> [YT-DLP OPTIONS...]

Downloads YouTube video or playlist as high-quality MP3 (320kbps / V0)
with embedded metadata and square-cropped thumbnail.

Playlist Detection:
  - If a playlist URL is detected (e.g. playlist?list=...), it downloads
    all tracks into a folder named after the playlist, sets the "Track Number"
    metadata tag to the playlist index, and sets "Album" to the playlist title.
  - If a video URL with a playlist parameter is detected (watch?v=...&list=...),
    it prompts whether to download the single track or the entire playlist.

Filename Length Protection:
  - If artist information is too long (over 60 chars or many contributors),
    the artist is automatically omitted from the filename to prevent
    filesystem "File name too long" errors, saving as simply "<Title>.mp3".
  - Full artist information is still preserved in the embedded MP3 metadata tags.

Options:
  -p, --playlist    Force playlist mode (embed track numbers & playlist folder)
  -s, --single      Force single track mode (ignore playlist parameters)
  -h, --help        Show this help message

Examples:
  dlmusic "https://www.youtube.com/watch?v=VIDEO_ID"
  dlmusic "https://www.youtube.com/playlist?list=PLAYLIST_ID"
  dlmusic -s "https://www.youtube.com/watch?v=VIDEO_ID&list=PLAYLIST_ID"
  dlmusic -p "https://www.youtube.com/watch?v=VIDEO_ID&list=PLAYLIST_ID"
  dlmusic --playlist-items 1:5 "https://www.youtube.com/playlist?list=..."
HELP
}

# Check dependencies
if ! command -v yt-dlp >/dev/null 2>&1; then
  echo "Error: yt-dlp is not installed or not in PATH." >&2
  exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "Error: ffmpeg is not installed or not in PATH." >&2
  exit 1
fi

# Help flag check
for arg in "$@"; do
  if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
    show_help
    exit 0
  fi
done

is_url() {
  [[ "$1" =~ ^https?:// || "$1" =~ ^www\. || "$1" =~ youtube\.com || "$1" =~ youtu\.be ]]
}

URL=""
RAW_ARGS=()

for arg in "$@"; do
  if [[ -z "$URL" ]] && is_url "$arg"; then
    URL="$arg"
  else
    RAW_ARGS+=("$arg")
  fi
done

MODE=""
EXTRA_ARGS=()

for arg in "${RAW_ARGS[@]}"; do
  case "$arg" in
    -p|--playlist)
      MODE="playlist"
      ;;
    -s|--single|--no-playlist)
      MODE="single"
      ;;
    --yes-playlist)
      MODE="playlist"
      ;;
    *)
      EXTRA_ARGS+=("$arg")
      ;;
  esac
done

# Fallback: if URL was not matched by regex, take the last non-flag argument
if [[ -z "$URL" ]]; then
  for (( i=${#EXTRA_ARGS[@]}; i>=1; i-- )); do
    if [[ ! "${EXTRA_ARGS[$i]}" =~ ^- ]]; then
      URL="${EXTRA_ARGS[$i]}"
      EXTRA_ARGS[$i]=()
      break
    fi
  done
fi

if [[ -z "$URL" ]]; then
  echo "Error: No URL provided." >&2
  echo ""
  show_help
  exit 1
fi

has_list=0
has_video=0

if [[ "$URL" == *"list="* || "$URL" == *"/playlist"* ]]; then
  has_list=1
fi

if [[ "$URL" == *"v="* || "$URL" == *"youtu.be/"* ]]; then
  has_video=1
fi

if [[ -z "$MODE" ]]; then
  if (( has_list == 1 && has_video == 1 )); then
    if [[ -t 0 ]]; then
      echo ""
      echo "🔍 Detected video URL containing a playlist parameter."
      echo "   [1] Download full playlist (Track Number = playlist index, Folder = Playlist)"
      echo "   [2] Download single video only"
      echo -n "   Choose [1/2] (default: 1): "
      read -r CHOICE
      if [[ "$CHOICE" == "2" ]]; then
        MODE="single"
      else
        MODE="playlist"
      fi
      echo ""
    else
      MODE="playlist"
    fi
  elif (( has_list == 1 )); then
    MODE="playlist"
  else
    MODE="single"
  fi
fi

COMMON_ARGS=(
  -x
  --audio-format mp3
  --audio-quality 0
  --embed-metadata
  --embed-thumbnail
  --ppa "ThumbnailsConvertor+ffmpeg_o:-c:v mjpeg -vf crop=ih:ih"
  --parse-metadata "%(artist,uploader|)s:(?P<short_artist>^.{1,60}$)"
  --parse-metadata ":(?P<description>)"
  --parse-metadata ":(?P<synopsis>)"
  --trim-filenames 180
)

if [[ "$MODE" == "playlist" ]]; then
  echo "🎵 [dlmusic] Mode: Playlist"
  echo "📁 Destination: <Playlist>/<Track#> - [<Artist> - ]<Title>.mp3"
  echo "🏷️  Metadata: Track Number = playlist index | Album = playlist title"
  echo "⏳ Starting download..."
  echo ""
  PLAYLIST_ARGS=(
    --yes-playlist
    --ignore-errors
    --parse-metadata "%(playlist_index|)s:%(track_number)s"
    --parse-metadata "%(playlist_title|)s:%(album)s"
    -o "%(playlist_title)s/%(playlist_index)02d - %(short_artist&{} - |)s%(title)s.%(ext)s"
  )
  exec yt-dlp "${COMMON_ARGS[@]}" "${PLAYLIST_ARGS[@]}" "${EXTRA_ARGS[@]}" "$URL"
else
  echo "🎵 [dlmusic] Mode: Single Track"
  echo "📁 Destination: [<Artist> - ]<Title>.mp3"
  echo "⏳ Starting download..."
  echo ""
  SINGLE_ARGS=(
    --no-playlist
    -o "%(short_artist&{} - |)s%(title)s.%(ext)s"
  )
  exec yt-dlp "${COMMON_ARGS[@]}" "${SINGLE_ARGS[@]}" "${EXTRA_ARGS[@]}" "$URL"
fi
