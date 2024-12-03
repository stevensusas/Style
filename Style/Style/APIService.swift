import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "https://style-backend-315518144493.us-east1.run.app" // Your FastAPI backend URL

    func signUp(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "username": username,
            "password": password,
            "friends": [],
            "deals": []
        ] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to sign up"])))
                return
            }

            completion(.success("User signed up successfully"))
        }.resume()
    }

    func logIn(username: String, password: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "username": username,
            "password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])))
                return
            }

            completion(.success(json))
        }.resume()
    }
    
    func fetchUserDiscounts(username: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/\(username)/deals")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse data"])))
                return
            }

            let discounts = json.compactMap { $0["description"] as? String }
            completion(.success(discounts))
        }.resume()
    }

    func fetchTotalDiscounts(username: String, completion: @escaping (Result<Int, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/\(username)/deals")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse data"])))
                return
            }

            completion(.success(json.count))
        }.resume()
    }

    func fetchNewDeals(username: String, completion: @escaping (Result<[Deal], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/\(username)/new-deals")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse data"])))
                return
            }

            let deals = json.compactMap { dealJson -> Deal? in
                guard let id = dealJson["_id"] as? String,
                      let description = dealJson["description"] as? String else {
                    return nil
                }
                return Deal(id: id, description: description)
            }
            
            completion(.success(deals))
        }.resume()
    }

    func addDealToUser(username: String, dealId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/\(username)/deals/\(dealId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to add deal"])))
                return
            }

            completion(.success(()))
        }.resume()
    }

    func fetchRandomDeal(username: String, completion: @escaping (Result<Deal, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/\(username)/random-deal")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let id = json["_id"] as? String,
                  let description = json["description"] as? String else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse data"])))
                return
            }

            let deal = Deal(id: id, description: description)
            completion(.success(deal))
        }.resume()
    }
}
