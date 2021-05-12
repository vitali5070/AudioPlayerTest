//
//  InfoCustomCell.swift
//  AudioPlayerTest
//
//  Created by Vitaly Nabarouski on 4/27/21.
//

import UIKit

protocol CellDelegate {
    func downloadButtonPressed(_ tag: Int)
}

class InfoCustomCell: UITableViewCell {
    
    var cellDelegate: CellDelegate?
    var downloadButtonCallBack: ( ()-> Void )?
    var pauseResumeDownloadButtonCallBack: ( ()-> Void )?
    
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
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {
        print("DOWNLOAD")
        
        if ((song?.isDownloading) != nil){
            guard let task = song?.downloadTask else {
                return
            }
            task.cancel()
            self.downloadButton.setImage(UIImage(systemName: "icloud.and.arrow.down.fill"), for: .normal)
        } else {
            downloadButtonCallBack?()
            self.downloadButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        }
    }
    
    @IBAction func pauseResumeDownloadButtonTapped(_ sender: UIButton) {
        pauseResumeDownloadButtonCallBack?()
    }
    
    
}
