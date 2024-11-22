//
//  MedicationService.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftData
import FirebaseAuth
import Alamofire

@MainActor
class MedicationService {
    private var context: ModelContext
    private var table: TableEntitiy
    private var apiService: StrapiApiClient
    private var syncHistoryRepository: SyncHistoryService
    private var headers: HTTPHeaders {
        [.authorization(bearerToken: apiService.bearerToken)]
    }
    
    init(context: ModelContext, apiService: StrapiApiClient) {
        self.context = context
        self.table = .MEDICATION
        self.apiService = apiService
        self.syncHistoryRepository = SyncHistoryService(context: context)
    }
    
    func insertMedication(medication: Medication) {
        context.insert(medication)
    }
    
    func getMedicationsWithTodaysIntakeTimes() -> [Medication] {
        guard let userID = Auth.auth().currentUser?.uid else { return [] }
        
        // Start und Endzeit für das heutige Datum
        let startOfDay = DateHelper.startToday.timeIntervalSince1970Milliseconds
        let endOfDay = DateHelper.endOfDay.timeIntervalSince1970Milliseconds

        // Medikament-Prädikat, um Benutzer-ID zu überprüfen
        let medicationPredicate = #Predicate { (medication: Medication) in
            medication.userId == userID
        }

        // Einnahmestatus-Prädikat für heutige Statusfilterung
        let query = FetchDescriptor<Medication>(
            predicate: medicationPredicate
        )

