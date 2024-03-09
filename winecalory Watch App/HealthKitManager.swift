import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    var healthStore: HKHealthStore?

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let energyBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(false)
            return
        }

        healthStore?.requestAuthorization(toShare: [], read: [energyBurnedType]) { success, _ in
            completion(success)
        }
    }

    func fetchCalories(completion: @escaping (Double) -> Void) {
        guard let energyBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
              let healthStore = self.healthStore else {
            completion(0)
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: energyBurnedType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            let calories = sum.doubleValue(for: HKUnit.kilocalorie())
            DispatchQueue.main.async {
                completion(calories)
            }
        }

        healthStore.execute(query)
    }
}
