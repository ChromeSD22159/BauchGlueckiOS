//
//  StrapiApiClient.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.10.24.
//

import Foundation
import FirebaseAuth
import Alamofire
import UIKit
import SwiftUI

class StrapiApiClient: GenericAPIService {
    
    override init(environment: EnvironmentVariables = .production) {
       super.init(environment: environment)
    }
    
    func isServerReachable() async throws  -> Bool {
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
            AppStorageService.backendReachableState = true
            return true
        } catch {
            print("Backend is not Reachable")
            AppStorageService.backendReachableState = false
            return false
        }
    }
    
    func sendDeviceTokenToBackend() async throws {
        guard
            let currentUser = Auth.auth().currentUser?.uid,
            let userNotifierToken = DeviceTokenService.shared.getSavedDeviceToken(),
            !userNotifierToken.isEmpty
        else { return }
        
        guard !userNotifierToken.isEmpty else { return }
        
        let body = ApiDeviceToken(userID: currentUser, token: userNotifierToken)
        
        let url = self.baseURL + "/api/saveDeviceToken"
        let headers: HTTPHeaders = [.authorization(bearerToken: self.bearerToken)]
        
        print(body)
        
        Task {
            do {
                let request = AF.request(url, method: .post, parameters: body, encoder: JSONParameterEncoder.default, headers: headers)
                    .validate(statusCode: 200..<300)
                    .serializingDecodable(ApiMessageResponse.self)

                let result = await request.result
                   
                switch result {
                    case .success(let response): print("Response message:", response.message)
                    case .failure(let error): print("Error sending device token to backend: \(error)")
                    throw URLError(.badServerResponse)
                }
            } catch {
                print("Error sending device token to backend: \(error) \(currentUser) \(userNotifierToken)")
                throw error
            }
        }
    }
    
    func deleteDeviceTokenFromBackend() async throws {
        guard
            let currentUser = Auth.auth().currentUser?.uid,
            let userNotifierToken = DeviceTokenService.shared.getSavedDeviceToken(),
            !userNotifierToken.isEmpty
        else { return }
        
        let body = ApiDeviceToken(userID: currentUser, token: userNotifierToken)
        
        let url = self.baseURL + "/api/deleteDeviceToken"
        let headers: HTTPHeaders = [.authorization(bearerToken: self.bearerToken)]
        
        Task {
            do {
                let request = AF.request(url, method: .post, parameters: body, encoder: JSONParameterEncoder.default, headers: headers)
                    .serializingDecodable(ApiMessageResponse.self)

                let result = await request.result
                   
                switch result {
                    case .success(let response): print("Response message:", response.message)
                    case .failure(_): throw URLError(.badServerResponse)
                }
            } catch {
                print("Error delete device token to backend: \(error) \(currentUser) \(userNotifierToken)")
                throw error
            }
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
    
    func uploadImage(
        endpoint: String,
        image: UIImage,
        completion: @escaping (Result<[MainImage], Error>) -> Void
    ) {
        let urlString = endpoint

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Image Conversion Failed", code: -2, userInfo: nil)))
            return
        }

        // Set headers for the request
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(bearerToken)"
        ]

        // Multipart form data upload
        AF.upload(
            multipartFormData: { multipartFormData in
                // Füge das Bild hinzu
                let imageName = UUID().uuidString
                multipartFormData.append(imageData, withName: "files", fileName: "\(imageName).jpg", mimeType: "image/jpeg")
            }, to: urlString, headers: headers
        )
        .validate(statusCode: 200..<300)
        .responseDecodable(of: [MainImage].self) { response in
            if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                print("Full server response (uploadImage): \(jsonString)")
            }
            
            switch response.result {
            case .success(let uploadResponse):
                completion(.success(uploadResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func uploadRecipe(
        endpoint: String,
        recipe: RecipeUpload,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let urlString = endpoint
        let headers: HTTPHeaders = [
            .authorization(bearerToken: self.bearerToken),
            .contentType("application/json")
        ]
        do {
            let jsonData = try JSONEncoder().encode(recipe)
            let jsonString = String(data: jsonData, encoding: .utf8)

            AF.request(urlString, method: .post, parameters: nil, encoding: JSONStringEncoding(jsonString!), headers: headers)
                .validate()
                .responseString { response in
                    
                    if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                        print("Full server response (uploadRecipe): \(jsonString)")
                    }
                    
                    switch response.result {
                    case .success(let responseString):
                        completion(.success(responseString))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
        } catch {
            completion(.failure(error))
        }
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
    case NothingToSync
}


struct JSONStringEncoding: ParameterEncoding {
    private let jsonString: String

    init(_ jsonString: String) {
        self.jsonString = jsonString
    }

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = jsonString.data(using: .utf8, allowLossyConversion: false)
        return request
    }
}
