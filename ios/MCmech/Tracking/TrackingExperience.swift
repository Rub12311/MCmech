// MCmech visual tracking implementation plan. Comments only; no implementation.
//
// Revised recommendation after risk review: adjust a rectangle over the LIVE
// preview and tap Track. Initialize against the corresponding current frame.
// A still photo with arrows only annotates that photo; transferring an old
// selection into live video introduces a separate correspondence problem.
// Start with one manually selected part and Apple's Vision object tracker.
// Defer automatic part recognition, YOLO, ARKit anchors, and distance measurement.
//
// Planned interaction:
// 1. Open the camera and show a short instruction to keep the target visible.
// 2. Show an adjustable rectangle over the live preview, with generous handles.
// 3. Frame a visually distinct part and keep it inside the rectangle.
// 4. Tap Track; capture the selection, frame, and coordinate transform together.
// 5. Show Acquiring until fresh, plausible results support an active arrow.
// 6. Offer Reselect and Stop. Require selection again after target loss.
//
// A frozen-frame selection can become stale while the user edits it. Do not seed
// the current live frame with the old box and assume it still describes the part.
// Defer frozen-frame selection. A future version would need either bounded
// sequence replay that demonstrably catches up or validated target matching
// against the new frame. Neither is needed for the initial live-selection flow.
// Even live preview has latency: bind selection to the displayed frame when
// practical, and reject excessive frame age instead of assuming perfect timing.
//
// Planned states: preview, selecting, acquiring, tracking, uncertain, lost,
// interrupted, and cameraUnavailable. Only tracking shows a confident arrow.
// Display uncertainty in words as well as styling; never show a made-up location.
// The arrow marks an approximate region, not an exact bolt, edge, or 3D point.
// All camera processing is on-device. Do not save footage by default.
