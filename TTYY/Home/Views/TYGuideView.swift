//
//  TYGuideView.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/6.
//

import UIKit
import BaseModule
import AVFoundation

class TYGuideView: UIView {
    private var bgImgV = UIImageView()
    private var guideImgV = UIImageView()
    private var skipBtn = UIButton()
    private var nextBtn = UIButton()
    private var playerView = UIView()
    private var playerBgImageView = UIImageView()
    private var avPlayer : AVPlayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension TYGuideView {
    func createSubviews() {
        bgImgV.image = UIImage.yjs_webpImage(imageName: "guide_one_bg")
        addSubview(bgImgV)
        bgImgV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(skipBtn)
        let btnBgImg = UIImage(named: "guide_skip")
        skipBtn.setBackgroundImage(btnBgImg, for: .normal)
        skipBtn.setBackgroundImage(btnBgImg, for: .highlighted)
        skipBtn.addTarget(self, action: #selector(skipBtnClick), for: .touchUpInside)
        skipBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen_IPadMultiply(52))
            make.right.equalToSuperview().offset(Screen_IPadMultiply(-30))
            make.width.equalTo(Screen_IPadMultiply(98))
            make.height.equalTo(Screen_IPadMultiply(32))
        }
        
        guideImgV.image = UIImage.yjs_webpImage(imageName: "guide_one")
        addSubview(guideImgV)
        guideImgV.contentMode = .scaleAspectFit
        var imgW = Screen_Width - Screen_IPadMultiply(40)
        if imgW > Screen_IPadMultiply(337) {
            imgW = Screen_IPadMultiply(337)
        }
        let imgH = Screen_IPadMultiply(275) * imgW / Screen_IPadMultiply(337)
        guideImgV.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(imgW)
            make.height.equalTo(imgH)
            make.centerY.equalToSuperview().offset(-4.5)
        }
        
        addSubview(nextBtn)
        nextBtn.setTitle("播放演示", for: .normal)
        nextBtn.setBackgroundColor(UIColor(red: 225/255.0, green: 21/255.0, blue: 33/255.0, alpha: 1.0), for: .normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        nextBtn.titleLabel?.textColor = .white
        nextBtn.layer.cornerRadius = 8;
        nextBtn.clipsToBounds = true
        nextBtn.addTarget(self, action: #selector(nextControlClick), for: .touchUpInside)
        nextBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(guideImgV.snp.bottom).offset(Screen_IPadMultiply(36))
            make.width.equalTo(Screen_IPadMultiply(160))
            make.height.equalTo(44)
        }
        nextBtn.pulse2(withDuration: 0.4)
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
    }
    
    @objc func skipBtnClick() {
        removeFromSuperview()
    }
    
    @objc func nextControlClick() {
        showVideo()
    }
    
    @objc func slienceClick(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        self.avPlayer?.isMuted = !(self.avPlayer?.isMuted ?? false)
    }
    
    func showVideo() {
        guideImgV.isHidden = true
        nextBtn.isHidden = true
        self.addSubview(playerBgImageView)
        self.addSubview(playerView)
        playerBgImageView.layer.cornerRadius = 8
        playerBgImageView.clipsToBounds = true
        playerBgImageView.image = UIImage(named: "video_bg")
        playerBgImageView.contentMode = .scaleAspectFill
        playerView.layer.cornerRadius = 8
        playerView.clipsToBounds = true
        let url = URL(string: "https://advideo.ashupu.com/2021/11/5/174752a5315a4348adcdc0cf618b298f.mp4")!
        self.avPlayer = AVPlayer(url: url)
        let videoAsset = AVURLAsset(url : url)
        var width = UIScreen.main.bounds.size.width - 40 * 2
        var height = UIScreen.main.bounds.size.height - 80 - 160
        
        if let videoAssetTrack = videoAsset.tracks(withMediaType: .video).first{
            let naturalSize = videoAssetTrack.naturalSize;
            if naturalSize.width > 10 {
                let heightDelta = width * videoAssetTrack.naturalSize.height / videoAssetTrack.naturalSize.width
                if heightDelta > height {
                    width = height * videoAssetTrack.naturalSize.width / videoAssetTrack.naturalSize.height
                } else {
                    height = heightDelta
                }
            }
        }
        playerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(height)
            make.width.equalTo(width)
            make.top.equalTo(160)
        }
        playerBgImageView.snp.makeConstraints { make in
            make.edges.equalTo(playerView)
        }
        self.updateConstraintsIfNeeded()
        self.layoutIfNeeded()
        let playerLayer = AVPlayerLayer(player: avPlayer)
        playerLayer.frame = playerView.bounds
        playerLayer.videoGravity = .resizeAspect
        playerView.layer.addSublayer(playerLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        self.avPlayer?.play()
        let slienceButton = UIButton(frame: .zero)
        
        slienceButton.setBackgroundColor(UIColor(white: 0, alpha: 0.34), for: .normal)
        slienceButton.setImage(UIImage(named: "muted"), for: .normal)
        slienceButton.setImage(UIImage(named: "muted_selected"), for: .selected)
        slienceButton.layer.cornerRadius = Screen_IPadMultiply(22) / 2;
        slienceButton.clipsToBounds = true
        playerView.addSubview(slienceButton)
        slienceButton.addTarget(self, action: #selector(slienceClick(_:)), for: .touchUpInside)
        slienceButton.snp.makeConstraints { make in
            make.height.equalTo(Screen_IPadMultiply(22))
            make.width.equalTo(Screen_IPadMultiply(44))
            make.bottom.equalTo(-22)
            make.right.equalTo(playerView.right).offset(-22)
        }
    }
    
    @objc func playbackFinished() {
        removeFromSuperview()
    }
    
    
//    func showThird() {
//        index = 3
//        guideImgV.image = UIImage.yjs_webpImage(imageName: "guide_three")
//        bgImgV.image = UIImage.yjs_webpImage(imageName: "guide_three_bg")
//        var imgW = Screen_Width - Screen_IPadMultiply(40)
//        if imgW > Screen_IPadMultiply(337) {
//            imgW = Screen_IPadMultiply(337)
//        }
//        let imgH = Screen_IPadMultiply(483) * imgW / Screen_IPadMultiply(337)
//        guideImgV.snp.makeConstraints { make in
//            make.width.equalTo(imgW)
//            make.height.equalTo(imgH)
//            make.center.equalToSuperview()
//        }
//        guideImgV.snp.remakeConstraints { make in
//            make.width.equalTo(imgW)
//            make.height.equalTo(imgH)
//            make.bottom.equalToSuperview().offset(Screen_IPadMultiply(-20) - Screen_SafeBottomHeight)
//        }
//        nextControl.snp.remakeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.left.right.equalTo(guideImgV)
//            make.height.equalTo(Screen_IPadMultiply(50))
//            make.centerY.equalTo(guideImgV).offset(Screen_IPadMultiply(40))
//        }
//    }
}
