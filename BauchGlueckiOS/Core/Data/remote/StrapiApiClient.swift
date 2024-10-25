//
//  StrapiApiClient.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.10.24.
//

import Foundation

class StrapiApiClient: GenericAPIService {
    
    override init(environment: EnvironmentVariables = .production) {
       super.init(environment: environment)
    }
    
    func isServerReachable() async throws -> Bool {
        let token = self.bearerToken
        let url = URL(string: "\(self.baseURL)/api/currentTimeStamp")!
        
        var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw NetworkError.conflict }
        
        do {
            let _ = try JSONDecoder().decode(StrapiCurrentTimeStamp.self, from: data)
            print("Backend is Reachable")
            return true
        } catch {
            print("Backend is not Reachable")
            return false
        }
    }
}

class GenericAPIService {
    
    var baseURL: String
    var bearerToken: String

    init(environment: EnvironmentVariables) {
        self.baseURL = ""
        self.bearerToken = ""
        
        guard
            let tokens = Bundle.main.object(forInfoDictionaryKey: "BACKEND_KEYs") as? [String: String],
            let urls = Bundle.main.object(forInfoDictionaryKey: "BACKEND_BASEURLS") as? [String: String]
        else {
            print("Fehler: API_KEY oder API_BASEURL nicht korrekt in Info.plist konfiguriert.")
            return
        }

        switch environment {
            case .production:
                self.baseURL = urls["production"] ?? ""
                self.bearerToken = tokens["production"] ?? ""
            case .localSabina:
                self.baseURL = urls["localSabina"] ?? ""
                self.bearerToken = tokens["localSabina"] ?? ""
            case .localFrederik:
                self.baseURL = urls["localFrederik"] ?? ""
                self.bearerToken = tokens["localFrederik"] ?? ""
        }
    }

    func sendRequest<T: Codable, U: Codable>(
        endpoint: String,
        method: HTTPMethod = HTTPMethod.get,
        body: T,
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        
        // Erstelle die URL mit dem angegebenen Endpunkt
        let url = URL(string: endpoint)!
        
        print(">>> Remote: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Bearer-Token hinzufügen
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        // Body codieren (wenn vorhanden)
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        // Netzwerkanfrage starten
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Fehlerbehandlung
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            // Response-Model decodieren
            do {
                let decodedResponse = try JSONDecoder().decode(U.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func sendData<T: Codable>(
        endpoint: String,
        method: HTTPMethod = HTTPMethod.post,
        body: T,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let url = URL(string: endpoint)!
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        // Body codieren (wenn vorhanden)
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        // Netzwerkanfrage starten
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            
            // Fehlerbehandlung
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Erfolgreiche Anfrage
            completion(.success(()))
        }
        
        task.resume()
    }
    
    func fetchData<T: Codable>(
        endpoint: String,
        method: HTTPMethod = HTTPMethod.get,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let url = URL(string: endpoint)!
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        // Netzwerkanfrage starten
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Fehlerbehandlung
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            // Response-Model decodieren
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

enum HTTPMethod: String {
    case get, post, put, delete
}

enum EnvironmentVariables {
    case production
    case localFrederik
    case localSabina
}

enum NetworkError: Error {
    case serializationError
    case noInternet
    case serverError
    case unauthorized
    case conflict
    case unknown
}
