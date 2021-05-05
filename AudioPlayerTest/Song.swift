//
//  Song.swift
//  AudioPlayerTest
//
//  Created by Vitaly Nabarouski on 4/28/21.
//

import Foundation
import AVFoundation

class Song: NSObject, URLSessionDownloadDelegate {
    
    var progress: Float = 0.0

    init(name: String,
         albumName: String,
         artistName: String,
         imageName: String,
         trackURL: String) {
        self.name = name
        self.albumName = albumName
        self.artistName = artistName
        self.imageName = imageName
        self.trackURL = trackURL
        super.init()
    }
    
    let name: String
    let albumName: String
    let artistName: String
    let imageName: String
    let trackURL: String
    var isDownloading: Bool = false
    var resumeData: Data?
    
    var progressCallBack:((_ :Float) -> Void)?
    var downloadCallBack:((_ :Bool) -> Void)?
    
    var localURL: URL? {
        guard let trackURLU = URL(string: trackURL) else { return nil }
        
        let docsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationPath = docsPath.appendingPathComponent(trackURLU.lastPathComponent)
        print(destinationPath)
        return destinationPath
    }
    var isDownloaded: Bool {
        
        guard let localURLU = localURL else { return false }
        let fileExist = FileManager.default.fileExists(atPath: localURLU.path)
        print(fileExist)
        return fileExist ? true : false
    }
    
    
    
    func download(){
        
        guard let localURLU = localURL, let trackURLU = URL(string: trackURL) else { return }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
            if FileManager.default.fileExists(atPath: localURLU.path) {
                print("The file already exists at path")
            } else {
                let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .current)
                urlSession.downloadTask(with: trackURLU).resume()
                self.isDownloading = true
            }
        })
    }
    
    func pauseDownload(){
        print("PAUSE")
        guard let trackURLU = URL(string: trackURL), isDownloading else {return}

        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .current)
            urlSession.downloadTask(with: trackURLU).cancel(byProducingResumeData: { [unowned self] data in
                guard let data = data else {return}
                self.resumeData = data
          })
        self.isDownloading = false
        })
    }
    
    // MARK: URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            guard let localURLU = self.localURL, downloadTask.error == nil else { return }
            
            do {
                try FileManager.default.copyItem(atPath: location.path, toPath: localURLU.path)
                DispatchQueue.main.async { [unowned self] in
                self.downloadCallBack?(true)
                }
            } catch  {
                print(error.localizedDescription)
                DispatchQueue.main.async { [unowned self] in
                self.downloadCallBack?(false)
                }
                
            }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        
        progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.progressCallBack?(self.progress)
            print(self.progress)
        }
    }
}
