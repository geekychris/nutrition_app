import Foundation
import SwiftUI

enum MeasurementUnit: String, CaseIterable, Codable {
    case metric = "Metric"
    case imperial = "Imperial"
    
    var weightUnit: String {
        switch self {
        case .metric: return "g"
        case .imperial: return "oz"
        }
    }
    
    var volumeUnit: String {
        switch self {
        case .metric: return "ml"
        case .imperial: return "fl oz"
        }
    }
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @AppStorage("measurementUnit") var measurementUnit: MeasurementUnit = .metric
    
    // Conversion helpers
    func gramsToOunces(_ grams: Double) -> Double {
        return grams * 0.035274
    }
    
    func ouncesToGrams(_ ounces: Double) -> Double {
        return ounces / 0.035274
    }
    
    func mlToFluidOunces(_ ml: Double) -> Double {
        return ml * 0.033814
    }
    
    func fluidOuncesToMl(_ flOz: Double) -> Double {
        return flOz / 0.033814
    }
    
    // Display weight in user's preferred unit (number only)
    func formatWeight(_ grams: Double) -> String {
        switch measurementUnit {
        case .metric:
            return String(format: "%.1f", grams)
        case .imperial:
            return String(format: "%.2f", gramsToOunces(grams))
        }
    }
    
    // Display weight with unit
    func formatWeightWithUnit(_ grams: Double) -> String {
        return "\(formatWeight(grams)) \(measurementUnit.weightUnit)"
    }
    
    // Display volume in user's preferred unit (number only)
    func formatVolume(_ ml: Double) -> String {
        switch measurementUnit {
        case .metric:
            return String(format: "%.0f", ml)
        case .imperial:
            return String(format: "%.1f", mlToFluidOunces(ml))
        }
    }
    
    // Display volume with unit
    func formatVolumeWithUnit(_ ml: Double) -> String {
        return "\(formatVolume(ml)) \(measurementUnit.volumeUnit)"
    }
    
    // Format nutritional weights (carbs, protein, etc.) - typically shown to 1 decimal
    func formatNutritionalWeight(_ grams: Double) -> String {
        switch measurementUnit {
        case .metric:
            return String(format: "%.1f", grams)
        case .imperial:
            return String(format: "%.2f", gramsToOunces(grams))
        }
    }
    
    // Get the unit label for nutritional info
    var nutritionalWeightUnit: String {
        return measurementUnit.weightUnit
    }
}
