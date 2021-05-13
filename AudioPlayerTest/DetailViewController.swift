//
//  DetailViewController.swift
//  AudioPlayerTest
//
//  Created by Vitaly Nabarouski on 5/12/21.
//

import UIKit
import AVFoundation

class DetailViewController: UIViewController {
    
    var localURL: URL? = nil
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artWork: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if let localURLU = localURL{
            try! FileManager.default.removeItem(at: localURLU)
        }
        performSegue(withIdentifier: "unwindToMainVC", sender: nil)
    }
    
    // MARK: setup View
    
    func setUpView(){
        if let localURLU = localURL{
            let asset = AVAsset(url: localURLU)
            for metaDataItem in asset.commonMetadata{
                if metaDataItem.commonKey?.rawValue == "title"{
                    let titleData = metaDataItem.value as! String
                    songTitle.text = titleData
                }
                if metaDataItem.commonKey?.rawValue == "type"{
                    let titleData = metaDataItem.value as! String
                    genre.text = titleData
                }
                if metaDataItem.commonKey?.rawValue == "albumName"{
                    let titleData = metaDataItem.value as! String
                    albumName.text = titleData
                }
                if metaDataItem.commonKey?.rawValue == "artist"{
                    let titleData = metaDataItem.value as! String
                    artist.text = titleData
                }
                if metaDataItem.commonKey?.rawValue == "artwork"{
                    let imageData = metaDataItem.value as! Data
                    artWork.image = UIImage(data: imageData)
                }
            }
        }
    }
    
}

