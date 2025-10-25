import Foundation
import SwiftUI
import SwiftData
import CoreData

class SyncMonitor: ObservableObject {
    @Published var lastSyncDate: Date?
    @Published var isSyncing = false
    @Published var refreshTrigger = 0  // Used to force view updates
    
    private var timer: Timer?
    private var modelContainer: ModelContainer?
    
    // Check for sync every 10 seconds when app is active
    private let syncCheckInterval: TimeInterval = 10
    
    func startMonitoring(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        
        // Listen for various CloudKit notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStoreRemoteChange),
            name: NSNotification.Name.NSPersistentStoreRemoteChange,
            object: nil
        )
        
        // Listen for CloudKit import events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCloudKitImport),
            name: NSNotification.Name("NSPersistentCloudKitContainerEventChangedNotification"),
            object: nil
        )
        
        // Listen for app becoming active to trigger sync check
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        // Start periodic timer for background checks
        startPeriodicSync()
        
        print("🔄 SyncMonitor: Started monitoring CloudKit sync")
        print("📱 Device: \(UIDevice.current.name)")
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        NotificationCenter.default.removeObserver(self)
        print("🔄 SyncMonitor: Stopped monitoring")
    }
    
    private func startPeriodicSync() {
        // Invalidate existing timer if any
        timer?.invalidate()
        
        // Create timer that fires every syncCheckInterval seconds
        timer = Timer.scheduledTimer(withTimeInterval: syncCheckInterval, repeats: true) { [weak self] _ in
            self?.checkForUpdates()
        }
        
        // Fire immediately on start
        checkForUpdates()
    }
    
    @objc private func handleStoreRemoteChange(_ notification: Notification) {
        print("📥 SyncMonitor: NSPersistentStoreRemoteChange notification received")
        if let userInfo = notification.userInfo {
            print("📥 UserInfo: \(userInfo)")
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.lastSyncDate = Date()
            self.isSyncing = false
            self.refreshTrigger += 1  // Trigger view refresh
            print("🔄 SyncMonitor: Remote change detected, data updated at \(Date())")
            print("🔄 SyncMonitor: Refresh trigger = \(self.refreshTrigger)")
        }
    }
    
    @objc private func handleCloudKitImport(_ notification: Notification) {
        print("☁️ SyncMonitor: CloudKit import event received")
        if let userInfo = notification.userInfo {
            print("☁️ UserInfo: \(userInfo)")
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.lastSyncDate = Date()
            self.refreshTrigger += 1
            print("☁️ CloudKit data imported, triggering refresh")
        }
    }
    
    @objc private func appDidBecomeActive() {
        print("🔄 SyncMonitor: App became active, checking for updates")
        checkForUpdates()
    }
    
    private func checkForUpdates() {
        guard let container = modelContainer else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.isSyncing = true
        }
        
        // Trigger a fetch to pull any remote changes
        Task { @MainActor in
            do {
                // Create a background context to fetch fresh data
                let context = ModelContext(container)
                
                // Fetch all meals to force CloudKit sync
                let mealDescriptor = FetchDescriptor<Meal>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
                let meals = try context.fetch(mealDescriptor)
                
                // Fetch foods and drinks too
                let foodDescriptor = FetchDescriptor<FoodItem>()
                _ = try context.fetch(foodDescriptor)
                
                let drinkDescriptor = FetchDescriptor<Drink>()
                _ = try context.fetch(drinkDescriptor)
                
                self.lastSyncDate = Date()
                self.isSyncing = false
                self.refreshTrigger += 1  // Trigger view refresh
                print("🔄 SyncMonitor: Sync check completed at \(Date()) - Found \(meals.count) meals")
            } catch {
                self.isSyncing = false
                print("⚠️ SyncMonitor: Sync check error: \(error)")
            }
        }
    }
    
    deinit {
        stopMonitoring()
    }
}
