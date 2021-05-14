//
//  MainViewController.swift
//  AudioPlayerTest
//
//  Created by Vitaly Nabarouski on 4/27/21.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var songs = [Song]()
    var headerHeight: CGFloat = 50
    var audioPlayer: AVAudioPlayer?
    
    let playButton = UIButton()
    var timeSlider = UISlider()
    let timeLabel = UILabel()
    
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
    
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    // MARK: - Table view data source
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InfoCustomCell
        let song = songs[indexPath.row]
        
        cell.setup(with: song)
        guard let localURLU = song.localURL else {return UITableViewCell()}
        
        song.downloadCallBack = { [unowned self] downloaded in
            if downloaded {
                cell.downloaded()
                self.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                play(url: localURLU)
            }
        }
        
        cell.playPauseCallback = { [unowned self] in
            if self.audioPlayer?.isPlaying == true {
                self.audioPlayer?.pause()
                return false
            } else {
                self.play(url: localURLU)
                return true
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return headerHeight
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailVC"{
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let song = songs[indexPath.row]
            if song.isDownloaded{
                let detailVC = segue.destination as! DetailViewController
                if let localURLU = song.localURL{
                    detailVC.localURL = localURLU
                }
            }
        }
    }
    
    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue){
        guard segue.identifier == "unwindToMainVC" else {return}
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = songs[indexPath.row]
        
        if song.isDownloaded{
            self.performSegue(withIdentifier: "detailVC", sender: self)
        }
    }
    
    // MARK: Player functions
    
    @objc func playButtonPressedInHeader(_ sender: UIButton){
        
        guard let player = audioPlayer else {return}
        if player.isPlaying{
            player.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    @objc func audioTimeController(_ sender: UISlider){
        audioPlayer?.stop()
        audioPlayer?.currentTime = TimeInterval(timeSlider.value)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    @objc func updateTimeValue(){
        if let currentTime = audioPlayer?.currentTime {
            timeSlider.value = Float(currentTime)
            timeLabel.text = timeString(time: currentTime)
        }
    }
    
    func play(url:URL) {
        print("playing \(url)")
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            if let duration = audioPlayer?.duration {
                timeSlider.maximumValue = Float(duration)
            }
            _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimeValue), userInfo: nil, repeats: true)
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print(error.localizedDescription)
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
        playButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        playButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        playButton.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 15).isActive = true
        playButton.addTarget(self, action: #selector(playButtonPressedInHeader(_:)), for: .touchUpInside)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -10).isActive = true
        timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.text = "00:00"
        
        timeSlider.translatesAutoresizingMaskIntoConstraints = false
        timeSlider.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        timeSlider.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 10).isActive = true
        timeSlider.rightAnchor.constraint(equalTo: timeLabel.leftAnchor,constant: -10).isActive = true
        timeSlider.addTarget(self, action: #selector(audioTimeController(_:)), for: .valueChanged)
        
        return headerView
    }
    
}
