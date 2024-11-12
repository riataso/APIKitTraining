import SwiftUI
import APIKit

struct ApiKitRepositoryView: View {
    let request = SearchRepositoriesRequest()

    var body: some View {

        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear() {
                Session.send(request) { result in
                        switch result {
                        case .success(let response):
                            print("limit: \(response.items.first!.full_name)")
                        case .failure(let error):
                            print("error: \(error)")
                        }
                }
            }
    }
}

struct SearchRepositoriesRequest: Request {
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try JSONDecoder().decode(Response.self, from: object as! Data)
    }
    typealias Response = SearchResult

    var parameters: Any? {
        return ["q": "swift", "page": 1]
    }

    var baseURL: URL = .init(string: "https://api.github.com")!

    var method: APIKit.HTTPMethod = .get
    
    var path: String {
        "/search/repositories"
    }

    var dataParser: any DataParser = JsonDataParser()

    class JsonDataParser: APIKit.DataParser {
        var contentType: String? {
            "application/json"
        }

        func parse(data: Data) throws -> Any {
            data
        }
    }
}
