import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    @Environment(\.dismiss) var dismiss
    
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
                    Text("Choose your preferred measurement system. All entries will be converted automatically.")
                        .font(.caption)
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
