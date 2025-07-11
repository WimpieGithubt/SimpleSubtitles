import UIKit
import SubtitlesInterface
import SwiftUI

class SubtitlesTextView: UIView {
    private let presenter: SubtitlesController
    private var viewModel: SubtitlesControl.ViewModel?
    
//    var show: Bool = true {
//        didSet {
//            labelLines.isHidden = !show
//        }
//    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    } ()
    
    private let labelLines: SubtitlesLabel = {
        
        let label = SubtitlesLabel()
        label.numberOfLines = 0
        label.insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        label.textAlignment = .center
        label.textColor = .white
        
        let defaultFontSize: CGFloat
            switch UIDevice.current.userInterfaceIdiom {
            case .tv:
                defaultFontSize = 44
            case .pad:
                defaultFontSize = 32
            case .phone:
                defaultFontSize = 22
            default:
                defaultFontSize = 44
            }
        
        let storedFontSize = UserDefaults.standard.double(forKey: "subtitleFontSize")
        let fontSize = storedFontSize > 0 ? storedFontSize : defaultFontSize

        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        
        label.layer.backgroundColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        label.layer.cornerRadius = 10
    
        return label
    } ()
    
    init(presenter: SubtitlesController) {
        self.presenter = presenter
        super.init(frame: CGRect(x: 100, y: 100, width: 1200, height: 800))
        
//        setupObserver()
        
        setupView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fontSizeDidChange(_:)),
            name: Notification.Name("subtitleFontSizeDidChange"),
            object: nil
        )

    }
    
    @objc private func fontSizeDidChange(_ notification: Notification) {
        if let size = notification.userInfo?["size"] as? Double {
            updateSubtitleFontSize(CGFloat(size))
//            print("updateSubtitleFontSize: \(size)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        UserDefaults.standard.removeObserver(self, forKeyPath: "subtitlesEnabled")

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    private func setupObserver() {
//        UserDefaults.standard.addObserver(
//            self,
//            forKeyPath: "subtitlesEnabled",
//            options: [.initial, .new],
//            context: nil
//        )
//    }
    
//    override func observeValue(forKeyPath keyPath: String?,
//                               of object: Any?,
//                               change: [NSKeyValueChangeKey: Any]?,
//                               context: UnsafeMutableRawPointer?) {
//        if keyPath == "subtitlesEnabled" {
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                let enabled = UserDefaults.standard.bool(forKey: "subtitlesEnabled")
//                show = enabled
//                print("subtitlesEnabled in observeValue SimpleSubtitles = \(show)")
//            }
//        }
//    }
    
    private func setupView() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        stackView.addArrangedSubview(labelLines)
        stackView.addSubview(labelLines)
        
//        let enabled = UserDefaults.standard.bool(forKey: "subtitlesEnabled")
//        labelLines.isHidden = !enabled
//        print("subtitlesEnabled in setupView SimpleSubtitles = \(enabled)")
    }
    
    func updateSubtitleFontSize(_ fontSize: CGFloat) {
        labelLines.font = UIFont.boldSystemFont(ofSize: fontSize)
        setNeedsLayout()
    }
    
    
}

extension SubtitlesTextView: SubtitlesControlViewProtocol {
    func perform(update: SubtitlesControl.Update) {
        switch update {
        case .hideSubtitles:
            labelLines.text = nil
            labelLines.isHidden = true
        case .showSubtitles(let viewModel):
            if viewModel != self.viewModel {
                labelLines.text = viewModel.lines
                labelLines.isHidden = false
            }
            self.viewModel = viewModel
        }
    }
}

class SubtitlesLabel: UILabel {
    
    var insets: UIEdgeInsets = .zero
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: text == nil ? rect : rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.width += insets.left + insets.right
        contentSize.height += insets.top + insets.bottom
        
        return contentSize
    }
}
