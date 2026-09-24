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
// Bound retained selection frames by time and memory; release on stop or reset.
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
