import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var viewModel = SearchRepositoryViewModel()

    var body: some View {

        VStack {
            TextField("リポジトリ検索",text: $viewModel.word)

            List(viewModel.repositoryNames) { repository in
                Text(repository.name)
            }
        }

    }
}


@MainActor
class SearchRepositoryViewModel: ObservableObject {

    @Published private(set) var repositoryNames: [SearchItem] = []
    @Published public var word: String = ""
    private var cancellables = Set<AnyCancellable>()

    init() {
        $word
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { newText in
                Task {
                    await self.searchResults()
                }
            }
            .store(in: &cancellables)
    }

    // 検索結果に応じてデータを取得する(データ内容はレポジトリ名と使用言語)
    func searchResults() async {
        do {
            let searchResultsValues = try await RepositorySearchAppSample.shared.searchApi(self.word)
            repositoryNames = searchResultsValues
        } catch {
            print(error)
        }
    }
}


actor RepositorySearchAppSample {
    static let shared = RepositorySearchAppSample()

    init() {

    }

    @MainActor
    func searchApi(_ word: String) async throws -> [SearchItem] {
        let url = URL(string: "https://api.github.com/search/repositories?q=\(word)")!
        let request = URLRequest(url: url)

        let (data, response) = try await URLSession.shared.data(for: request)
        //let responseStatasCode = (response as! HTTPURLResponse).statusCode
        let searchResults = try JSONDecoder().decode(SearchResult.self, from: data)
        return searchResults.items
    }
}

// GitHub APIのレスポンス全体を表す構造体
struct SearchResult: Codable, Hashable {
    // リポジトリ情報の配列
    var items: [SearchItem]
}

// 各リポジトリ情報を表す構造体
struct SearchItem: Codable, Identifiable, Hashable{
    var id: Int
    var name: String
    var full_name: String
    var html_url: String
    var description: String?
    var language: String?
    var forks_count: Int
    var open_issues_count: Int
    var watchers_count: Int
}
