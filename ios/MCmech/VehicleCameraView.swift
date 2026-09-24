import AVFoundation
import SwiftUI
import UIKit

struct VehicleCameraView: View {
    let vehicleTitle: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var authorization = AVCaptureDevice.authorizationStatus(for: .video)

    var body: some View {
        NavigationStack {
            Group {
                if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                    ContentUnavailableView("Camera unavailable", systemImage: "camera",
                        description: Text("Open MCmech on an iPhone or iPad with a camera."))
                } else if authorization == .authorized {
                    LiveCameraPreview()
                        .ignoresSafeArea(edges: .bottom)
                        .accessibilityLabel("Live camera preview")
                } else if authorization == .notDetermined {
                    ProgressView("Requesting camera access…")
                } else {
                    VStack(spacing: 20) {
                        ContentUnavailableView("Camera access needed", systemImage: "camera",
                            description: Text(authorization == .restricted
                                ? "Camera access is restricted on this device."
                                : "Allow camera access in Settings to view your vehicle."))
                        if authorization == .denied {
                            Button("Open Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    openURL(url)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Text(vehicleTitle)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.regularMaterial)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("closeCameraButton")
                }
            }
        }
        .task {
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            if authorization == .notDetermined {
                _ = await AVCaptureDevice.requestAccess(for: .video)
            }
            authorization = AVCaptureDevice.authorizationStatus(for: .video)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                authorization = AVCaptureDevice.authorizationStatus(for: .video)
            }
        }
    }
}

// The system camera owns capture lifecycle for this preview-only first step.
// No photos or video are recorded. Tracking will use a dedicated frame pipeline.
private struct LiveCameraPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let camera = UIImagePickerController()
        camera.sourceType = .camera
        camera.cameraCaptureMode = .photo
        camera.showsCameraControls = false
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            camera.cameraDevice = .rear
        }
        return camera
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}
}
