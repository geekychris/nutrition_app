import SwiftUI
import Charts
import SwiftData

struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var meals: [Meal]
    @EnvironmentObject var syncMonitor: SyncMonitor
    @ObservedObject var settings = SettingsManager.shared
    
    private var dataManager: DataManager {
        DataManager(modelContext: modelContext)
    }
    @State private var selectedTimeframe: Timeframe = .daily
    
    enum Timeframe: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Hidden view that triggers refresh when sync occurs
                EmptyView().id(syncMonitor.refreshTrigger)
                
                VStack(spacing: 20) {
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(Timeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    if selectedTimeframe == .daily {
                        dailyView
                    } else {
                        weeklyView
                    }
                }
            }
            .navigationTitle("Summary")
        }
        .navigationViewStyle(.stack)
    }
    
    private var dailyView: some View {
        VStack(spacing: 16) {
            let summaries = dataManager.getDailySummaries(meals: meals)
            
            if summaries.isEmpty {
                Text("No meals recorded yet")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                // Chart for last 7 days
                if summaries.count > 1 {
                    VStack(alignment: .leading) {
                        Text("Last 7 Days")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(Array(summaries.prefix(7))) { summary in
                                BarMark(
                                    x: .value("Date", summary.date, unit: .day),
                                    y: .value("Calories", summary.totalNutrition.calories)
                                )
                                .foregroundStyle(.blue)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Daily breakdown
                ForEach(summaries) { summary in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(summary.dateString)
                            .font(.headline)
                        
                        HStack(spacing: 30) {
                            VStack(alignment: .leading) {
                                Text("Carbs")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(settings.formatNutritionalWeight(summary.totalNutrition.carbohydrates)) \(settings.nutritionalWeightUnit)")
                                    .font(.title3)
                                    .bold()
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Protein")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(settings.formatNutritionalWeight(summary.totalNutrition.protein)) \(settings.nutritionalWeightUnit)")
                                    .font(.title3)
                                    .bold()
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Calories")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(summary.totalNutrition.calories, specifier: "%.0f")")
                                    .font(.title3)
                                    .bold()
                            }
                        }
                        
                        Text("\(summary.meals.count) meal\(summary.meals.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var weeklyView: some View {
        VStack(spacing: 16) {
            let weeklySummaries = dataManager.getWeeklySummaries(meals: meals)
            
            if weeklySummaries.isEmpty {
                Text("No meals recorded yet")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                // Chart
                VStack(alignment: .leading) {
                    Text("Weekly Trends")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart {
                        ForEach(weeklySummaries, id: \.weekStart) { summary in
                            LineMark(
                                x: .value("Week", summary.weekStart, unit: .weekOfYear),
                                y: .value("Calories", summary.nutrition.calories)
                            )
                            .foregroundStyle(.blue)
                            .symbol(Circle())
                        }
                    }
                    .frame(height: 200)
                    .padding()
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Weekly breakdown
                ForEach(weeklySummaries, id: \.weekStart) { summary in
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Week of \(summary.weekStart, style: .date)")
                            .font(.headline)
                        
                        HStack(spacing: 30) {
                            VStack(alignment: .leading) {
                                Text("Carbs")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(settings.formatNutritionalWeight(summary.nutrition.carbohydrates)) \(settings.nutritionalWeightUnit)")
                                    .font(.title3)
                                    .bold()
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Protein")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(settings.formatNutritionalWeight(summary.nutrition.protein)) \(settings.nutritionalWeightUnit)")
                                    .font(.title3)
                                    .bold()
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Calories")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(summary.nutrition.calories, specifier: "%.0f")")
                                    .font(.title3)
                                    .bold()
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
    }
}
