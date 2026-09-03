# Camera Server — VM Client Quality Issue

**Date:** 2026-07-14  
**Project:** camera-server (RPi5 + IMX219, V4L2 MMAP → WebSocket → Canvas2D)

## Finding

Quality difference between phone and VM browser is **entirely client-side**. Server produces identical 640×480 Q65 JPEG frames (6648 bytes) to every client. Confirmed with 3 simultaneous clients — all get the same bytes.

## Root Cause

1. **No GPU in VM** → `ctx.drawImage()` and CSS `filter` fall back to software rendering with poor interpolation. Phone has hardware bilinear scaling → smooth.
2. **640×480 upscaled on large monitor** → physically larger pixels, more visible blockiness. Phone's small high-DPI screen masks low resolution.
3. **`getImageData()` GPU readback every frame** for client-side motion detection → stalls the rendering pipeline, especially catastrophic in VM without GPU acceleration.

## Server is NOT the Problem

- 56°C, no thermal throttle
- CMA healthy (124 MB free of 128 MB)
- 2ms RTT, 6648 bytes/frame
- Multi-client works fine (~150 FPS per client in pull loop)

## Fixes Applied

1. **Server:** Wired up dead quality selector — `get_frame_at_quality()` encodes from `_latest_bgr` on demand. Zero extra cost for default (medium) since it returns pre-encoded JPEG.
2. **Client:** `imageSmoothingQuality = 'high'` on canvas context for better upscaling.
3. **Client:** Motion detection throttled to every 3rd frame + toggleable — eliminates the expensive `getImageData()` GPU readback on most frames.

## Key Lesson

> When a browser inside a VM reports poor video quality, check GPU acceleration first. The `getImageData()` readback is the #1 performance killer — it forces a full GPU pipeline flush to CPU memory every single frame.
