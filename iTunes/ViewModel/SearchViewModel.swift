//
//  SearchViewModel.swift
//  iTunesAppCodeChallenge
//
//  Created by Talha on 24.03.2023.
//

import Foundation

protocol SearchViewModelProtocol {
	func fetchData(_ query: String, mediaType: MediaType, limit: Int, offset: Int)
	func setDelegate(output: SearchOutput)
	func changeLoading()
	
	var searchResult: [MediaItem] {get set}
	var searchService: ServiceProtocol {get}
	var searchOutPut: SearchOutput? {get}
}

final class SearchViewModel: SearchViewModelProtocol {
	weak var searchOutPut: SearchOutput?
	var searchService: ServiceProtocol
	var searchResult: [MediaItem] = []
	private var isLoading = false;
	
	init() {
		searchService = APIService()
	}
	/// Sets the output delegate
	func setDelegate(output: SearchOutput) {
		self.searchOutPut = output
	}
	///Changes the loading state and notifies the output delegate
	func changeLoading() {
		isLoading = !isLoading
		searchOutPut?.changeLoading(isLoad: isLoading)
	}
	/// Fetches data from the service and saves the result
	func fetchData(_ query: String, mediaType: MediaType, limit: Int, offset: Int) {
		searchService.request(route: APIRouter.search(term: query, media: mediaType, limit: 20, offset: 0)) { [weak self] (result: Result<SearchResponseModel, ServiceError>) in
			guard let self else {return}
			switch result {
			case .success(let response):
				self.changeLoading()
				self.searchResult = response.results ?? []
				self.searchOutPut?.saveDatas(values: self.searchResult)
				#if DEBUG
				print(response)
				#endif
			case .failure(let error):
				switch error {
				case .invalidURL:
					print("Error: Invalid URL")
				case .unableToParseData:
					print("Error: Unable to parse data")
				case .networkError(let networkError):
					print("Network Error: \(networkError.localizedDescription)")
				case .serverError(let statusCode):
					print("Server Error: \(statusCode)")
				}
			}
			self.searchOutPut?.changeLoading(isLoad: false)
		}
		
	}
}