        do {
            let medications = try context.fetch(query)
            return medications.filter { medication in
                medication.intakeTimes.contains { intakeTime in
                    intakeTime.intakeStatuses.contains { intakeStatus in
                        intakeStatus.date >= startOfDay &&
                        intakeStatus.date < endOfDay
                    }
                }
            }
        } catch {
            print("Error fetching medications: \(error)")
            return []
        }
    }
    
    func getById(medicationId: String) -> Medication? {
        let predicate = #Predicate { (medication: Medication) in
            medication.medicationId == medicationId
        }

        let query = FetchDescriptor<Medication>(
            predicate: predicate
        )
        
        if let result = try? context.fetch(query).first {
            return result
        }
        
        return nil
    }
    
    func getAllUpdatedMedication(timeStamp: Int64) -> [Medication] {
        guard let userID = Auth.auth().currentUser?.uid else { return [] }
       
        let predicate = #Predicate { (medication: Medication) in
            medication.userId == userID && medication.updatedAtOnDevice > timeStamp
        }
        
        let query = FetchDescriptor<Medication>(
            predicate: predicate,
            sortBy: [SortDescriptor(\Medication.name)]
        )

        do {
            return try context.fetch(query)
        } catch {
            return []
        }
    }
    
    func insertOrUpdate(medicationId: String, serverMedication: Medication) {
        // Prüfen, ob das Medikament lokal existiert
        if let localMedication = getById(medicationId: medicationId) {
            // Update der lokalen Daten
            localMedication.name = serverMedication.name
            localMedication.dosage = serverMedication.dosage
            localMedication.isDeleted = serverMedication.isDeleted
            localMedication.updatedAtOnDevice = serverMedication.updatedAtOnDevice
            
            // Update der Beziehungen (IntakeTimes)
            for serverIntakeTime in serverMedication.intakeTimes {
                insertOrUpdateIntakeTime(intakeTimeId: serverIntakeTime.intakeTimeId, serverIntakeTime: serverIntakeTime, medication: localMedication)
            }
        } else {
            // Neues Medikament einfügen
            let newMedication = Medication(
                medicationId: serverMedication.medicationId,
                userId: serverMedication.userId,
                name: serverMedication.name,
                dosage: serverMedication.dosage,
                isDeleted: serverMedication.isDeleted,
                updatedAtOnDevice: serverMedication.updatedAtOnDevice
            )
            
            // IntakeTimes zuweisen
            for serverIntakeTime in serverMedication.intakeTimes {
                insertOrUpdateIntakeTime(intakeTimeId: serverIntakeTime.intakeTimeId, serverIntakeTime: serverIntakeTime, medication: newMedication)
            }
            
            context.insert(newMedication)
        }
    }
    
    func insertOrUpdateIntakeTime(intakeTimeId: String, serverIntakeTime: IntakeTime, medication: Medication) {
        // Prüfen, ob die IntakeTime lokal existiert
        let existingIntakeTime = medication.intakeTimes.first { $0.intakeTimeId == intakeTimeId }
        
        if let localIntakeTime = existingIntakeTime {
            // Update der lokalen Daten
            localIntakeTime.intakeTime = serverIntakeTime.intakeTime
            localIntakeTime.isDeleted = serverIntakeTime.isDeleted
            localIntakeTime.updatedAtOnDevice = serverIntakeTime.updatedAtOnDevice
            localIntakeTime.medication = medication
             
            NotificationService.shared.checkAndUpdateRecurringNotification(forMedication: medication, forIntakeTime: localIntakeTime)
            
            // IntakeStatuses aktualisieren
            for serverIntakeStatus in serverIntakeTime.intakeStatuses {
                insertOrUpdateIntakeStatus(intakeStatusId: serverIntakeStatus.intakeStatusId, serverIntakeStatus: serverIntakeStatus, intakeTime: localIntakeTime)
            }
        } else {
            // Neue IntakeTime erstellen
            let newIntakeTime = IntakeTime(
                intakeTimeId: serverIntakeTime.intakeTimeId,
                intakeTime: serverIntakeTime.intakeTime,
                medicationId: medication.medicationId,
                isDeleted: serverIntakeTime.isDeleted,
                updatedAtOnDevice: serverIntakeTime.updatedAtOnDevice,
                medication: medication
            )
            
            // IntakeStatuses zuweisen
            for serverIntakeStatus in serverIntakeTime.intakeStatuses {
                insertOrUpdateIntakeStatus(intakeStatusId: serverIntakeStatus.intakeStatusId, serverIntakeStatus: serverIntakeStatus, intakeTime: newIntakeTime)
            }
            
            medication.intakeTimes.append(newIntakeTime)
            context.insert(newIntakeTime)
            
            NotificationService.shared.checkAndUpdateRecurringNotification(forMedication: medication, forIntakeTime: newIntakeTime)
        }
    }
    
    func insertOrUpdateIntakeStatus(intakeStatusId: String, serverIntakeStatus: IntakeStatus, intakeTime: IntakeTime) {
        // Prüfen, ob IntakeStatus lokal existiert
        let existingIntakeStatus = intakeTime.intakeStatuses.first { $0.intakeStatusId == intakeStatusId }
        
        if let localIntakeStatus = existingIntakeStatus {
            // Update der lokalen Daten
            localIntakeStatus.date = serverIntakeStatus.date
            localIntakeStatus.isTaken = serverIntakeStatus.isTaken 
            localIntakeStatus.updatedAtOnDevice = serverIntakeStatus.updatedAtOnDevice
            localIntakeStatus.intakeTime = intakeTime
            
        } else {
            // Neuen IntakeStatus erstellen
            let newIntakeStatus = IntakeStatus(
                intakeStatusId: serverIntakeStatus.intakeStatusId,
                intakeTimeId: intakeTime.intakeTimeId,
                date: serverIntakeStatus.date,
                isTaken: serverIntakeStatus.isTaken,
                updatedAtOnDevice: serverIntakeStatus.updatedAtOnDevice,
                intakeTime: intakeTime
            )
            intakeTime.intakeStatuses.append(newIntakeStatus)
            context.insert(newIntakeStatus)
        }
    }
    
    func fetchMedicationFromBackend() {
        guard (Auth.auth().currentUser != nil), AppStorageService.whenBackendReachable() else { return }
        
        Task {
            do {
                let lastSync = try await syncHistoryRepository.getLastSyncHistoryByEntity(entity: table)?.lastSync ?? -1
                guard let user = Auth.auth().currentUser else { return }
                
                let url = apiService.baseURL + "/api/medication/getUpdatedMedicationEntries?timeStamp=\(lastSync)&userId=\(user.uid)"
                
                print("")
                print("<<< URL \(url)")
                
                let response = await AF.request(url, headers: headers)
                                       .cacheResponse(using: .doNotCache)
                                       .validate()
                                       .serializingDecodable([Medication].self)
                                       .response
                
                
                print(response)
                
                switch (response.result) {
                    case .success(let data):
                    
                        data.forEach { medication in
                            insertOrUpdate(medicationId: medication.medicationId, serverMedication: medication)
                        }
                    
                        print("")
                        print("Medication: Sync successful \(data.count)")
                        print("MedicationIntakeTimes: Sync successful \(data.map { $0.intakeTimes.count }.reduce(0, +))")
                        print("MedicationIntakeTimeStatuses: Sync successful \(data.flatMap { $0.intakeTimes }.map { $0.intakeStatuses.count }.reduce(0, +))")
                        print("")
                    
                        do {
                            try context.save()
                        } catch {
                            print("Fehler beim Speichern des Kontexts: \(error)")
                        }
                    
                        syncHistoryRepository.saveSyncHistoryStamp(entity: table)
                    
                    case .failure(_):
                        if response.response?.statusCode == 430 {
                            print("Medication: NothingToSync")
                            throw NetworkError.NothingToSync
                        } else {
                            throw NetworkError.unknown
                        }
                }
                
            }
        }
    }
    
    func sendUpdatedMedicationToBackend() {
        guard (Auth.auth().currentUser != nil), AppStorageService.whenBackendReachable() else { return }
 
        let sendURL = apiService.baseURL + "/api/medication/syncDeviceMedicationData"

        let headers: HTTPHeaders = [
            .authorization(bearerToken: apiService.bearerToken),
            .contentType("application/json")
        ]
        
        Task {
            do {
                let lastSync = try await syncHistoryRepository.getLastSyncHistoryByEntity(entity: table)?.lastSync ?? -1
                
                let foundMedications: [Medication] = getAllUpdatedMedication(timeStamp: lastSync)
                 
                print("")
                print("\(table) >>> URL \(sendURL)")
                print("\(table) last Sync: \(lastSync)")
                print("\(table) send Medications: \(foundMedications.count)")
 
                print("")
                print("Medication: Sync successful \(foundMedications.count)")
                print("MedicationIntakeTimes: Sync successful \(foundMedications.map { $0.intakeTimes.count }.reduce(0, +))")
                print("MedicationIntakeTimeStatuses: Sync successful \(foundMedications.flatMap { $0.intakeTimes }.map { $0.intakeStatuses.count }.reduce(0, +))")
                print("")

                let updateMedis = foundMedications.map { med in
                     MedicationDTO(
                        medicationId: med.medicationId,
                        userId: med.userId,
                        name: med.name,
                        dosage: med.dosage,
                        isDeleted: med.isDeleted,
                        updatedAtOnDevice: med.updatedAtOnDevice,
                        intake_times: med.intakeTimes.map { time in
                             IntakeTimeDTO(
                                intakeTimeId: time.intakeTimeId,
                                intakeTime: time.intakeTime,
                                medicationId: med.medicationId,
                                isDeleted: time.isDeleted,
                                updatedAtOnDevice: time.updatedAtOnDevice,
                                intake_statuses: time.intakeStatuses.map { status in
                                    IntakeStatusDTO(
                                        intakeStatusId: status.intakeStatusId,
                                        intakeTimeId: time.intakeTimeId,
                                        date: status.date,
                                        isTaken: status.isTaken,
                                        isDeleted: status.isDeleted,
                                        updatedAtOnDevice: status.updatedAtOnDevice
                                    )
                                }
                            )
                        }
                    )
                }
                
                AF.request(sendURL, method: .post, parameters: updateMedis, encoder: JSONParameterEncoder.default, headers: headers)
                    .validate()
                    .response { response in
                        switch response.result {
                            case .success: print("Daten erfolgreich gesendet!")
                            case .failure(let error): print("Fehler beim Senden der Daten: \(error)")
                        }
                    }
            }
        }
    }

    func syncWeights() {
        guard (Auth.auth().currentUser != nil), AppStorageService.whenBackendReachable() else { return }
        
        sendUpdatedMedicationToBackend()
        
        fetchMedicationFromBackend()
    }
    
    func setAllMedicationNotifications() {
        if let userId = Auth.auth().currentUser?.uid {
            
            let predicate = #Predicate<Medication> { medication in
                medication.userId == userId
            }
            
            let query = FetchDescriptor<Medication>(predicate: predicate)
            
            if let results = try? context.fetch(query) {
                for medication in results {
                    medication.intakeTimes.forEach { intakeTime in
                        NotificationService.shared.checkAndUpdateRecurringNotification(forMedication: medication, forIntakeTime: intakeTime)
                    }
                }
            }
        }
    }
    
    func removeAllMedicationNotifications() {
        if let userId = Auth.auth().currentUser?.uid {
            
            let predicate = #Predicate<Medication> { medication in
                medication.userId == userId
            }
            
            let query = FetchDescriptor<Medication>(predicate: predicate)
            
            if let results = try? context.fetch(query) {
                for medication in results {
                    medication.intakeTimes.forEach { intakeTime in
                        NotificationService.shared.removeRecurringNotification(forIntakeTime: intakeTime)
                    }
                }
            }
            
        }
    }
} 
