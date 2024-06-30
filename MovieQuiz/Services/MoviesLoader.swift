
import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {

        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    if ((mostPopularMovies.errorMessage?.isEmpty) == nil) {
                        handler(.failure(NetworkErrors.invalidUrlError(mostPopularMovies.errorMessage ?? "error not identity")))
                    } else {
                        handler(.success(mostPopularMovies))
                    }
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    enum NetworkErrors: LocalizedError {
        case codeError
        case invalidUrlError(String)
        case loadImageError(String)
        var errorDescription: String?{
            switch self{
            case .codeError:
                return localizedDescription
            case .invalidUrlError(let error):
                return error
            case .loadImageError(let error):
                return error
            }
        }
    }
    
}
