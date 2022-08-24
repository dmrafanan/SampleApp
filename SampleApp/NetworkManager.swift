//
//  NetworkManager.swift
//  SampleApp
//
//  Created by Daniel Marco Rafanan on 8/25/22.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    
    func fetchProducts(completion: @escaping (Result<[Product], NetworkError>) -> Void){
        let urlString = "https://dummyjson.com/products"
        guard let url = URL(string: urlString) else {
            completion(.failure(.wrongUrl))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
               200 >= httpResponse.statusCode && httpResponse.statusCode <= 299 else{
                completion(.failure(.errorFetching))
                return
            }
            
            guard let data = data,
                  let productModel = try? JSONDecoder().decode(ProductModel.self, from: data),
                  let products = productModel.products else {
                completion(.failure(.cantParseData))
                return
            }

            completion(.success(products))
        }.resume()
    }
    
    enum NetworkError: Error{
        case wrongUrl, networkError(String), cantParseData, errorFetching
    }
}
