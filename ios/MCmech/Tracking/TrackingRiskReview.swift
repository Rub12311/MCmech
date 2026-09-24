// MCmech tracking risk review and implementation order. Comments only.
// These are design risks, not observed runtime defects: no tracker exists yet.
//
// FIRST MILESTONE
// One manually selected stationary component, one rear camera, live selection,
// camera movement within a tested range, approximate region arrow, local processing.
// No promise of exact feature attachment, automatic naming, persistent identity
// after loss, or tracking through a fully hidden object.
//
// PRIORITY 1: WRONG TARGET WITH A CONFIDENT ARROW
// Similar bolts, hoses, reflections, and background texture can attract the box.
// Confidence and smooth motion do not prove identity. Measure false locks using
// annotated clips containing near-identical neighbors. Manual reselection is
// the first recovery method. If wrong locks remain common, restrict supported
// targets or evaluate an independent appearance check; do not just lower thresholds.
// An appearance check must itself be validated across lighting and view changes.
//
// PRIORITY 1: SELECTION / FRAME MISMATCH
// Use live selection instead of the earlier frozen-frame replay proposal.
// Capture selection coordinates with frame metadata, reject stale initialization,
// and display Acquiring before the active arrow. Test phone motion during Track.
//
// PRIORITY 1: ARROW LAGS OR IS OFFSET
// Spatial correctness requires consistent crop, rotation, and mirroring transforms.
// Temporal correctness requires result age checks: an accurate old box over a newer
// preview is still misplaced. Measure frame-to-render age separately from model
// execution time. Prefer hiding stale output to aggressive unvalidated prediction.
// Smoothing operates only on accepted observations and resets after loss.
//
// PRIORITY 2: OCCLUSION, VIEW CHANGE, OR SMALL TARGET
// Hands and tools can obscure the part. Walking around a 3D part changes its
// appearance and its bounding-box center. Thin hoses and tiny bolts may have too
// few useful pixels, and a box may include more background than target.
// Prompt the user to reposition for a clear view. Do not infer a hidden location.
// If an exact surface point is required later, evaluate feature correspondences
// or segmentation; a constant offset inside a box is not a stable physical point.
//
// PRIORITY 2: CAMERA / DEVICE LIMITS
// Near-focus limits, glare, darkness, blur, thermal throttling, and camera changes
// can degrade results. Benchmark on the oldest intended device and a newer one.
// Use bounded work, inspect dropped frames, and lower capture rate/resolution only
// after checking that small-target accuracy remains usable. Reset on interruptions.
//
// STATE TRANSITIONS
// Preview -> selecting -> acquiring -> tracking after enough valid fresh evidence.
// Marginal evidence -> uncertain, with no confident arrow; brief recovery must
// remain continuous and plausible. Severe failure, timeout, or target exit -> lost.
// Lost -> explicit reselection, never blind automatic resume on a nearby object.
// Stop/background/camera interruption invalidates in-flight results and the target.
// Confidence hysteresis, acquisition duration, and timeouts are tunable values;
// choose them using validation data rather than presenting arbitrary guarantees.
//
// BUILD ORDER AND DECISION GATES
// 1. Camera + selection + coordinate overlays. Prove corner/center mapping across
//    supported orientations and screen sizes before adding tracking.
// 2. Single Vision track + timestamped raw boxes + explicit lifecycle states.
//    Run recorded clips deterministically and inspect identity failures.
// 3. Lost-target behavior + stale-result rejection + reselection. Simulate delayed
//    results, backgrounding, and session restarts; old arrows must never reappear.
// 4. Arrow styling and modest smoothing. Compare raw/smoothed output during motion;
//    quantify lag and jitter instead of judging only a stationary demo.
// 5. Held-out engine-bay clips and physical-device sessions, including sustained
//    use. Record failures as well as successful intervals and thermal behavior.
// 6. Decide whether Vision meets the intended target set before adding YOLO or
//    a more complex tracker. YOLO recognition alone cannot fix instance identity.
//
// EVALUATION CONTRACT
// Record target pixel size, light/view conditions, annotated identity and boxes,
// visible versus occluded intervals, device, capture settings, and clip duration.
// Report box overlap and center error relative to target size, false-lock duration,
// lost-target detection time, useful tracking coverage, and reselection frequency.
// Report latency distribution, peak memory, drops, and sustained thermal behavior.
// Include coverage to prevent a tracker that always hides from appearing successful.
// Hard functional checks: no cross-session stale arrows and no automatic recovery
// after declared loss. Statistical accuracy thresholds need baseline measurements
// and an agreed user tolerance; no elite-quality claim is justified yet.
