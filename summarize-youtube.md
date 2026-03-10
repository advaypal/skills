# Summarize YouTube Video

Summarize a YouTube video by fetching its transcript and extracting key takeaways.

## Usage
Provide the YouTube video URL as the argument: $ARGUMENTS

## Steps

1. **Get video metadata**: Fetch the oEmbed endpoint to get the title and author:
   - URL: `https://www.youtube.com/oembed?url=<VIDEO_URL>&format=json`

2. **Extract the video ID** from the URL (the `v=` parameter or the path after `youtu.be/`).

3. **Fetch the transcript** using the `youtube-transcript-api` Python package:
   ```bash
   python3 -c "
   from youtube_transcript_api import YouTubeTranscriptApi
   ytt_api = YouTubeTranscriptApi()
   transcript = ytt_api.fetch(video_id='<VIDEO_ID>')
   for snippet in transcript:
       print(snippet.text)
   "
   ```
   - If the package is not installed, install it first: `pip3 install youtube-transcript-api`
   - The transcript output may be very large. Read the full output file to get complete context.

4. **Read the entire transcript** before summarizing. If the output is saved to a file, read it in chunks to cover everything.

5. **Summarize** the transcript with the following structure:
   - Start with the video title, channel name, and a one-line description
   - List **key takeaways** as numbered sections with bold headers
   - Under each takeaway, provide 3-5 bullet points with the most important details
   - Use specific facts, numbers, names, and quotes from the transcript
   - Capture contrarian or surprising viewpoints
   - Note any predictions made
   - End with any concluding statements or final answers to key questions

## Notes
- YouTube pages are heavily JS-rendered, so direct web fetching won't extract transcript content
- The `youtube-transcript-api` package is the reliable method for getting transcripts
- Some videos may not have transcripts available (no captions) — inform the user if this happens
