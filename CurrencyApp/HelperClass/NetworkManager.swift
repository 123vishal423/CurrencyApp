//
//  NetworkManager.swift
//  CurrencyApp
//
//  Created by Sandip on 29/11/22.
//

import Foundation

let IS_BASE_URL = "https://api.apilayer.com/fixer/"
let IS_API_ACCESS_KEY = "xUevw85lw1bBvgidXPZ8imBGosNE1ENM"

enum NetworkError: Error {
    case invalidURL(String)
    case invalidResponse(String)
    case decodingError(String)
    case genericError(String)
    case internetError(String)
    
}

class NetworkManager {
    static let shared: NetworkManager = NetworkManager()
    
    private var baseURL: URL {
            return URL(string: IS_BASE_URL)!
    }

    public func infoForKey(_ key: String) -> String? {
            return (Bundle.main.infoDictionary?[key] as? String)?
                .replacingOccurrences(of: "\\", with: "")
     }
    
    public func getDataResponse(urlString: String, queryItems: [String: String]? = nil, completionBlock: @escaping (Result<[String: Any], Error>) -> Void) {
        let urlstr = baseURL.appendingPathComponent(urlString)

        var request = URLRequest(url: urlstr,timeoutInterval:Double.infinity)
        request.httpMethod = "GET"
        request.addValue("xUevw85lw1bBvgidXPZ8imBGosNE1ENM", forHTTPHeaderField: "apikey")
        
           let task = URLSession.shared.dataTask(with: request) { data, response, error in
               guard error == nil else {
                   completionBlock(.failure(NetworkError.internetError("Network error")))
                   return
               }
               
               guard let responseData = data else {
                   completionBlock(.failure(NetworkError.genericError("Generic error")))
                   return
               }

               guard let json = (try? JSONSerialization.jsonObject(with: responseData, options: [])) as? [String: AnyObject] else {
                   completionBlock(.failure(NetworkError.decodingError("Decoding error")))
                   return
               }
               
               guard let httpResponse = response as? HTTPURLResponse,
                   200 ..< 300 ~= httpResponse.statusCode else {
                       completionBlock(.failure(NetworkError.genericError("Generic error")))
                       return
               }
               
               if let status = json["success"] as? Bool, !status, let errorJson = json["error"] as? [String: Any], let errorMessage = errorJson["info"], let errorString = errorMessage as? String {
                   
                   completionBlock(.failure(NetworkError.invalidResponse(errorString)))
               } else {
                   completionBlock(.success(json))
               }
               
           }
           task.resume()
       }
    
    
    private func getQueryItems(queryItemDictionary: [String: String]?) -> [URLQueryItem] {
        var items = [URLQueryItem]()
        items.append(URLQueryItem(name: StringConstants.accessKey, value: IS_API_ACCESS_KEY))
        guard let itemDictionary = queryItemDictionary else {
            return items
        }
        for key in itemDictionary.keys {
            items.append(URLQueryItem(name: key, value: itemDictionary[key]))
        }
        
        return items
    }
    
}

