import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Unit System", selection: $settings.measurementUnit) {
                        ForEach(MeasurementUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Weight:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(settings.measurementUnit.weightUnit)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Volume:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(settings.measurementUnit.volumeUnit)
                                .fontWeight(.medium)
                        }
                    }
                    .font(.caption)
                } header: {
                    Text("Measurements")
                } footer: {
                    Text("Choose your preferred measurement system. Food weights and drink volumes are shown in this unit; carbs and protein are always in grams.")
                        .font(.caption)
                }
                
                Section {
                    SecureField("API key (optional)", text: $settings.usdaAPIKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("USDA Online Search")
                } footer: {
                    Text("Without a key the shared DEMO_KEY is used, which allows only a few searches per hour. Get a free key at fdc.nal.usda.gov.")
                        .font(.caption)
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Database")
                        Spacer()
                        Text("USDA FoodData Central")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(.stack)
    }
    
    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }
}
