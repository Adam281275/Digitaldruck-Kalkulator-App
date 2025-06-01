import SwiftUI

struct KalkulatorView: View {
    // Beispielmaterialien und Parameter (später über Datenbank/Verwaltung erweiterbar)
    @State private var materialien = [
        Material(name: "PVC 3mm", staerkeMM: 3, gewichtQM: 1.4, einkaufspreis: 8.0, lieferant: "Musterlieferant", bestellnummer: "123456", laengeMM: 1000, breiteMM: 700),
        Material(name: "Alu-Verbund", staerkeMM: 3, gewichtQM: 3.5, einkaufspreis: 18.0, lieferant: "AluSupplier", bestellnummer: "ALU2345", laengeMM: 1000, breiteMM: 500)
    ]
    @State private var parameter = KalkulationsParameter(aufschlagProzent: 80.0, fixkosten: 15.0, rabattMaxFlaeche: 30.0, rabattMaxStueck: 20.0)
    
    // Eingaben
    @State private var kundenname = ""
    @State private var firma = ""
    @State private var adresse = ""
    @State private var gewaehltesMaterial = 0
    @State private var laenge = 0
    @State private var breite = 0
    @State private var stueckzahl = 1
    @State private var laminiert = false
    @State private var doppelseitig = false
    @State private var eckengerundet = false
    @State private var lochbohrungen = 0
    
    var aktuelleMaterial: Material {
        materialien[gewaehltesMaterial]
    }
    
    // Kalkulationen
    var flaecheProStueck: Double {
        let f = (Double(laenge) / 1000.0) * (Double(breite) / 1000.0)
        return max(f, 0.0)
    }
    var gesamtflaeche: Double {
        flaecheProStueck * Double(stueckzahl)
    }
    var gewichtProStueck: Double {
        flaecheProStueck * aktuelleMaterial.gewichtQM
    }
    var gesamtgewicht: Double {
        gewichtProStueck * Double(stueckzahl)
    }
    
    // Rabatt-Berechnung
    var flaechenRabatt: Double {
        if gesamtflaeche < 0.01 { return 0 }
        if gesamtflaeche >= 5 { return parameter.rabattMaxFlaeche }
        // Exponentieller Anstieg (smooth)
        let r = parameter.rabattMaxFlaeche * (1 - exp(-gesamtflaeche))
        return min(r, parameter.rabattMaxFlaeche)
    }
    var stueckRabatt: Double {
        if stueckzahl <= 1 { return 0 }
        if stueckzahl >= 1000 { return parameter.rabattMaxStueck }
        // Linear
        let r = Double(stueckzahl - 1) / 999.0 * parameter.rabattMaxStueck
        return min(r, parameter.rabattMaxStueck)
    }
    var gesamtRabatt: Double {
        flaechenRabatt + stueckRabatt
    }
    
    // Preis-Berechnung
    var einkaufspreisGesamt: Double {
        aktuelleMaterial.einkaufspreis * gesamtflaeche
    }
    var verkaufspreisVorRabatt: Double {
        let basis = einkaufspreisGesamt * (1 + parameter.aufschlagProzent / 100.0)
        return basis + parameter.fixkosten
    }
    var rabattBetrag: Double {
        verkaufspreisVorRabatt * gesamtRabatt / 100.0
    }
    var endpreis: Double {
        max(0, verkaufspreisVorRabatt - rabattBetrag)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Kundendaten")
                        .font(.headline)
                    TextField("Name", text: $kundenname)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Firma", text: $firma)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Adresse", text: $adresse)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Group {
                    Text("Material & Maße")
                        .font(.headline)
                    Picker("Material", selection: $gewaehltesMaterial) {
                        ForEach(materialien.indices, id: \.self) { i in
                            Text(materialien[i].name)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Länge (mm)")
                            TextField("Länge", value: $laenge, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading) {
                            Text("Breite (mm)")
                            TextField("Breite", value: $breite, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading) {
                            Text("Stückzahl")
                            TextField("Stückzahl", value: $stueckzahl, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                Group {
                    Toggle("Laminiert", isOn: $laminiert)
                    Toggle("Doppelseitig", isOn: $doppelseitig)
                    Toggle("Eckengerundet", isOn: $eckengerundet)
                    Stepper("Lochbohrungen: \(lochbohrungen)", value: $lochbohrungen, in: 0...20)
                }
                
                Group {
                    Text("Live-Feedback")
                        .font(.headline)
                    Text(String(format: "Fläche pro Stück: %.3f m²", flaecheProStueck))
                    Text(String(format: "Gesamtfläche: %.3f m²", gesamtflaeche))
                    Text(String(format: "Gewicht pro Stück: %.2f kg", gewichtProStueck))
                    Text(String(format: "Gesamtgewicht: %.2f kg", gesamtgewicht))
                    Text(String(format: "Flächenrabatt: %.1f %%", flaechenRabatt))
                    Text(String(format: "Stückzahlrabatt: %.1f %%", stueckRabatt))
                    Text(String(format: "Gesamtrabatt: %.1f %%", gesamtRabatt))
                    Text(String(format: "Verkaufspreis (vor Rabatt): %.2f €", verkaufspreisVorRabatt))
                    Text(String(format: "Endpreis (nach Rabatt): %.2f €", endpreis))
                        .font(.title2)
                        .bold()
                        .foregroundColor(.blue)
                }
                .padding(.top)
            }
            .padding()
        }
    }
}

struct KalkulatorView_Previews: PreviewProvider {
    static var previews: some View {
        KalkulatorView()
    }
}
