import Foundation
import Combine

struct Vehicle: Codable, Identifiable, Equatable {
    var id: String { vin }
    let vin: String
    let year: String
    let make: String
    let model: String
    let trim: String?
    let liters: String?
    let cylinders: String?
    let engineModel: String?
    let fuel: String?
    let decodedAt: Date
    var confirmedAt: Date?
    var title: String { "\(year) \(make) \(model)" }
    var engine: String {
        let parts = [liters.map { "\($0) L" }, cylinders.map { "\($0) cylinders" }, engineModel].compactMap { $0 }
        return parts.isEmpty ? "Not provided" : parts.joined(separator: " · ")
    }
}

enum VINError: LocalizedError {
    case message(String)
    var errorDescription: String? { if case let .message(text) = self { return text }; return nil }
}

struct VINService {
    static func normalize(_ input: String) throws -> String {
        let vin = input.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard vin.range(of: "^[A-HJ-NPR-Z0-9]{17}$", options: .regularExpression) != nil else {
            throw VINError.message("Enter 17 letters and numbers. VINs do not use I, O, Q, spaces, or punctuation.")
        }
        return vin
    }
    static func parse(_ data: Data, vin: String, year: String) throws -> Vehicle {
        struct Response: Decodable { let Results: [[String: String?]] }
        let response = try JSONDecoder().decode(Response.self, from: data)
        guard let row = response.Results.first else { throw VINError.message("No vehicle was returned. Please try again.") }
        func field(_ key: String) -> String? {
            guard let text = row[key] ?? nil else { return nil }
            let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return value.isEmpty ? nil : value
        }
        let codes = (field("ErrorCode") ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard !codes.isEmpty, codes.allSatisfy({ $0 == "0" }),
              let make = field("Make"), let model = field("Model"), let modelYear = field("ModelYear"),
              let number = Int(modelYear), number >= 1981,
              year.isEmpty || year == modelYear,
              field("VIN") == nil || field("VIN")?.uppercased() == vin else {
            throw VINError.message("NHTSA could not cleanly identify this vehicle. Check your VIN and add the model year if you know it.")
        }
        return Vehicle(vin: vin, year: modelYear, make: make, model: model, trim: field("Trim"), liters: field("DisplacementL"), cylinders: field("EngineCylinders"), engineModel: field("EngineModel"), fuel: field("FuelTypePrimary"), decodedAt: Date())
    }
    func lookup(_ input: String, year inputYear: String) async throws -> Vehicle {
        let vin = try Self.normalize(input)
        let year = inputYear.trimmingCharacters(in: .whitespacesAndNewlines)
        if !year.isEmpty {
            guard year.count == 4, let number = Int(year), (1981...(Calendar.current.component(.year, from: Date()) + 2)).contains(number) else {
                throw VINError.message("Enter a valid model year from 1981 onward, or leave it blank.")
            }
        }
        var url = URLComponents(string: "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues/\(vin)")!
        url.queryItems = [URLQueryItem(name: "format", value: "json")]
        if !year.isEmpty { url.queryItems?.append(URLQueryItem(name: "modelyear", value: year)) }
        var request = URLRequest(url: url.url!)
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let data: Data
        do {
            let (body, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
            data = body
        } catch {
            throw VINError.message("Vehicle lookup is unavailable. Check your internet connection and try again. Your VIN is still here.")
        }
        do { return try Self.parse(data, vin: vin, year: year) }
        catch let error as VINError { throw error }
        catch { throw VINError.message("The lookup returned an unexpected response. Please try again.") }
    }
}

@MainActor
final class Garage: ObservableObject {
    @Published private(set) var vehicles: [Vehicle] = []
    @Published var error: String?
    private let file: URL
    private var loaded = false
    init(file: URL? = nil) {
        self.file = file ?? URL.applicationSupportDirectory.appending(path: "MCmech/vehicles.json")
        load()
    }
    func load() {
        do {
            if FileManager.default.fileExists(atPath: file.path) {
                vehicles = try JSONDecoder().decode([Vehicle].self, from: Data(contentsOf: file))
            }
            loaded = true
            error = nil
        } catch { self.error = "Saved vehicles could not be read. Your existing file has not been changed." }
    }
    private func persist(_ updated: [Vehicle]) throws {
        guard loaded else { throw VINError.message("Reload the garage before making changes to saved vehicles.") }
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(updated).write(to: file, options: .atomic)
        vehicles = updated
    }
    func save(_ vehicle: Vehicle) throws {
        var confirmed = vehicle
        confirmed.confirmedAt = vehicles.first(where: { $0.vin == vehicle.vin })?.confirmedAt ?? Date()
        var updated = vehicles.filter { $0.vin != vehicle.vin }
        updated.insert(confirmed, at: 0)
        try persist(updated)
    }
    func remove(_ vehicle: Vehicle) throws { try persist(vehicles.filter { $0.vin != vehicle.vin }) }
}
