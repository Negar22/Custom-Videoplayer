
import UIKit
import AVFoundation

protocol MediaPageViewControllerDelegate {
  func pauseButtonPressed(index:NSInteger)
  func sliderChangedValue(_ sender: UISlider, _ index:NSInteger)
}

class ViewController: UIViewController , UIApplicationDelegate{
  
  // ==================
  // MARK: - Properties
  // ==================
  
  // MARK: Private
  private var videoPlayer: AVPlayer!
  private var playerLayer: AVPlayerLayer!
  private var isVideoPlaying = false
  private var shouldHideSuplementaryViewsStatus = false {
    didSet {
      self.topView?.isHidden = true
      self.bottomView?.isHidden = true
    }
  }
  
  // ===============
  // MARK: - Outlets
  // ===============
  
  // MARK: Private
  @IBOutlet private weak var topView: UIView!
  @IBOutlet private weak var videoView: UIView!
  @IBOutlet private weak var bottomView: UIView!
  @IBOutlet private weak var timeSlider: UISlider!
  @IBOutlet private weak var durationLable: UILabel!
  @IBOutlet private weak var currentTimeLable: UILabel!
}

// ======================
// MARK: - ViewController
// ======================

// MARK: LifeCycle
extension ViewController {
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    videoPlayer.pause()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupURL()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    playerLayer.frame = videoView.bounds
  }
}

// ===============
// MARK: - Methods
// ===============

// MARK: Private
extension ViewController {
  func addTimeObserver () {
    let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    let mainQueue = DispatchQueue.main
    _ = videoPlayer.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: {[weak self] time in
      guard let currentItem = self?.videoPlayer.currentItem
        else{return}
      self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
      self?.timeSlider.minimumValue = 0
      self?.timeSlider.value = Float(currentItem.currentTime().seconds)
      self?.currentTimeLable.text = self?.getTimeString(from: currentItem.currentTime())
    })
  }
  
  func getTimeString(from time:CMTime) -> String{
    let totalSecconds = CMTimeGetSeconds(time)
    let hours = Int(totalSecconds/3600)
    let minutes = Int(totalSecconds/60) % 60
    let secconds = Int(totalSecconds.truncatingRemainder(dividingBy: 60))
    if hours > 0 {
      return String(format: "%i:%02i:%02i", arguments:[hours,minutes,secconds])
    }else{
      return String(format: "%i:%02i", arguments:[minutes,secconds])
    }
  }
  
  func setupURL() {
    let path = NSURL(fileURLWithPath: "/Volumes/FARIBA/NegarCustomVideoPlayer/NegarCustomVideoPlayer/cara.mp4")
    videoPlayer = AVPlayer(url: path as URL)
    videoPlayer.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
    addTimeObserver ()
    playerLayer = AVPlayerLayer(player: videoPlayer)
    playerLayer.videoGravity = .resize
    videoView.layer.addSublayer(playerLayer)
  }
  
  
  // MARK: Public
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "duration", let duration = videoPlayer.currentItem?.duration.seconds, duration > 0.0 {
      self.durationLable.text = getTimeString(from: videoPlayer.currentItem!.duration)
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if bottomView.isHidden == true && topView.isHidden == true{
      self.bottomView.isHidden = false
      self.topView.isHidden = false
    }else{
      self.bottomView.isHidden = true
      self.topView.isHidden = true
    }
  }
}

// ===============
// MARK: - Actions
// ===============

// MARK: Private
private extension ViewController {
  @IBAction func forwardBtn(_ sender: Any){
    guard let duration = videoPlayer.currentItem?.duration
      else {
        return
    }
    
    let currentTime = CMTimeGetSeconds(videoPlayer.currentTime())
    var newTime = currentTime + 15.0
    if newTime < (CMTimeGetSeconds(duration) - 15.0){
      let time : CMTime = CMTimeMake(value: Int64(newTime*1000), timescale: 1000)
      videoPlayer.seek(to: time)
    }else{
      newTime = CMTimeGetSeconds(duration)
      let time : CMTime = CMTimeMake(value: Int64(newTime*1000), timescale: 1000)
      videoPlayer.seek(to: time)
    }
  }
  
  @IBAction func backwardBtn(_ sender: Any) {
    guard (videoPlayer.currentItem?.duration) != nil
      else {
        return
    }
    let currentTime = CMTimeGetSeconds(videoPlayer.currentTime())
    var newTime = currentTime - 15.0
    if newTime < 0.0 {
      newTime = 0
    }
    let time : CMTime = CMTimeMake(value: Int64(newTime*1000), timescale: 1000)
    videoPlayer.seek(to: time)
  }
  
  @IBAction func playerAction(_ sender: UIButton) {
    if isVideoPlaying{
      videoPlayer.pause()
      sender.setTitle("Playe", for: .normal)
    } else {
      videoPlayer.play()
      sender.setTitle("Pause", for: .normal)
    }
    isVideoPlaying = !isVideoPlaying
  }
  
  @IBAction func sliderValueChanged(_ sender: UISlider) {
    videoPlayer.seek(to: CMTimeMake(value: Int64(sender.value*1000), timescale: 1000))
  }
}
