//
//  AllStationsController.swift
//  RadioApp
//
//  Created by Дмитрий Лубов on 05.08.2024.
//

import UIKit

final class AllStationsController: ViewController {

	// MARK: - Dependencies

	var presenter: AllStationsPresenterProtocol!
	var searchPresenter: SearchPresenter!

	// MARK: - Private properties

	private lazy var mainStack = makeStackView()
	private lazy var titleLabel = makeLabel()
	private lazy var searchTextField = makeTextField()
	private lazy var searchImageView = makeImageView()
	private lazy var activateSearchButton = makeButton()
	private lazy var collectionView = makeCollectionView()

	private var isActiveSearch: Bool = false {
		didSet {
            let image: UIImage = isActiveSearch ? .closeSearch : .goSearch
			activateSearchButton.setImage(image, for: .normal)
			titleLabel.isHidden = isActiveSearch
		}
	}

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
        
		setupUI()
        layout()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if presenter.getStations.isEmpty {
            showLoading()
        }
        
        if isActiveSearch {
            searchPresenter.activate()
        } else {
            presenter.activate()
        }
    }
}

// MARK: - UITextFieldDelegate

extension AllStationsController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if let text = textField.text, !text.isEmpty {
			showLoading()
			searchPresenter.searchStations(with: text)
			textField.resignFirstResponder()
            collectionView.setContentOffset(CGPoint(x:0 ,y:0), animated: true)
		}
		return true
	}

	func textField(
		_ textField: UITextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool {
		isActiveSearch = true
		return true
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		isActiveSearch = true
	}
}

// MARK: - AllStationsControllerProtocol

extension AllStationsController: AllStationsControllerProtocol {

	func update() {
		collectionView.reloadData()
		hideLoading()
	}
    
    func insert(at indexPaths: [IndexPath]) {
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: indexPaths)
        }, completion: nil)
    }
}

// MARK: - StationViewDelegate

extension AllStationsController: StationViewDelegate {

	func vote(at indexPath: IndexPath) {
        let presenter: AllStationsPresenterProtocol = isActiveSearch ? searchPresenter : presenter
        presenter.didStationVoted(at: indexPath)
	}
}

// MARK: - Collection View Data Source

extension AllStationsController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let presenter: AllStationsPresenterProtocol = isActiveSearch ? searchPresenter : presenter
        return presenter.getStations.count
	}
	
	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: AllStationsCell.reusableIdentifier,
			for: indexPath
		)
		guard let cell = cell as? AllStationsCell,
              let station = presenter.getStations[safe: indexPath.row] else {
            return UICollectionViewCell()
        }
        
        let presenter: AllStationsPresenterProtocol = isActiveSearch ? searchPresenter : presenter
        guard !presenter.getStations.isEmpty else { return cell }
		cell.configure(by: indexPath, with: station, delegate: self)
		
		return cell
	}
}

// MARK: - Collection View Delegate

extension AllStationsController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentPresenter: AllStationsPresenterProtocol = isActiveSearch ? searchPresenter : presenter
        currentPresenter.didStationSelected(at: indexPath)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		willDisplay cell: UICollectionViewCell,
		forItemAt indexPath: IndexPath
	) {
        let presenter: AllStationsPresenterProtocol = isActiveSearch ? searchPresenter : presenter
        guard presenter.getStations.count - indexPath.row == 4 else { return }
        presenter.fetchStations()
	}
}

// MARK: - Actions

private extension AllStationsController {

	var activateSearchHandler: UIActionHandler {
		{ [weak self] _ in
			guard let self else { return }
            
            isActiveSearch.toggle()
			if isActiveSearch {
                searchPresenter.setPlayerStations()
                searchTextField.becomeFirstResponder()
                collectionView.reloadData()
			} else {
                presenter.setPlayerStations()
                searchTextField.text = ""
                searchTextField.resignFirstResponder()
                collectionView.reloadData()
			}
		}
	}

    @objc func handleStationChange(_ notification: Notification) {
        guard let stationUUID = notification.userInfo?[K.UserInfoKey.stationUUID] as? UUID else {
            return
        }
        
        let currentPresenter: AllStationsPresenterProtocol = isActiveSearch ? searchPresenter : presenter
        let lastStationId = currentPresenter.lastStationId
        refreshItemState()
        
        guard let stationId = currentPresenter.getStations.firstIndex(where: { $0.id == stationUUID }) else {
            deselectItem(for: lastStationId)
            currentPresenter.resetLastStationId()
            return
        }
        
        let indexPath = IndexPath(item: stationId, section: 0)
        collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .centeredVertically
        )
        currentPresenter.updateLastStationId(stationId)
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: collectionView)
        
        if let indexPath = collectionView.indexPathForItem(at: point) {
            let presenter: AllStationsPresenterProtocol = isActiveSearch ? searchPresenter : presenter
            presenter.showDetail(at: indexPath)
        }
    }
}

