import SwiftUI
import HealthKit
import CoreData

struct HealthView: View {
    // Environment object for managed object context
    @Environment(\.managedObjectContext) private var viewContext

    // State variables for health data
    @State private var steps: Double?
    @State private var heartRate: Double?
    @State private var calories: Double?
    @State private var weight: Double?
    @State private var height: Double?

    // State variables for UI
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var healthKitAuthorized = false

    // Fetch request for health data
    @FetchRequest(
        entity: NSEntityDescription.entity(forEntityName: "HealthData", in: CoreDataStack.shared.viewContext)!,
        sortDescriptors: [NSSortDescriptor(keyPath: \HealthData.date, ascending: false)],
        predicate: nil,
        animation: .default)
    private var healthDataResults: FetchedResults<HealthData>

    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color.white.edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 20) {
                        // Header is now in the navigation bar, so we don't need it here

                        // Health Kit Authorization Status
                        HStack {
                            Image(systemName: healthKitAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(healthKitAuthorized ? .green : .red)
                            Text(healthKitAuthorized ? "HealthKit Authorized" : "HealthKit Not Authorized")
                                .font(.headline)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        // Request Authorization Button
                        if !healthKitAuthorized {
                            Button(action: {
                                requestHealthKitAuthorization()
                            }) {
                                Text("Request HealthKit Access")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            }
                            .padding(.bottom, 20)
                        }

                        // Health Data Cards
                        Group {
                            // Steps Card
                            HealthDataCard(
                                title: "Steps",
                                value: steps != nil ? "\(Int(steps!)) steps" : "No data",
                                icon: "figure.walk",
                                color: .blue
                            )

                            // Heart Rate Card
                            HealthDataCard(
                                title: "Heart Rate",
                                value: heartRate != nil ? "\(Int(heartRate!)) bpm" : "No data",
                                icon: "heart.fill",
                                color: .red
                            )

                            // Calories Card
                            HealthDataCard(
                                title: "Active Calories",
                                value: calories != nil ? "\(Int(calories!)) kcal" : "No data",
                                icon: "flame.fill",
                                color: .orange
                            )

                            // Weight Card
                            HealthDataCard(
                                title: "Weight",
                                value: weight != nil ? String(format: "%.1f kg", weight!) : "No data",
                                icon: "scalemass.fill",
                                color: .purple
                            )

                            // Height Card
                            HealthDataCard(
                                title: "Height",
                                value: height != nil ? String(format: "%.2f m", height!) : "No data",
                                icon: "ruler.fill",
                                color: .green
                            )
                        }

                        // Refresh Button
                        Button(action: {
                            if healthKitAuthorized {
                                fetchHealthData()
                            } else {
                                alertMessage = "Please authorize HealthKit access first"
                                showingAlert = true
                            }
                        }) {
                            Text("Refresh Health Data")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)

                        // Save Button
                        Button(action: {
                            saveHealthData()
                        }) {
                            Text("Save Health Data")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        .padding(.top, 10)

                        // History Section
                        if !healthDataResults.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("History")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                    .padding(.top, 20)

                                ForEach(healthDataResults.prefix(5), id: \.self) { data in
                                    HealthHistoryRow(healthData: data)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }

                        Spacer(minLength: 50)
                    }
                    .padding()
                }

                // Loading overlay
                if isLoading {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)

                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("Loading health data...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(30)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            .navigationBarTitle("Health Data", displayMode: .large)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Health Data"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                checkHealthKitAuthorization()
            }
        }
    }

    // Check if HealthKit is authorized
    private func checkHealthKitAuthorization() {
        // Check if HealthKit is available
        if !HealthKitManager.shared.isHealthDataAvailable() {
            alertMessage = "HealthKit is not available on this device"
            showingAlert = true
            return
        }

        // Check authorization status
        for type in HealthKitManager.shared.readTypes {
            let status = HealthKitManager.shared.healthStore.authorizationStatus(for: type)
            if status == .sharingAuthorized {
                healthKitAuthorized = true
                fetchHealthData()
                return
            }
        }

        healthKitAuthorized = false
    }

    // Request HealthKit authorization
    private func requestHealthKitAuthorization() {
        isLoading = true

        HealthKitManager.shared.requestAuthorization { success, error in
            DispatchQueue.main.async {
                isLoading = false

                if success {
                    healthKitAuthorized = true
                    fetchHealthData()
                } else {
                    alertMessage = error?.localizedDescription ?? "Failed to authorize HealthKit"
                    showingAlert = true
                }
            }
        }
    }

    // Fetch health data from HealthKit
    private func fetchHealthData() {
        isLoading = true

        let today = Date()
        let group = DispatchGroup()

        // Fetch steps
        group.enter()
        HealthKitManager.shared.fetchStepCount(forDate: today) { result, error in
            DispatchQueue.main.async {
                steps = result
                group.leave()
            }
        }

        // Fetch heart rate
        group.enter()
        HealthKitManager.shared.fetchHeartRate(forDate: today) { result, error in
            DispatchQueue.main.async {
                heartRate = result
                group.leave()
            }
        }

        // Fetch active energy
        group.enter()
        HealthKitManager.shared.fetchActiveEnergy(forDate: today) { result, error in
            DispatchQueue.main.async {
                calories = result
                group.leave()
            }
        }

        // Fetch weight
        group.enter()
        HealthKitManager.shared.fetchWeight { result, error in
            DispatchQueue.main.async {
                weight = result
                group.leave()
            }
        }

        // Fetch height
        group.enter()
        HealthKitManager.shared.fetchHeight { result, error in
            DispatchQueue.main.async {
                height = result
                group.leave()
            }
        }

        // When all fetches are complete
        group.notify(queue: .main) {
            isLoading = false
        }
    }

    // Save health data to Core Data
    private func saveHealthData() {
        HealthKitManager.shared.saveHealthData(
            steps: steps,
            heartRate: heartRate,
            calories: calories,
            weight: weight,
            height: height
        )

        alertMessage = "Health data saved successfully"
        showingAlert = true
    }
}

// Health Data Card View
struct HealthDataCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 50)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.gray)

                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// Health History Row View
struct HealthHistoryRow: View {
    let healthData: HealthData

    var body: some View {
        VStack(alignment: .leading) {
            Text(formattedDate)
                .font(.headline)
                .foregroundColor(.gray)

            HStack {
                // Check if steps has a value
                if healthData.steps > 0 {
                    Text("\(Int(healthData.steps)) steps")
                        .font(.subheadline)
                }

                // Check if heart rate has a value
                if healthData.heartRate > 0 {
                    Text("• \(Int(healthData.heartRate)) bpm")
                        .font(.subheadline)
                }

                // Check if calories has a value
                if healthData.calories > 0 {
                    Text("• \(Int(healthData.calories)) kcal")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    // Format the date
    private var formattedDate: String {
        guard let date = healthData.date else { return "Unknown date" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
