import Foundation
import HealthKit
import Observation

@MainActor @Observable
final class HealthKitManager {
    private let store = HKHealthStore()
    private(set) var isAuthorized = false

    private let readTypes: Set<HKSampleType> = [
        HKCategoryType(.menstrualFlow),
    ]

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            return true
        } catch {
            return false
        }
    }

    func importEntries(existingDates: Set<Date>) async -> [PeriodEntry] {
        guard isAuthorized else { return [] }

        let flowType = HKCategoryType(.menstrualFlow)
        let sortDescriptor = SortDescriptor(\HKCategorySample.startDate, order: .forward)

        do {
            let descriptor = HKSampleQueryDescriptor<HKCategorySample>(
                predicates: [.categorySample(type: flowType)],
                sortDescriptors: [sortDescriptor]
            )
            let samples = try await descriptor.result(for: store)

            return samples.compactMap { sample in
                let date = sample.startDate.startOfDay
                guard !existingDates.contains(date) else { return nil }

                let flowLevel: FlowLevel
                switch sample.value {
                case HKCategoryValueMenstrualFlow.unspecified.rawValue:
                    flowLevel = .medium
                case HKCategoryValueMenstrualFlow.light.rawValue:
                    flowLevel = .light
                case HKCategoryValueMenstrualFlow.medium.rawValue:
                    flowLevel = .medium
                case HKCategoryValueMenstrualFlow.heavy.rawValue:
                    flowLevel = .heavy
                default:
                    flowLevel = .medium
                }

                return PeriodEntry(date: date, flowLevel: flowLevel)
            }
        } catch {
            return []
        }
    }

}
