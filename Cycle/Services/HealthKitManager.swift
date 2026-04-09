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

    private let writeTypes: Set<HKSampleType> = [
        HKCategoryType(.menstrualFlow),
    ]

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
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

    func writeEntry(_ entry: PeriodEntry) async {
        guard isAuthorized, entry.flowLevel.isFlow else { return }

        let flowType = HKCategoryType(.menstrualFlow)
        let hkValue: Int
        switch entry.flowLevel {
        case .none: return
        case .spotting: hkValue = HKCategoryValueMenstrualFlow.light.rawValue
        case .light: hkValue = HKCategoryValueMenstrualFlow.light.rawValue
        case .medium: hkValue = HKCategoryValueMenstrualFlow.medium.rawValue
        case .heavy: hkValue = HKCategoryValueMenstrualFlow.heavy.rawValue
        }

        let sample = HKCategorySample(
            type: flowType,
            value: hkValue,
            start: entry.date,
            end: entry.date.adding(days: 1)
        )

        do {
            try await store.save(sample)
        } catch {
            // Write failed
        }
    }
}
