// MCmech visual tracking implementation plan. Comments only; no implementation.
//
// Recommendation: freeze a frame from the live camera, select a target, and
// resume live tracking. A still photo with arrows is easier to build, but only
// annotates that photo. It does not keep an arrow on a part as the phone moves.
// Start with one manually selected part and Apple's Vision object tracker.
// Defer automatic part recognition, YOLO, ARKit anchors, and distance measurement.
//
// Planned interaction:
// 1. Open the camera and show a short instruction to keep the target visible.
// 2. Freeze the preview while retaining the exact frame and its orientation.
// 3. Drag and resize a tight rectangle around a visually distinct part.
// 4. Confirm the selection; show the arrow pointing to the rectangle's center.
// 5. Resume with a short acquisition phase before declaring tracking active.
// 6. Offer Reselect and Stop. Require selection again after target loss.
//
// A frozen-frame selection can become stale while the user edits it. Do not seed
// the current live frame with the old box and assume it still describes the part.
// Plan a bounded frame buffer during selection, then process the sequence from
// the selected frame in order. If the buffer expires or catch-up is too slow,
// ask for a fresh selection. Measure feasibility before committing to this UX;
// a live adjustable rectangle is the fallback if continuity cannot be preserved.
//
// Planned states: preview, selecting, acquiring, tracking, uncertain, lost,
// interrupted, and cameraUnavailable. Only tracking shows a confident arrow.
// Display uncertainty in words as well as styling; never show a made-up location.
// The arrow marks an approximate region, not an exact bolt, edge, or 3D point.
// All camera processing is on-device. Do not save footage by default.
