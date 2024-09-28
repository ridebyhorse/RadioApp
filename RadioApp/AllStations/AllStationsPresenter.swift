//
//  AllStationsPresenter.swift
//  RadioApp
//
//  Created by Дмитрий Лубов on 02.08.2024.
//

import Foundation
import RadioBrowser

/// Презентер для экрана с полным списком радиостанций.
final class AllStationsPresenter {

	// MARK: - Dependencies

	private let router: AllStationsRouterProtocol
	private weak var view: AllStationsControllerProtocol!

	private let radioBrowser: RadioBrowser
	private let storageManager: StorageManager
	private let audioPlayer: AudioPlayerProtocol

	// MARK: - Private properties

	private var stations: [AllStationViewModel] = []
    
    // MARK: - Public properties
    
    var getStations: [AllStationViewModel] {
        get { stations }
    }
    
    var lastStationId: Int = K.invalidStationId

	// MARK: - Initialization

	/// Инициализатор презентера.
	/// - Parameters:
	///   - router: роутер, для осуществления перехода на другие экраны.
	///   - view: view, на которой будет отображаться информация.
	///   - radioBrowser: сервис для работы с `API all.api.radio-browser`.
	///   - storageManager: менеджер, управляющий хранилищем радиостанций.
	///   - audioPlayer: аудиоплеер.
	init(
		router: AllStationsRouterProtocol,
		view: AllStationsControllerProtocol,
		radioBrowser: RadioBrowser,
		storageManager: StorageManager,
		audioPlayer: AudioPlayerController
	) {
		self.router = router
		self.view = view
		self.radioBrowser = radioBrowser
		self.storageManager = storageManager
		self.audioPlayer = audioPlayer
	}
}

// MARK: - AllStationsPresenterProtocol

extension AllStationsPresenter: AllStationsPresenterProtocol {

	/// Активация презентера для обновления информации на экране.
	///
	/// Получает первые 20 радиостанций из api и обновляет экран AllStations. Для подгрузки радиостанций используйте `fetchStations()`.
	func activate() {
		Task {
            if !stations.isEmpty {
                setPlayerStations()
				return
			}

			let result = await radioBrowser.getAllStations(offset: stations.count)

			switch result {
			case .success(let data):
                stations = data.map({ makeStationModel(from: $0) })
                setPlayerStations()
				await render()
			case .failure(let error):
				print(error)
			}
		}
	}

	/// Загрузка радиостанций.
	///
	/// При вызове подгружает 20 станций и обновляет экран.
	func fetchStations() {
		Task {
			let result = await radioBrowser.getAllStations(offset: stations.count)
			
			switch result {
			case .success(let data):
                let newStations = data.map({ makeStationModel(from: $0) })
                
                guard !newStations.isEmpty else {
                    return
                }
                
                /// update array of stations
                stations.append(contentsOf: newStations)
                
                /// update array of stations in audio player
                setPlayerStations()
                
                await updateView(with: newStations)
			case .failure(let error):
				print(error)
			}
		}
	}

	/// Выбрана радиостанция.
	/// - Parameter indexPath: индекс радиостанции.
	///
	/// Переход на экран с детальной информацией станции, которую выбрал пользователь.
    func showDetail(at indexPath: IndexPath) {
        let selectedStation = stations[indexPath.row]
        let radioStation = RadioStation(
            id: selectedStation.id,
            url: selectedStation.url,
            frequency: selectedStation.subtitle,
            name: selectedStation.title,
            imageName: selectedStation.imageURL
        )
        router.showStationDetails(with: radioStation)
    }
    
    /// Выбрана радиостанция
    /// - Parameter indexPath: индекс радиостанции
    ///
    /// Запуск плеера
	func didStationSelected(at indexPath: IndexPath) {
        let stationId = indexPath.row
        
        if stationId != lastStationId || lastStationId == K.invalidStationId {
            audioPlayer.playStation(at: stationId)
        }
	}

	/// Проголосовали за радиостанцию.
	/// - Parameter indexPath: индекс радиостанции.
	///
	/// Метод добавляет радиостанцию в избранное или удаляет от туда. Также голосует за выбранную радиостанцию, но только один раз.
	func didStationVoted(at indexPath: IndexPath) {
		Task {
			let station = stations[indexPath.row]
            favorite(station: station)
			let result = await radioBrowser.voteForStation(withId: station.id)
            switch result {
            case .success:
                print("successfully voted")
            case .failure(let error):
                print(error)
            }
            let stationData = await getStation(withId: station.id)
            stations[indexPath.row] = stationData ?? station
			await render()
		}
	}
}

// MARK: - Public methods

extension AllStationsPresenter {
    func updateLastStationId(_ stationId: Int) {
        lastStationId = stationId
    }
    
    func resetLastStationId() {
        lastStationId = K.invalidStationId
    }
}

// MARK: - Private methods

private extension AllStationsPresenter {

	@MainActor
	func render() {
		view.update()
	}
    
    @MainActor
    func updateView(with newStations: [AllStationViewModel]) {
        let startIndex = stations.count - newStations.count
        let endIndex = stations.count - 1
        let indexPaths = (startIndex...endIndex).map {
            IndexPath(item: $0, section: 0)
        }
        view.insert(at: indexPaths)
    }

	func getStation(withId id: UUID) async -> AllStationViewModel? {
		let result = await radioBrowser.getStation(withId: id)
		switch result {
		case .success(let data):
			return data.map({ makeStationModel(from: $0) })
		case .failure(let error):
			print(error)
			return nil
		}
	}

	func favorite(station: AllStationViewModel) {
		storageManager.toggleFavorite(
			id: station.id,
			title: station.title.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines),
			genre: station.subtitle,
            url: station.url,
            favicon: station.imageURL
		)
	}

	func makeStationModel(from data: Station) -> AllStationViewModel {
		let station = storageManager.fetchStation(with: data.stationUUID)
        let stationNames = StationFormatter.formatNames(data)

		return AllStationViewModel(
            id: data.stationUUID,
            title: stationNames.title,
            subtitle: stationNames.subtitle,
			votes: data.votes,
			isFavorite: station != nil ? true : false,
            url: data.urlResolved,
            imageURL: data.favicon
		)
	}
}

// MARK: - Set PlayList for Audio Player
extension AllStationsPresenter {
    func setPlayerStations() {
        let playList: [PlayerStation] = stations.map { station in
            PlayerStation(id: station.id, url: station.url)
        }
        let startIndex = lastStationId == K.invalidStationId ? 0 : lastStationId
        audioPlayer.setStations(playList, startIndex: startIndex)
    }
}
