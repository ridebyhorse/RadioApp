//
//  AllStationsCell.swift
//  RadioApp
//
//  Created by Дмитрий Лубов on 05.08.2024.
//

import UIKit

/// Представление радиостанции для экрана AllStations
final class StationView: UIView {
	
	// MARK: - Outlets
	
	// MARK: - Public properties
	
	/// Заголовок.
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}
	/// Подзаголовок.
	var subtitle: String? {
		didSet {
			subtitleLabel.text = subtitle
		}
	}
	/// Статус.
	var status: String? {
		didSet {
			statusLabel.text = status
		}
	}
	/// Количество голосов.
	var numberOfVotes: Int? {
		didSet {
			if let numberOfVotes {
				voteLabel.text = "votes \(numberOfVotes)"
			} else {
				voteLabel.text = nil
			}
		}
	}
	/// Предпочтение.
	var isFavorite: Bool? {
		didSet {
			if let isFavorite {
				favoriteButton.configuration?.background.image = isFavorite ? .voteOn : .voteOff
			} else {
				favoriteButton.configuration?.background.image = nil
			}
		}
	}
	/// Цвет волны.
	var waveCirclesColor: StationView.ColorCircle? {
		didSet {
			if let waveCirclesColor {
				waveCirclesImage.tintColor = waveCirclesColor.color
			} else {
				waveCirclesImage.image = nil
			}
		}
	}

	// MARK: - Dependencies
	
	// MARK: - Private properties

	private lazy var titleStack = makeStackView()
	private lazy var titleLabel = makeLabel(font: .systemFont(ofSize: 30, weight: .bold))
	private lazy var subtitleLabel = makeLabel(font: .systemFont(ofSize: 15, weight: .regular))
	private lazy var statusLabel = makeLabel(font: .systemFont(ofSize: 14, weight: .bold))

	private lazy var voteStack = makeVoteStack()
	private lazy var voteLabel = makeLabel(font: .systemFont(ofSize: 10, weight: .bold))
	private lazy var favoriteButton = makeButton()

	private lazy var waveCirclesImage = makeImageView(with: .waveCircles)

	// MARK: - Initialization

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifecycle

	override func layoutSubviews() {
		super.layoutSubviews()
		layout()
	}

	// MARK: - Public methods

	func setTheme(_ theme: Theme) {
		backgroundColor = theme.background
		layer.borderColor = theme.borderColor.cgColor
		titleLabel.textColor = theme.textColor
		subtitleLabel.textColor = theme.textColor
		statusLabel.textColor = UIColor(red: 0.69, green: 0.16, blue: 0.33, alpha: 1.00)
		voteLabel.textColor = theme.textColor
	}

	// MARK: - Private methods
}

// MARK: - Theme View

extension StationView {
	
	/// Тема view
	enum Theme {

		case base
		case pink

		/// Цвет фона.
		var background: UIColor? {
			switch self {
			case .base:
				nil
			case .pink:
				.pinkApp
			}
		}
		
		/// Цвет рамки.
		var borderColor: UIColor {
			switch self {
			case .base:
				.white.withAlphaComponent(0.2)
			case .pink:
				.pinkApp
			}
		}
		
		/// Цвет текста.
		var textColor: UIColor {
			switch self {
			case .base:
				.white.withAlphaComponent(0.2)
			case .pink:
				.white
			}
		}
		
		/// Цвет волны.
		var waveColor: UIColor {
			switch self {
			case .base:
				.white.withAlphaComponent(0.3)
			case .pink:
				.white
			}
		}
	}
}

// MARK: - Color of wave circles

extension StationView {
	
	/// Цвет кружков.
	enum ColorCircle: Int, CaseIterable {

		case darkPink
		case blue
		case magenta
		case green
		case yellow
		case orange

		// TODO: - использовать цвета из ассетов
		/// Цвет.
		var color: UIColor {
			switch self {
			case .darkPink:
				.systemPink
			case .blue:
				.systemBlue
			case .magenta:
				.systemPurple
			case .green:
				.systemGreen
			case .yellow:
				.systemYellow
			case .orange:
				.systemRed
			}
		}
	}
}

// MARK: - Actions

private extension StationView {
	
}

// MARK: - Setup UI

private extension StationView {
	
	func setupUI() {
		layer.borderWidth = 2

		addSubviews()
	}

	func makeStackView() -> UIStackView {
		let element = UIStackView()

		element.axis = .vertical
		element.distribution = .fillEqually
		element.translatesAutoresizingMaskIntoConstraints = false

		return element
	}

	func makeVoteStack() -> UIStackView {
		let element = UIStackView()

		element.axis = .horizontal
		element.alignment = .trailing
		element.spacing = 5
		element.translatesAutoresizingMaskIntoConstraints = false

		return element
	}

	func makeLabel(font: UIFont) -> UILabel {
		let element = UILabel()

		element.font = font
		element.translatesAutoresizingMaskIntoConstraints = false

		return element
	}

	func makeButton() -> UIButton {
		let element = UIButton()

		element.configuration = .plain()
		element.translatesAutoresizingMaskIntoConstraints = false

		return element
	}

	func makeImageView(with image: UIImage) -> UIImageView {
		let element = UIImageView()

		element.image = image
		element.contentMode = .scaleAspectFit
		element.translatesAutoresizingMaskIntoConstraints = false

		return element
	}
}

// MARK: - Setting UI

private extension StationView {
	
	func addSubviews() {
		addSubview(titleStack)
		addSubview(voteStack)
		addSubview(waveCirclesImage)

		titleStack.addArrangedSubview(titleLabel)
		titleStack.addArrangedSubview(subtitleLabel)
		titleStack.addArrangedSubview(statusLabel)

		voteStack.addArrangedSubview(voteLabel)
		voteStack.addArrangedSubview(favoriteButton)
	}
}

// MARK: - Layout UI

private extension StationView {
	
	func layout() {
		NSLayoutConstraint.activate([
			titleStack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
			titleStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
			titleStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

			voteStack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
			voteStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

			favoriteButton.widthAnchor.constraint(equalToConstant: 14.66),
			favoriteButton.heightAnchor.constraint(equalToConstant: 12),

			waveCirclesImage.centerYAnchor.constraint(equalTo: centerYAnchor),
			waveCirclesImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
			waveCirclesImage.widthAnchor.constraint(equalToConstant: 93.91)
		])
	}
}

@available(iOS 17.0, *)
#Preview {
	NavigationController(rootViewController: AllStationsController())
}
