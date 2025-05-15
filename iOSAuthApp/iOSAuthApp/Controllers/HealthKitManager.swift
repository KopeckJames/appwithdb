import Foundation
import HealthKit
import CoreData

class HealthKitManager {
    static let shared = HealthKitManager()
    
    // The HealthKit store
    let healthStore = HKHealthStore()
    
    // Types of data we want to read from HealthKit
    let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .height)!
    ]
    
    // Private initializer for singleton
    private init() {
        print("HealthKitManager initialized")
    }
    
    // Check if HealthKit is available on this device
    func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    // Request authorization to access HealthKit data
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Check if HealthKit is available
        guard isHealthDataAvailable() else {
            completion(false, NSError(domain: "com.healthkit.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        // Request authorization
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
            completion(success, error)
        }
    }
    
    // Fetch step count for a specific day
    func fetchStepCount(forDate date: Date, completion: @escaping (Double?, Error?) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        // Set up the predicate for the query
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Create the query
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            
            let steps = sum.doubleValue(for: HKUnit.count())
            completion(steps, nil)
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    // Fetch heart rate data
    func fetchHeartRate(forDate date: Date, completion: @escaping (Double?, Error?) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        // Set up the predicate for the query
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Create the query
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { (_, result, error) in
            guard let result = result, let average = result.averageQuantity() else {
                completion(nil, error)
                return
            }
            
            let heartRate = average.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            completion(heartRate, nil)
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    // Fetch active energy burned
    func fetchActiveEnergy(forDate date: Date, completion: @escaping (Double?, Error?) -> Void) {
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        // Set up the predicate for the query
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Create the query
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            
            let calories = sum.doubleValue(for: HKUnit.kilocalorie())
            completion(calories, nil)
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    // Fetch weight data
    func fetchWeight(completion: @escaping (Double?, Error?) -> Void) {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        
        // Create the query
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { (_, samples, error) in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil, error)
                return
            }
            
            let weight = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion(weight, nil)
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    // Fetch height data
    func fetchHeight(completion: @escaping (Double?, Error?) -> Void) {
        let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
        
        // Create the query
        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { (_, samples, error) in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil, error)
                return
            }
            
            let height = sample.quantity.doubleValue(for: HKUnit.meter())
            completion(height, nil)
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    // Save health data to Core Data
    func saveHealthData(steps: Double?, heartRate: Double?, calories: Double?, weight: Double?, height: Double?) {
        let context = CoreDataStack.shared.viewContext
        
        // Create a new HealthData entity
        let entity = NSEntityDescription.entity(forEntityName: "HealthData", in: context)!
        let healthData = NSManagedObject(entity: entity, insertInto: context)
        
        // Set the values
        healthData.setValue(Date(), forKeyPath: "date")
        healthData.setValue(steps, forKeyPath: "steps")
        healthData.setValue(heartRate, forKeyPath: "heartRate")
        healthData.setValue(calories, forKeyPath: "calories")
        healthData.setValue(weight, forKeyPath: "weight")
        healthData.setValue(height, forKeyPath: "height")
        
        // Save the context
        do {
            try context.save()
            print("Health data saved successfully")
        } catch {
            print("Error saving health data: \(error)")
        }
    }
}
