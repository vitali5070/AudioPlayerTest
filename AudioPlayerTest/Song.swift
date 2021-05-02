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
        return fileExist ? true : false
    }
    
    
    
    func download(){
        
        guard let localURLU = localURL, let trackURLU = URL(string: trackURL) else { return }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
            if FileManager.default.fileExists(atPath: localURLU.path) {
                print("The file already exists at path")
                
            } else {
                
                URLSession.shared.downloadTask(with: trackURLU) { location, response, error in
                    guard let location = location, error == nil else { return }
                    
                    do {
                        try FileManager.default.moveItem(at: location, to: localURLU)
                        print("File moved to documents folder")
                        self.downloadCallBack?(true)
                    } catch {
                        print(error)
                        self.downloadCallBack?(false)
                    }
                }.resume()
            }
        })
    }
    
    // MARK: URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let localURLU = localURL else { return }
        
        do {
            try FileManager.default.copyItem(at: location, to: localURLU)
            downloadCallBack?(true)
        } catch  {
            print(error)
            downloadCallBack?(false)
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
