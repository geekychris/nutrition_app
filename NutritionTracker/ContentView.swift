import SwiftUI

struct ContentView: View {
    @State private var showingSettings = false
    
    var body: some View {
        TabView {
            MealsListView()
                .tabItem {
                    Label("Meals", systemImage: "fork.knife")
                }
            
            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "chart.bar")
                }
            
            Button(action: {
                showingSettings = true
            }) {
                Label("Settings", systemImage: "gear")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}
