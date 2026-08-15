# Need the number of frames in the video so that the first and last can be cropped.

set -eu

frame_count() {
    ffprobe -count_frames -v error -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 "$1"
    }

print_info() {
    local input="$1"

    echo "Filename:   $input"
    echo "Framecount: $(frame_count "$input")"
    echo "Duration: $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input")s"
    }

# https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
trim_video() {
    local input="$1" start="$2" duration="$3" # expansion happens before assignment;
    local output="${input%.*}-trim.mp4"       # split lines or $input is empty.
    echo "Trimming $input from ${start}s for ${duration}s to $output."
    ffmpeg -y -ss "$start" -i "$input" -t "$duration" -c:v libx264 -c:a aac "$output"
	   echo "Trimmed video written to $output."
    }

# https://www.ffmpeg-micro.com/blog/ffmpeg-loop-video-stream-loop-filter
# The above page has a 90% solution but does not crop the first and last frames before
# concatenating a reversed video; this will cause a visual "hang" each time the video
# reverses, because it will be playing the same frame twice in a row as it turns around.
# The solution below takes the input video, copies, trims the endpoint frames, then
# concatenates.
make_periodic() {
    local N input="$1"
    N=$(frame_count "$input")
    ffmpeg -i "$input" -filter_complex \
	   "[0:v]split[v1][v2]; \
	   [v2]reverse,trim=start_frame=1:end_frame=$((N-1)),setpts=PTS-STARTPTS[v2r]; \
	   [v1][v2r]concat=n=2:v=1:a=0[out]" \
	   -map "[out]" "${input%.*}-loop.mp4"
    }

usage() {
    cat <<SCHLUSS

Usage: $(basename "$0") {info|trim|loop} <args>

Commands:
    info <input>                    Print the filename, framecount, and duration.
    trim <input> <start> <duration> Trim a video at <start>s for <duration>s.
    loop <input>                    Create a video that loops seamlessly by reversing.

SCHLUSS
}

case "${1:-}" in
    info) print_info "$2" ;;
    trim) shift; trim_video "$@" ;;
    loop) shift; make_periodic "$@" ;;
    -h|--help|"") usage ;;
    *) usage >&2; exit 1 ;;
esac
