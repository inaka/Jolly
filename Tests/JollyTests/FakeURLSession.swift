import Foundation

typealias DataTaskCompletionParameters = (Data?, URLResponse?, Error?)
typealias DataTaskCompletion = (DataTaskCompletionParameters) -> ()

class FakeURLSession: URLSession {
    
    var dataTasks = [FakeURLSessionDataTask]()
    let parameters: DataTaskCompletionParameters
    
    init(customDataTaskCompletionParameters parameters: DataTaskCompletionParameters = (nil, nil, nil)) {
        self.parameters = parameters
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTask {
        let task = FakeURLSessionDataTask(request: request, parameters: self.parameters, completion: completionHandler)
        dataTasks += [task]
        return task
    }
    
}

class FakeURLSessionDataTask: URLSessionDataTask {
    
    let request: URLRequest?
    let completion: DataTaskCompletion
    let parameters: DataTaskCompletionParameters
    
    init(request: URLRequest, parameters: DataTaskCompletionParameters, completion: @escaping DataTaskCompletion) {
        self.request = request
        self.parameters = parameters
        self.completion = completion
    }
    
    override func resume() {
        self.completion(parameters.0, parameters.1, parameters.2)
    }
    
}
