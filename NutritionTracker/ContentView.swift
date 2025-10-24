import SwiftUI

struct ContentView: View {
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
        }
    }
}
