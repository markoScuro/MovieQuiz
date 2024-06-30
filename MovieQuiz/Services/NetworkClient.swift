
import Foundation
protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
    struct NetworkClient: NetworkRouting {
    enum NetworkErrors: Error {
        case codeError
        case invalidURLError(String)
        case loadImageError(String)
        var errorDescription: String? {
            switch self {
            case .codeError:
                return localizedDescription
            default:
                return "error"
            }
        }
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
        
            if let error = error {
                handler(.failure(error))
                return
                
            }
     
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkErrors.codeError.errorDescription as! Error))
                return
            }
      
            guard let data = data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
    
    enum DataLoadError: Error, LocalizedError {
        case failedToLoadImage
        
        public var errorDescription: String? {
            switch self {
            case .failedToLoadImage:
                return NSLocalizedString("Не удалось загрузить следующий вопрос", comment: "Image not found")
            }
        }
    }
}
