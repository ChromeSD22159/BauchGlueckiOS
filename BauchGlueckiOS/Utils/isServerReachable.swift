//
//  isServerReachable.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 21.10.24.
//

import Foundation

func isServerReachable(client: StrapiApiClient) async throws -> Bool {
    let token = client.bearerToken
    let url = URL(string: "\(client.baseURL)/api/currentTimeStamp")!
    
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

struct StrapiCurrentTimeStamp: Codable {
    let previewTimeSamp, currentTimestamp, futureTimeStamp: Int
    let currentTimeString: String?
}

// https://app.quicktype.io/
