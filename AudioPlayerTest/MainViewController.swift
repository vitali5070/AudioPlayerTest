//
//  MainViewController.swift
//  AudioPlayerTest
//
//  Created by Vitaly Nabarouski on 4/27/21.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let fileManager = FileManager.default
    var headerHeight: CGFloat = 50
    var audioPlayer = AVAudioPlayer()
    
    let playButton = UIButton()
    let forwardButton = UIButton()
    let backwardButton = UIButton()
    

    
    var songs = [Song]()
    let position: Int = 0
    

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
        
        let song = songs[tag]
        guard let localURLU = song.localURL else {return}
        
        if song.isDownloaded{
            play(url: localURLU)
        }else{
            song.download()
            song.downloadCallBack = { [unowned self] downloaded in
                if downloaded{
                    play(url: localURLU)
                }
            }
        }
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
        
        if song.isDownloaded == true{
            cell.downloadButton.setImage(UIImage.init(systemName: "play.fill"), for: .normal)
        } else {
            cell.downloadButton.setImage(UIImage.init(systemName: "icloud.and.arrow.down.fill"), for: .normal)
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
    
    @objc func playButtonPressed(_ sender: UIButton){
        
        
        let musicPath = Bundle.main.path(forResource: "01. Groundhog Day", ofType: "mp3")
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: musicPath!))
        }
        catch{
            print(error)
        }
        
        switch audioPlayer.isPlaying {
        case true:
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                        audioPlayer.pause()
        default:
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                audioPlayer.play()
        }
    }
    
    func play(url:URL) {
        print("playing \(url)")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            audioPlayer.play()
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
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
        headerView.addSubview(forwardButton)
        headerView.addSubview(backwardButton)

        
        playButton.setImage(UIImage.init(systemName: "play.fill"), for: .normal)
        playButton.imageView?.image?.withTintColor(.gray)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        playButton.addTarget(self, action: #selector(playButtonPressed(_:)), for: .touchUpInside)
        
        forwardButton.setImage(UIImage.init(systemName: "forward.fill"), for: .normal)
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        forwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 10).isActive = true
        
        backwardButton.setImage(UIImage.init(systemName: "backward.fill"), for: .normal)
        backwardButton.translatesAutoresizingMaskIntoConstraints = false
        backwardButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        backwardButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -10).isActive = true
        
        return headerView
    }

}
