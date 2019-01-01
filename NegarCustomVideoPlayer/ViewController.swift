
import UIKit
import AVFoundation


protocol MediaPageViewControllerDelegate {
    
    func pauseButtonPressed(index:NSInteger)
    func sliderChangedValue(_ sender: UISlider, _ index:NSInteger)
    
}

class ViewController: UIViewController , UIApplicationDelegate{
    
    var videoPlayer: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isVideoPlaying = false
    var shouldHideSuplementaryViewsStatus = false {
        didSet {
            self.topView?.isHidden = true
            self.bottomView?.isHidden = true
        }
    }
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var durationLable: UILabel!
    @IBOutlet weak var currentTimeLable: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = NSURL(fileURLWithPath: "/Volumes/FARIBA/NegarCustomVideoPlayer/NegarCustomVideoPlayer/cara.mp4")
        videoPlayer = AVPlayer(url: path as URL)
        videoPlayer.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        
        addTimeObserver ()
        playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.videoGravity = .resize
        videoView.layer.addSublayer(playerLayer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoPlayer.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = videoPlayer.currentItem?.duration.seconds, duration > 0.0 {
            self.durationLable.text = getTimeString(from: videoPlayer.currentItem!.duration)
        }
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
    
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if bottomView.isHidden == true && topView.isHidden == true{
                self.bottomView.isHidden = false
                self.topView.isHidden = false
            }else{
                self.bottomView.isHidden = true
                self.topView.isHidden = true
            }
        }
    //
    //    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        if timeSlider.isHighlighted == true{
    //            videoPlayer.pause() }
    //        if timeSlider.isHighlighted == false {
    //            videoPlayer.play()
    //        }
    //
    //    }
    //    func pageViewDragged(_ gesture: UIPanGestureRecognizer){
    //        let translation = gesture.translation(in: self.view)
    //        let mainView = gesture.view!
    //        if view.alpha > 0 {
    //            var newAlpha = abs(UIScreen.main.bounds.midY - self.view.center.y) / (4 * UIScreen.main.bounds.height / 10)
    //            if newAlpha > 1 {
    //                newAlpha = 1
    //            }
    //            view.alpha = 1 - newAlpha
    //        } else {
    //            dismiss(animated: true, completion: nil)
    //        }
    //        mainView.center = CGPoint(x: mainView.center.x, y: mainView.center.y + translation.y)
    //        gesture.setTranslation(CGPoint.zero , in: self.view)
    //
    //        if gesture.state == UIGestureRecognizerState.ended{
    //            if view.alpha == 0 {
    //                dismiss(animated: true, completion: nil)
    //            }
    //            UIView.transition(with: mainView, duration: 0.3, options: .allowAnimatedContent , animations: {
    //                mainView.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    //                self.view.alpha = 1
    //            }, completion: nil)
    //        }
    //    }
}
