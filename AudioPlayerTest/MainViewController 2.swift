//
//  MainViewController.swift
//  AudioPlayerTest
//
//  Created by Vitaly Nabarouski on 4/27/21.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellDelegate, AVAudioPlayerDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var headerHeight: CGFloat = 50
    var audioPlayer: AVAudioPlayer?
    
    let playButton = UIButton()
    let timeSlider = UISlider()
    let timeLabel = UILabel()
    
    
    
    var songs = [Song]()
//    let position: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSongList()
    }
    
    // MARK: Functions
    
    func addSongList(){
        songs.append(Song(name: "Groundhog Day",
                          albumName: "Brightest lights",
                          artistName: "Lane 8",
                          imageName: "artCover",
                          trackURL: "https://www.dropbox.com/s/0iwwuh8unyvmxut/01.%20Groundhog%20Day.mp3?dl=1"))
        songs.append(Song(name: "Road (Feat. Arctic Lake)",
                          albumName: "Brightest lights",
                          artistName: "Lane 8",
                          imageName: "artCover",
                          trackURL:  "https://www.dropbox.com/s/y9v1geqx5nq2jl9/02.%20Road%20%28Feat.%20Arctic%20Lake%29.mp3?dl=1"))
        songs.append(Song(name: "Just",
                          albumName: "Brightest lights",
                          artistName: "Lane 8",
                          imageName: "artCover",
                          trackURL: "https://www.dropbox.com/s/angl3sc08e2rw6a/03.%20Just.mp3?dl=1"))
        songs.append(Song(name: "Brightest Lights (Feat. POLICA)",
                          albumName: "Brightest lights",
                          artistName: "Lane 8",
                          imageName: "artCover",
                          trackURL: "https://www.dropbox.com/s/c683ymjf595d0i2/04.%20Brightest%20Lights%20%28Feat.%20POLICA%29.mp3?dl=1"))
        songs.append(Song(name: "Sunday Song",
                          albumName: "Brightest lights",
                          artistName: "Lane 8",
                          imageName: "artCover",
                          trackURL: "https://www.dropbox.com/s/c6f3crqjipawztw/05.%20Sunday%20Song.mp3?dl=1"))
    }
    
    func downloadButtonPressed(_ tag: Int) {
        
    }
    
    
    
    // MARK: - Table view data source
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InfoCustomCell
        
        let song = songs[indexPath.row]
        
        cell.titleLabel.text = song.name
        cell.songImage.image = UIImage.init(named: song.imageName)
        
        cell.cellDelegate = self
        cell.downloadButton.tag = indexPath.row
        
        let title = song.isDownloaded ? "play.fill" : "icloud.and.arrow.down.fill"
        cell.downloadButton.setImage(UIImage(systemName: title), for: .normal)
        
        cell.downloadButtonCallBack = { [unowned self] in
            guard let localURLU = song.localURL else {return}
            if song.isDownloaded{
                play(url: localURLU)
                self.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }else{
                song.download()
                if cell.downloadProgress.progress < 1 {
                    cell.pauseResumeDownloadButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                    cell.pauseResumeDownloadButton.isHidden = false
                    cell.pauseResumeDownloadButtonCallBack = {
                        // вызов функции паузы загрузки
                        song.pauseDownload()
                    }
                }
                song.downloadCallBack = { [unowned self] downloaded in
                    if downloaded {
                        cell.pauseResumeDownloadButton.isHidden = true
                        cell.downloadButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                        cell.downloadProgress.progress = 0
                        self.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                        play(url: localURLU)
                    }
                }
            }
        }
        song.progressCallBack = { progress in
            cell.downloadProgress.setProgress(progress, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // переход на второй вид и передача мета данных в него
        
        
    }
    
    // MARK: Player functions
    
    @objc func playButtonPressedInHeader(_ sender: UIButton){
        
        guard let player = audioPlayer else {return}
        if player.isPlaying{
            player.stop()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            print("PLAY")
            player.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    
    func play(url:URL) {
        print("playing \(url)")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
        } catch {
            print(error.localizedDescription)
            print("player error")
        }
        
    }
    
    
    // MARK: Setup PlayerView at Header
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return setUpPlayerView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    private func setUpPlayerView() -> UIView?{
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: headerHeight))
        headerView.backgroundColor = .systemBackground
        headerView.addSubview(playButton)
        headerView.addSubview(timeLabel)
        headerView.addSubview(timeSlider)
        
        
        
        playButton.setImage(UIImage.init(systemName: "play.fill"), for: .normal)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        playButton.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 15).isActive = true
        playButton.addTarget(self, action: #selector(playButtonPressedInHeader(_:)), for: .touchUpInside)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -10).isActive = true
        timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.text = "01:20"
    
        timeSlider.translatesAutoresizingMaskIntoConstraints = false
        timeSlider.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        timeSlider.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 10).isActive = true
        timeSlider.rightAnchor.constraint(equalTo: timeLabel.leftAnchor,constant: -10).isActive = true
        
        return headerView
    }
    
}