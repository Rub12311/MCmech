// MCmech overlay and validation plan. Comments only; no implementation.
//
// Render a lightweight selection outline and an arrow whose tip follows the
// accepted target rectangle's center. Keep the label outside the selected region
// when space permits, and avoid obscuring the physical part with a large graphic.
// Apply modest time-based smoothing to reduce jitter; reset it for a new target.
// Smoothing must not conceal loss or make an arrow visibly lag a fast-moving part.
// Hide stale results and show Target lost or Reselect instead of a frozen arrow.
// Do not imply pixel-precise attachment: tracking a region is not tracking a
// particular surface feature. Evaluate keypoints or segmentation separately if
// a future requirement is an arrow on an exact bolt head or component boundary.
//
// Validation before calling this high-quality tracking:
// Record consented evaluation clips with annotated target boxes and identities.
// Cover camera pan, scale change, rotation, low light, glare, motion blur, partial
// and full occlusion, similar neighboring parts, and leaving/reentering the frame.
// Keep tuning clips separate from held-out evaluation clips.
// Measure box overlap, false target switches, stationary-marker jitter, time to
// hide after loss, frame-to-overlay latency, dropped frames, memory, and thermals.
// Agree numerical acceptance targets after a baseline on the intended iPhone;
// do not claim elite accuracy or a frame rate before measuring them.
//
// Verify portrait/landscape coordinate mapping, selection-to-live continuity,
// permission denial, background/resume, stale-result rejection, and reselection.
// Prioritize never pointing confidently at the wrong part over uninterrupted
// animation. Device trials are required; simulator-only checks are insufficient.
//
// These files are planning placeholders only. Future implementation will add
// camera usage text, feature navigation, project membership if needed, and tests.
