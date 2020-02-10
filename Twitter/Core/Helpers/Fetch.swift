//
//  Fetch.swift
//  Twitter
//
//  Created by Alex Geier on 2/9/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import Foundation

enum FetchError: Error {
    case badURL
    case API
    case noData
    case decode
}

func fetchJSON<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> ()) {
    guard let url = URL(string: urlString) else {
        completion(.failure(FetchError.badURL))
        return
    }
    
    URLSession.shared.dataTask(with: url) { (data, res, err) in
        if let err = err {
            completion(.failure(FetchError.API))
            return
        }
        
        guard let data = data else {
            completion(.failure(FetchError.noData))
            return
        }
        
        do {
            let jsonData = try JSONDecoder().decode(T.self, from: data)
            completion(.success(jsonData))
        } catch {
            print(error)
            completion(.failure(FetchError.decode))
        }
    }.resume()
}
