// MCmech tracking engine plan. Comments only; no implementation.
//
// Seed VNTrackObjectRequest with a VNDetectedObjectObservation made from the
// selected bounding box. Use VNSequenceRequestHandler on ordered camera frames,
// supply the correct orientation, and feed accepted observations into subsequent
// tracking requests. Benchmark the accurate tracking level on the target device.
// Source: https://developer.apple.com/documentation/vision/tracking-multiple-objects-or-rectangles-in-video
//
// Vision follows visual appearance; it does not name parts or guarantee identity.
// Keep one stable app-owned target ID for the current selection. A new selection
// begins a new generation so in-flight results cannot resurrect the old target.
//
// Assess observation confidence alongside elapsed time, box size changes, sudden
// position jumps, and whether the region remains inside the image. Tune thresholds
// on recorded engine-bay footage; confidence is not a calibrated accuracy score.
// Use hysteresis so a single marginal result does not flicker the state, while
// severe failures immediately remove the active arrow. Do not keep feeding an
// obviously incorrect observation into the tracker just to maintain continuity.
//
// After occlusion or loss, ask for reselection in version one. Never automatically
// attach the marker to a similar nearby bolt. Later evaluate detection plus
// appearance matching with explicit ambiguity handling for reacquisition.
// A class label alone cannot distinguish two instances of the same kind of part.
//
// Add YOLO only when automatic selection becomes a requirement and labeled
// automotive examples are available. It can propose candidate regions through
// Core ML; it does not replace temporal tracking or prove instance identity.
