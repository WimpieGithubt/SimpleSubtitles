import CoreMedia
import SubtitlesInterface

public struct SubtitleLanguage: Identifiable {
    public let id: String
    public let label: String
    public let url: String
    
    public init(id: String, label: String, url: String) {
        self.id = id
        self.label = label
        self.url = url
    }
}

public protocol SubtitlesController: AnyObject {
    func setLanguage(url: String)
    func setAvailableLanguages(languages: [SubtitleLanguage], defaultLanguageID: String?)
    func turnOff()
}

class SubtitlesControlPresenter: SubtitlesController {
    private let interactor: SubtitlesInteractorProtocol
    private weak var player: PlayerControlProtocol?
    private var timeObserver:Any? = nil
    
    private var availableLanguages: [SubtitleLanguage] = []
    private var currentLanguage: SubtitleLanguage? = nil
    
    weak var view: SubtitlesControlViewProtocol?
    private var previousSections: [SubtitleInformation.Section] = []
    private var isOn: Bool = true
    
    init(player: PlayerControlProtocol, interactor: SubtitlesInteractorProtocol) {
        self.player = player
        self.interactor = interactor
        initialiserObserver()
    }
    
    deinit {
        if let timeObserver = self.timeObserver {
            self.player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
    
    func setLanguage(url: String) {
//        print("setLanguage \(!url.isEmpty) \(url)")
        interactor.setSubtitleFile(url: url)
//        isOn = true
        isOn = !url.isEmpty
        
    }
    
    func setAvailableLanguages(languages: [SubtitleLanguage], defaultLanguageID: String? = nil) {
        availableLanguages = languages
        currentLanguage = languages.first { $0.id == defaultLanguageID }
    }
    
    func turnOff() {
        isOn = false
        view?.perform(update: .hideSubtitles)
    }
    
    func timeUpdate(_ time: CMTime) {
        guard isOn else {
            return
        }
        
        let sections = interactor.sectionsFromTime(time.seconds)
        guard !sections.isEmpty else {
            view?.perform(update: .hideSubtitles)
            return
        }
        if sections != previousSections {
            view?.perform(update: .showSubtitles(SubtitlesControl.ViewModel(sections)))
        }
    }
    
    // MARK: - private methods
    
    private func initialiserObserver() {
        let interval = CMTimeMakeWithSeconds(0.1, preferredTimescale: Int32(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: DispatchQueue.main,
            using: {[weak self] time in
            self?.timeUpdate(time)
        })
    }
}

extension SubtitlesControl.ViewModel {
    init(_ sections: [SubtitleInformation.Section]) {
        self.init(lines: sections.map(\.lines).joined(separator: "\n"))
    }
}
