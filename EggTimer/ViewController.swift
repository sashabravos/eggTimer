//
//  ViewController.swift
//  EggTimer
//
//  Created by Александра Кострова on 20.01.2023.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    private lazy var buttonIndex = 1
    private lazy var currentViewPlace = 1
    private var softEggView = UIView(), medEggView = UIView(), hardEggView = UIView()

    private let eggTime = [ "Soft": 5, "Medium": 7, "Hard": 12]
    private let eggNames = [ "Soft", "Medium", "Hard" ]
    private let eggImageNames = ["soft_egg", "medium_egg", "hard_egg"]
    private let titleLabel = UILabel()
    private lazy var currentTime = Int()
    private lazy var totalTime = Int()
    private lazy var timer = Timer()
    private var player: AVAudioPlayer?
    private lazy var timeLine: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressViewStyle = .default
        progressView.setProgress(0.0, animated: true)
        progressView.progressTintColor = .systemYellow
        progressView.trackTintColor = .systemGray
        return progressView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
    }
    private func addSubViews() {
        view.backgroundColor = UIColor.init(named: "backgroundColor")
        let mainStackView = UIStackView()
        mainStackView.axis = NSLayoutConstraint.Axis.vertical
        mainStackView.distribution = UIStackView.Distribution.fillEqually
        mainStackView.alignment = UIStackView.Alignment.fill
        mainStackView.spacing = Constants.mainStackViewSpacing
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            mainStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
        ])
        for _ in 1...3 {
            switch currentViewPlace {
            case 1:
                let titleView = UIView()
                addViewInStackView(nameOfElement: titleView, stackView: mainStackView)
                titleLabel.text = "How do you like your eggs?"
                titleLabel.numberOfLines = 0
                titleLabel.textColor = .black
                titleLabel.font = .systemFont(ofSize: Constants.titleLabelFontSize)
                titleLabel.textAlignment = .center
                titleLabel.highlightedTextColor = .systemGray
                titleView.addSubview(titleLabel)
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
                    titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
                    titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
                    titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor)
                ])
                currentViewPlace += 1
            case 2:
                let eggStackView = UIStackView()
                eggStackView.axis  = NSLayoutConstraint.Axis.horizontal
                eggStackView.distribution  = UIStackView.Distribution.fillEqually
                eggStackView.alignment = UIStackView.Alignment.fill
                eggStackView.spacing = Constants.eggStackViewSpacing
                eggStackView.contentMode = .scaleAspectFit
                mainStackView.addArrangedSubview(eggStackView)
                eggStackView.translatesAutoresizingMaskIntoConstraints = false
                eggStackView.centerXAnchor.constraint(equalTo: mainStackView.centerXAnchor).isActive = true
                let eggViews = [ softEggView, medEggView, hardEggView ]
                for buttonIndex in 0..<eggViews.count {
                    eggStackView.addArrangedSubview(eggViews[buttonIndex])
                    eggViews[buttonIndex].translatesAutoresizingMaskIntoConstraints = false
                    eggViews[buttonIndex].centerYAnchor.constraint(equalTo: eggStackView.centerYAnchor).isActive = true
                    let imageView = UIImageView.init(image: UIImage(named: eggImageNames[buttonIndex]) ?? UIImage())
                    imageView.contentMode = .scaleAspectFit
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    eggViews[buttonIndex].addSubview(imageView)
                    NSLayoutConstraint.activate([
                        imageView.leadingAnchor.constraint(equalTo: eggViews[buttonIndex].leadingAnchor),
                        imageView.trailingAnchor.constraint(equalTo: eggViews[buttonIndex].trailingAnchor),
                        imageView.bottomAnchor.constraint(equalTo: eggViews[buttonIndex].bottomAnchor),
                        imageView.topAnchor.constraint(equalTo: eggViews[buttonIndex].topAnchor)
                    ])
                    let eggButton = UIButton()
                    eggButton.setTitle(eggNames[buttonIndex], for: .normal)
                    eggButton.setTitleColor(.white, for: .normal)
                    eggButton.titleLabel?.font = UIFont.systemFont(ofSize: Constants.buttonFontSize, weight: .black)
                    eggViews[buttonIndex].addSubview(eggButton)
                    eggButton.translatesAutoresizingMaskIntoConstraints = false
                    eggButton.centerXAnchor.constraint(equalTo: eggViews[buttonIndex].centerXAnchor).isActive = true
                    eggButton.centerYAnchor.constraint(equalTo: eggViews[buttonIndex].centerYAnchor).isActive = true
                    eggButton.tag = buttonIndex
                    eggButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
                }
                currentViewPlace += 1
            case 3:
                let timerView = UIView()
                addViewInStackView(nameOfElement: timerView, stackView: mainStackView)
                timerView.addSubview(timeLine)
                timeLine.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    timeLine.heightAnchor.constraint(equalToConstant: 5),
                    timeLine.leadingAnchor.constraint(equalTo: timerView.leadingAnchor),
                    timeLine.trailingAnchor.constraint(equalTo: timerView.trailingAnchor),
                    timeLine.centerYAnchor.constraint(equalTo: timerView.centerYAnchor)
                ])
            default:
                break
            }
        }
    }
    @objc func buttonPressed(sender: UIButton) {
        let hardness = sender.currentTitle!
        timeLine.progress = 0.0
        totalTime = eggTime[hardness]!
        currentTime = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil, repeats: true)
    }
    @objc func updateTimer() {
        if currentTime < totalTime {
            titleLabel.text = "\(totalTime - currentTime) minutes"
            currentTime += 1
            timeLine.progress += Constants.fullProgress / Float(totalTime)
            print("\(currentTime) seconds.")
        } else {
            playSound(soundName: "engDone")
//            playSound(soundName: "rusDone") // try this :)
            titleLabel.text = "Done!"
            timer.invalidate()
        }
    }
    private func playSound(soundName: String) {
        let url = Bundle.main.url(forResource: soundName, withExtension: "mp3")
        player = try? AVAudioPlayer(contentsOf: url!)
        player?.play()
    }
    private func addViewInStackView(nameOfElement: UIView, stackView: UIStackView) {
        stackView.addArrangedSubview(nameOfElement)
        nameOfElement.translatesAutoresizingMaskIntoConstraints = false
        nameOfElement.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
    }
    private enum Constants {
        static let mainStackViewSpacing: CGFloat = 39.0
        static let titleLabelFontSize: CGFloat = 40.0
        static let eggStackViewSpacing: CGFloat = 20.0
        static let buttonFontSize: CGFloat = 18.0
        static let fullProgress: Float = 1.0
    }
}
