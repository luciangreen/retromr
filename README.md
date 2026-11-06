# retromr

A talking photo. Upload a picture of yourself, and retromr models the face, animates it, and talks with you in a spoken conversation. It hears you through voice recognition and answers through [newos](https://github.com/luciangreen/newos), using newos's text-to-speech with lip-sync. Nothing appears on screen apart from your face and a close box.

## Run

retromr works best with the newos repository cloned next to it:

```sh
git clone https://github.com/luciangreen/newos
git clone https://github.com/luciangreen/retromr
cd retromr
swipl retromr.pl
```

Then open <http://localhost:8082> in Chrome, Edge or Safari, which have built-in voice recognition.

* If `../newos` exists, retromr loads the newos engine directly and shares its memory (`newos/data/knowledge.pl`). Set `NEWOS_DIR` to use a copy somewhere else.
* Otherwise retromr talks to a running newos server at `NEWOS_URL` (default `http://localhost:8081/api/chat`).

## Using it

1. Tap the glowing circle and choose a photo, or drop one onto the page.
2. retromr finds your eyes and mouth. It tries MediaPipe Face Landmarker (loaded from a CDN), then the browser's FaceDetector, then a skin-tone estimate. If it had to guess, it shows three markers to drag onto your eyes and mouth; tap ✓ when done. The crosshair icon (top left) brings the markers back any time.
3. Just talk. The light at the bottom shows teal when listening, bright when it hears you, amber while thinking, and dim while speaking. Your face blinks, breathes, sways and moves its mouth in time with the voice.
4. **×** closes the session and forgets the photo.

Browsers only allow speech after you've tapped the page. When you come back to a saved face, the light pulses gold until you tap it. If a browser can't do voice recognition, a keyboard icon lets you type instead.

## How it works

| File | What it does |
|---|---|
| `retromr.pl` | Web server: saves the photo and landmarks (`data/face.pl`), builds the animation model, and passes speech to newos |
| `face_model.pl` | Turns landmarks into animation geometry: head roll, the jaw region that drops when speaking, how far it may open, eyelid size, and the neck pivot for head movement |
| `web/index.html` | The page: face finding, a canvas puppet (jaw drop over a mouth cavity, blinks, sway), voice loop |
| `/newos/tts.js` | newos's speech module, served from `../newos/web/tts.js` (a bundled copy in `web/tts.js` is used if newos isn't alongside) |
| `paint.pl` | The retro paint primitives from `specs/retromr_spec.pl`: move mouse, paint point, draw line, delete point, delete screen |

## Tests

```sh
swipl -g run_tests -t halt tests/test_retromr.pl
```

These cover the face model and the spec's paint examples. Two spec examples look like slips, and the tests use the intended result instead: the "left" move grid is garbled, and the vertical "draw line" expects a blank screen.
