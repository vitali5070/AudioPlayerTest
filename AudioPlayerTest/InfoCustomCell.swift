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
    
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var downloadProgress: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    var song: Song?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        guard let songU = self.song else { return }
        songImage.image = UIImage(named: songU.imageName)
        songU.progressCallBack = { [unowned self] progress in
            self.downloadProgress.progress = progress
            self.layoutIfNeeded()
        }
    }
    
    func setup(with song: Song) {
        self.song = song
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {
        cellDelegate?.downloadButtonPressed(sender.tag)
    }
    
    
}
