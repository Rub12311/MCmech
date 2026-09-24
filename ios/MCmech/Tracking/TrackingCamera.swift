// MCmech camera and frame-coordinate plan. Comments only; no implementation.
//
// Use AVFoundation for the first camera-only prototype. Request camera access
// when entering this feature and handle denial, interruption, and app backgrounding.
// Later ARKit integration must supply frames through its own session rather than
// running a second camera capture session alongside it.
//
// Give each frame a timestamp, pixel buffer, orientation, and session generation.
// Serialize Vision work off the main thread; keep the UI responsive.
// During normal tracking, bound pending work and avoid building a stale queue.
// Long time gaps require reacquisition rather than silently retaining the lock.
// Retain only bounded working frames; release on stop or reset. Do not buffer
// the entire selection interaction. Avoid retaining capture-owned buffers long
// enough to exhaust the capture pool. Copy only when a bounded use requires it.
// Discard late capture frames and keep at most one pending latest frame in the
// application worker as well; capture-level dropping does not bound a separate
// async task queue. Record timestamp gaps and dropped-frame reasons.
// Source: https://developer.apple.com/library/archive/technotes/tn2445/_index.html
// Measure processing time and thermal behavior on the actual target iPhone.
//
// Centralize conversions between view coordinates and Vision's normalized image
// coordinates. Account for lower-left versus upper-left origins, image orientation,
// aspect-fill crop, preview dimensions, and mirroring. Test forward and inverse
// mappings; do not simply multiply a normalized box by the screen dimensions.
// Preserve the transform associated with the selected frame and each result.
//
// Publish timestamped observations to the overlay. Reject results from an old
// selection or camera session. On rotation or camera configuration changes,
// explicitly recompute transforms and reset tracking when continuity is invalid.
// Start with one rear physical camera and no zoom controls. Avoid automatic lens
// switching during a track. Handle focus hunting and exposure changes as possible
// causes of poor observations, especially close to small shiny engine components.
