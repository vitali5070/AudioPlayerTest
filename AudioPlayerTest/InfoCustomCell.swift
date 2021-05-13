//
//  InfoCustomCell.swift
//  AudioPlayerTest
//
//  Created by Vitaly Nabarouski on 4/27/21.
//

import UIKit

class InfoCustomCell: UITableViewCell {
    
    var playPauseCallback: ( ()-> Bool )?
    
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var downloadProgress: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var pauseResumeDownloadButton: UIButton!
    
    var song: Song?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        guard let songU = self.song else { return }
        songImage.image = UIImage(named: songU.imageName)
        songU.progressCallBack = { [unowned self] progress in
            self.downloadProgress.progress += progress
            self.layoutIfNeeded()
        }
    }
    
    func setup(with song: Song) {
        self.song = song
        songImage.image = UIImage(named: song.imageName)
        let title = song.isDownloaded ? "play.fill" : "icloud.and.arrow.down.fill"
        self.downloadButton.setImage(UIImage(systemName: title), for: .normal)
        self.titleLabel.text = song.name
        self.songImage.image = UIImage.init(named: song.imageName)
        song.progressCallBack = { [unowned self] progress in
            self.downloadProgress.progress += progress
            self.layoutIfNeeded()
        }
    }
    
    func download() {
        self.song?.download()
        self.downloadButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        self.pauseResumeDownloadButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        self.pauseResumeDownloadButton.isHidden = false
    }
    
    func stop() {
        self.song?.cancelDownload()
        self.downloadProgress.progress = 0
        self.pauseResumeDownloadButton.isHidden = true
        self.downloadButton.setImage(UIImage(systemName: "icloud.and.arrow.down.fill"), for: .normal)
    }
    
    func suspend() {
        self.song?.pauseDownload()
        self.pauseResumeDownloadButton.setImage(UIImage(systemName: "icloud.and.arrow.down.fill"), for: .normal)
        self.pauseResumeDownloadButton.isHidden = false
    }
    
    func resume() {
        self.song?.resumeDownload()
        self.pauseResumeDownloadButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        self.pauseResumeDownloadButton.isHidden = false
    }
    
    func downloaded() {
        self.pauseResumeDownloadButton.isHidden = true
        self.downloadButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        self.downloadProgress.progress = 0
        self.playPauseSong()
    }
    
    func playPauseSong() {
        guard let isPlaying = self.playPauseCallback?() else { return }
        if isPlaying {
            self.downloadButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            self.downloadButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {
        if self.song?.isDownloaded == true {
            playPauseSong()
            return
        }
        guard let song = self.song else { return }
        switch song.downloadTask?.state {
        case .none:
            self.download()
        case .running, .suspended:
            self.stop()
        default : break
        }
    }
    
    @IBAction func pauseResumeDownloadButtonTapped(_ sender: UIButton) {
        guard let state = self.song?.downloadTask?.state else { return }
        switch state {
        case .running:
            suspend()
        case .suspended:
            resume()
        default: break
        }
    }
}
