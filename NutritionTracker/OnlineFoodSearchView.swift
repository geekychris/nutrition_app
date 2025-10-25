import SwiftUI

struct OnlineFoodSearchView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var searchQuery: String
    let onSelect: (USDAFood) -> Void
    
    @State private var results: [USDAFood] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var hasSearched = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isSearching {
                    ProgressView("Searching USDA database...")
                        .padding()
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        Text("Search Failed")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Try Again") {
                            performSearch()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if results.isEmpty && hasSearched {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Results Found")
                            .font(.headline)
                        Text("Try a different search term")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else if results.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        Text("Search USDA Database")
                            .font(.headline)
                        Text("Enter a food name and tap search")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List(results) { food in
                        Button(action: {
                            onSelect(food)
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(food.description)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                let nutrition = food.toNutritionInfo()
                                if nutrition.calories > 0 {
                                    HStack(spacing: 12) {
                                        Label("\(nutrition.carbohydrates, specifier: "%.1f")g", systemImage: "leaf.fill")
                                        Label("\(nutrition.protein, specifier: "%.1f")g", systemImage: "scalemass.fill")
                                        Label("\(nutrition.calories, specifier: "%.0f")", systemImage: "flame.fill")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                } else {
                                    Text("Nutrition data available")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Online Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchQuery, prompt: "Search for food...")
            .onSubmit(of: .search) {
                performSearch()
            }
            .onAppear {
                if !searchQuery.isEmpty {
                    performSearch()
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchQuery.isEmpty else { return }
        
        isSearching = true
        errorMessage = nil
        hasSearched = true
        
        Task {
            do {
                let searchResults = try await NutritionAPIService.shared.searchFood(query: searchQuery)
                await MainActor.run {
                    results = searchResults
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    isSearching = false
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet:
                            errorMessage = "No internet connection"
                        case .timedOut:
                            errorMessage = "Request timed out. Please try again."
                        default:
                            errorMessage = "Network error. Please check your connection."
                        }
                    } else {
                        errorMessage = "Unable to search. Please try again."
                    }
                }
            }
        }
    }
}
