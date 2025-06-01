import Foundation

struct Material: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var staerkeMM: Int      // Dicke in mm
    var gewichtQM: Double   // Gewicht pro m²
    var einkaufspreis: Double  // Einkaufspreis pro m²
    var lieferant: String
    var bestellnummer: String
    var laengeMM: Int       // Standardlänge in mm
    var breiteMM: Int       // Standardbreite in mm
}