// MARK: - Refresh CollectionItem State
private extension AllStationsController {
    func refreshItemState() {
        if isActiveSearch {
            deselectItem(for: presenter.lastStationId)
            presenter.resetLastStationId()
        } else {
            deselectItem(for: searchPresenter.lastStationId)
            searchPresenter.resetLastStationId()
        }
    }
}

// MARK: - Get CollectionView Cell
private extension AllStationsController {
    func getCollectionViewCell(for stationId: Int) -> AllStationsCell? {
        let indexPath = IndexPath(item: stationId, section: 0)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? AllStationsCell else {
            return nil
        }
        
        return cell
    }
}

// MARK: - Deselect CollectionView Cell
private extension AllStationsController {
    func deselectItem(for stationId: Int) {
        guard stationId != K.invalidStationId else {
            return
        }
        
        let indexPath = IndexPath(item: stationId, section: 0)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

// MARK: - Setup UI

private extension AllStationsController {
	
	func setupUI() {
		view.backgroundColor = .darkBlueApp

		addSubviews()
		addActions()
        setTapGesutre()
		setNotification()
	}

	func makeFlowLayout() -> UICollectionViewFlowLayout {
		let layout = UICollectionViewFlowLayout()

		layout.itemSize = CGSize(width: 291, height: 123)
		layout.minimumLineSpacing = 20

		return layout
	}

	func makeCollectionView() -> UICollectionView {
		let element = UICollectionView(frame: .zero, collectionViewLayout: makeFlowLayout())

		element.backgroundColor = .clear
		element.register(AllStationsCell.self, forCellWithReuseIdentifier: AllStationsCell.reusableIdentifier)
		element.dataSource = self
		element.delegate = self
		element.translatesAutoresizingMaskIntoConstraints = false

		return element
	}

	func makeStackView() -> UIStackView {
		let element = UIStackView()

		element.axis = .vertical
		element.alignment = .center
		element.spacing = 15
		element.translatesAutoresizingMaskIntoConstraints = false

		return element
	}

	func makeLabel() -> UILabel {
		let element = UILabel()

		element.text = "All Stations".localized
		element.font = .systemFont(ofSize: 30, weight: .light)
		element.textColor = .white
		element.translatesAutoresizingMaskIntoConstraints = false

		return element
	}

	func makeTextField() -> UITextField {
		let element = UITextField()

		element.backgroundColor = .searchApp
		element.layer.cornerRadius = 15
		element.textColor = .white
		element.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 58, height: element.frame.height))
		element.leftViewMode = .always
		element.rightView = activateSearchButton
		element.rightViewMode = .always
		element.attributedPlaceholder = NSAttributedString(
			string: "Search radio station",
			attributes: [.foregroundColor: UIColor.white]
		)
		element.returnKeyType = .search
		element.delegate = self
		element.translatesAutoresizingMaskIntoConstraints = false

		return element
	}

	func makeImageView() -> UIImageView {
		let element = UIImageView()

		element.image = .searchApp
		element.translatesAutoresizingMaskIntoConstraints = false

		return element
	}

	func makeButton() -> UIButton {
		let element = UIButton()

		element.setImage(.goSearch, for: .normal)
		element.translatesAutoresizingMaskIntoConstraints = false

		return element
	}
}

// MARK: - Setting UI

private extension AllStationsController {
	
	func addSubviews() {
		view.addSubview(mainStack)

		mainStack.addArrangedSubview(titleLabel)
		mainStack.addArrangedSubview(searchTextField)
		mainStack.addArrangedSubview(collectionView)

		searchTextField.addSubview(searchImageView)
	}

	func addActions() {
		activateSearchButton.addAction(UIAction(handler: activateSearchHandler), for: .touchUpInside)
	}
    
    private func setTapGesutre() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleDoubleTap)
        )
        tapGesture.numberOfTapsRequired = 2
        collectionView.addGestureRecognizer(tapGesture)
    }

	private func setNotification() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStationChange),
            name: .playerStationDidChange,
            object: nil
        )
	}
}

// MARK: - Layout UI

private extension AllStationsController {

	func layout() {
		NSLayoutConstraint.activate([
			mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			mainStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
			mainStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
			mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(K.audioPlayerHeight + K.audioPlayerBottomIndent)),

			titleLabel.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 44.18),

			searchTextField.heightAnchor.constraint(equalToConstant: 56),
			searchTextField.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
			
			searchImageView.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
			searchImageView.leadingAnchor.constraint(equalTo: searchTextField.layoutMarginsGuide.leadingAnchor),
			
            activateSearchButton.heightAnchor.constraint(equalToConstant: 32).withPriority(.defaultLow),
            activateSearchButton.widthAnchor.constraint(equalToConstant: 50).withPriority(.defaultLow),

			collectionView.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
			collectionView.bottomAnchor.constraint(equalTo: mainStack.bottomAnchor)
		])
	}
}
