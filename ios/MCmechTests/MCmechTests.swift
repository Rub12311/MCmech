import Foundation
import Testing
@testable import MCmech

struct MCmechTests {
    let vin = "5UXWX7C57BA000000"
    func sample(code: String = "0") -> Data {
        Data("""
        {"Results":[{"VIN":"5UXWX7C57BA000000","ErrorCode":"\(code)","ModelYear":"2011","Make":"BMW","Model":"X3","EngineModel":"","DisplacementL":"3.0","EngineCylinders":"6"}]}
        """.utf8)
    }
    @Test func normalization() throws {
        #expect(try VINService.normalize("  \(vin.lowercased()) ") == vin)
        #expect(throws: VINError.self) { try VINService.normalize("INVALID") }
        #expect(throws: VINError.self) { try VINService.normalize(String(repeating: "O", count: 17)) }
    }
    @Test func missingEngineStaysUnknown() throws {
        let vehicle = try VINService.parse(sample(), vin: vin, year: "2011")
        #expect(vehicle.engineModel == nil)
        #expect(vehicle.title == "2011 BMW X3")
        #expect(vehicle.confirmedAt == nil)
    }
    @Test func rejectsProviderErrorsAndMismatches() {
        #expect(throws: VINError.self) { try VINService.parse(sample(code: "1"), vin: vin, year: "") }
        #expect(throws: VINError.self) { try VINService.parse(sample(), vin: vin, year: "2021") }
        #expect(throws: VINError.self) { try VINService.parse(sample(), vin: "11111111111111111", year: "") }
    }
    @Test @MainActor func garagePersistsDeduplicatesAndRemoves() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appending(path: "vehicles.json")
        let vehicle = try VINService.parse(sample(), vin: vin, year: "")
        let garage = Garage(file: file)
        try garage.save(vehicle)
        try garage.save(vehicle)
        #expect(garage.vehicles.count == 1)
        let reopened = Garage(file: file)
        #expect(reopened.vehicles.first?.vin == vin)
        #expect(reopened.vehicles.first?.confirmedAt != nil)
        try reopened.remove(vehicle)
        #expect(Garage(file: file).vehicles.isEmpty)
    }
    @Test @MainActor func damagedStorageIsNotOverwritten() throws {
        let file = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: file) }
        let original = Data("invalid json".utf8)
        try original.write(to: file)
        let garage = Garage(file: file)
        #expect(garage.error != nil)
        let vehicle = try VINService.parse(sample(), vin: vin, year: "")
        #expect(throws: VINError.self) { try garage.save(vehicle) }
        #expect(try Data(contentsOf: file) == original)
    }
}
