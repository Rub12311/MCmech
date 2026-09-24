import SwiftUI

struct ContentView: View {
    @StateObject private var garage = Garage()
    @State private var vin = ""
    @State private var year = ""
    @State private var preview: Vehicle?
    @State private var busy = false
    @State private var message: String?
    @State private var error: String?
    @State private var removing: Vehicle?
    @State private var cameraVehicle: Vehicle?
    @FocusState private var inputFocused: Bool
    private let green = Color(red: 0.13, green: 0.29, blue: 0.24)

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "car.side.fill").font(.largeTitle).foregroundStyle(green)
                        Text("Your car, identified.").font(.title.bold())
                        Text("Enter your VIN. Check the details. Save your vehicle.").foregroundStyle(.secondary)
                    }.padding(.vertical, 12)
                }
                Section {
                    TextField("17-character VIN", text: $vin)
                        .textInputAutocapitalization(.characters).autocorrectionDisabled()
                        .font(.system(.body, design: .monospaced)).focused($inputFocused)
                        .accessibilityLabel("Vehicle identification number")
                        .accessibilityIdentifier("vinInput")
                    TextField("Model year (optional)", text: $year).keyboardType(.numberPad).focused($inputFocused)
                    Button {
                        inputFocused = false
                        error = nil; message = nil; preview = nil; busy = true
                        Task {
                            defer { busy = false }
                            do { preview = try await VINService().lookup(vin, year: year) }
                            catch { self.error = error.localizedDescription }
                        }
                    } label: {
                        HStack { Text("Identify my vehicle"); Spacer(); if busy { ProgressView() } else { Image(systemName: "arrow.right") } }
                    }.accessibilityIdentifier("lookupButton")
                } header: { Text("Identify your vehicle") }
                footer: { Text("Lookup sends your VIN to NHTSA. Nothing is saved until you confirm. Modern US-market vehicles; no letters I, O, or Q.") }
                .disabled(busy)
                if let error { Section { Text(error).foregroundStyle(.red).accessibilityIdentifier("lookupError") } }
                if let message { Section { Label(message, systemImage: "checkmark.circle").foregroundStyle(green) } }
                if let vehicle = preview {
                    Section("Does this match your vehicle?") {
                        vehicleDetails(vehicle)
                        Text("Engine information may be incomplete. Exact repair configuration has not been verified.").font(.footnote).foregroundStyle(.secondary)
                        Button("Yes, save my vehicle") {
                            do { try garage.save(vehicle); preview = nil; message = "Vehicle saved to your garage."; error = nil }
                            catch { self.error = error.localizedDescription }
                        }.accessibilityIdentifier("saveVehicleButton")
                        Button("This isn’t my vehicle", role: .cancel) { preview = nil; message = "Check your VIN and model year." }
                    }
                }
                Section("Your garage · \(garage.vehicles.count)") {
                    if let storageError = garage.error {
                        Text(storageError).foregroundStyle(.red)
                        Button("Retry loading garage") { garage.load() }
                    } else if garage.vehicles.isEmpty {
                        ContentUnavailableView("Your garage starts here", systemImage: "car", description: Text("Identify and confirm your first vehicle above."))
                    }
                    ForEach(garage.vehicles) { vehicle in
                        DisclosureGroup(vehicle.title) {
                            vehicleDetails(vehicle)
                            if let date = vehicle.confirmedAt { Text("Confirmed \(date.formatted(date: .abbreviated, time: .omitted))").font(.caption) }
                            Button("Remove vehicle", role: .destructive) { removing = vehicle }
                        }
                        Button {
                            cameraVehicle = vehicle
                        } label: {
                            Label("Open camera · \(vehicle.title)", systemImage: "camera")
                        }
                        .accessibilityIdentifier("garageCameraButton")
                    }
                }
                Section {
                    DisclosureGroup("Where do I find my VIN?") {
                        Text("Look through the windshield at the driver-side dashboard, on the driver’s door-jamb label, or on your registration.")
                    }
                    Text("Vehicles are stored on this iPhone. No account or sync with the Mac garage. Saved vehicles are available offline.").font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("MCmech").tint(green)
            .fullScreenCover(item: $cameraVehicle) { vehicle in
                VehicleCameraView(vehicleTitle: vehicle.title)
            }
            .onChange(of: vin) { preview = nil; error = nil; message = nil }
            .onChange(of: year) { preview = nil; error = nil; message = nil }
            .alert("Remove saved vehicle?", isPresented: Binding(get: { removing != nil }, set: { if !$0 { removing = nil } })) {
                Button("Cancel", role: .cancel) { removing = nil }
                Button("Remove", role: .destructive) {
                    if let vehicle = removing {
                        do { try garage.remove(vehicle) } catch { self.error = error.localizedDescription }
                    }
                    removing = nil
                }
            } message: { Text("This removes the vehicle from this iPhone’s garage.") }
        }
    }
    @ViewBuilder private func vehicleDetails(_ vehicle: Vehicle) -> some View {
        Text(vehicle.title).font(.headline)
        Text(vehicle.vin).font(.system(.caption, design: .monospaced)).textSelection(.enabled)
        LabeledContent("Engine", value: vehicle.engine)
        LabeledContent("Fuel", value: vehicle.fuel ?? "Not provided")
        LabeledContent("Trim", value: vehicle.trim ?? "Not provided")
        Text("Source: NHTSA vPIC · No repair procedure matched").font(.caption).foregroundStyle(.secondary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View { ContentView() }
}
