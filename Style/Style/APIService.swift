import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "https://style-backend-315518144493.us-east1.run.app" // Your FastAPI backend URL

    // Sign up a user
    func signUp(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Request body
        let body = [
            "username": username,
            "password": password,
            "friends": [],
            "deals": []
        ] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // Send request
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

    // Log in a user
    func logIn(username: String, password: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Request body
        let body = [
            "username": username,
            "password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // Send request
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

    // Fetch total discounts
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
    
    func initiateTrade(fromUser: String, toUser: String, itemFrom: String, itemTo: String, completion: @escaping (Result<String, Error>) -> Void) {
            let url = URL(string: "\(baseURL)/trades")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body = [
                "from_user": fromUser,
                "to_user": toUser,
                "item_from": itemFrom,
                "item_to": itemTo
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let tradeId = json["trade_id"] as? String else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to initiate trade"])))
                    return
                }

                completion(.success(tradeId))
            }.resume()
        }

        // Confirm a trade
        func confirmTrade(tradeId: String, completion: @escaping (Result<String, Error>) -> Void) {
            let url = URL(string: "\(baseURL)/trades/\(tradeId)/confirm")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to confirm trade"])))
                    return
                }

                completion(.success("Trade confirmed successfully"))
            }.resume()
        }

        // Cancel a trade
        func cancelTrade(tradeId: String, completion: @escaping (Result<String, Error>) -> Void) {
            let url = URL(string: "\(baseURL)/trades/\(tradeId)/cancel")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to cancel trade"])))
                    return
                }

                completion(.success("Trade canceled successfully"))
            }.resume()
        }

        // Fetch details of a trade
        func fetchTradeDetails(tradeId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
            let url = URL(string: "\(baseURL)/trades/\(tradeId)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch trade details"])))
                    return
                }

                completion(.success(json))
            }.resume()
        }
    
    
    
        // Fetch a random coupon
        func fetchRandomCoupon(completion: @escaping (Result<Coupon, Error>) -> Void) {
            let url = URL(string: "\(baseURL)/coupons/random")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let id = json["id"] as? String,
                      let brand = json["brand"] as? String,
                      let description = json["description"] as? String,
                      let imageURL = json["image_url"] as? String else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch random coupon"])))
                    return
                }

                let coupon = Coupon(id: id, brand: brand, description: description, imageURL: imageURL)
                completion(.success(coupon))
            }.resume()
        }

        // Claim a coupon
        func claimCoupon(username: String, couponId: String, completion: @escaping (Result<String, Error>) -> Void) {
            let url = URL(string: "\(baseURL)/users/\(username)/claim")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body = [
                "coupon_id": couponId
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to claim coupon"])))
                    return
                }

                completion(.success("Coupon claimed successfully"))
            }.resume()
        }
    

        // Update fetchUserDiscounts to return [Coupon]
        func fetchUserDiscounts(username: String, completion: @escaping (Result<[Coupon], Error>) -> Void) {
            let url = URL(string: "\(baseURL)/users/\(username)/deals")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data,
                      let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse data"])))
                    return
                }

                let coupons = jsonArray.compactMap { dict -> Coupon? in
                    guard let id = dict["id"] as? String,
                          let brand = dict["brand"] as? String,
                          let description = dict["description"] as? String,
                          let imageURL = dict["image_url"] as? String else {
                        return nil
                    }
                    return Coupon(id: id, brand: brand, description: description, imageURL: imageURL)
                }
                completion(.success(coupons))
            }.resume()
        }
}

