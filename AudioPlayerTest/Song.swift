//
//  Song.swift
//  AudioPlayerTest
//
//  Created by Vitaly Nabarouski on 4/28/21.
//

import Foundation

class Song: NSObject, URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        do {
            try FileManager.default.copyItem(at: location, to: localURL)
            downloadCallBack?(true)
        } catch  {
            print(error)
            downloadCallBack?(false)
        }
        
        
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        let progress: Float = 0.0
        //var progress: Float = 0.0
        self.progressCallBack?(progress)
    }


    init(name: String,
    albumName: String,
    artistName: String,
    imageName: String,
    trackURL: URL) {
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
    let trackURL: URL
    
    var progressCallBack:((_ :Float) -> Void)?
    var downloadCallBack:((_ :Bool) -> Void)?
    
    var localURL: URL {
        let docsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationPath = docsPath.appendingPathComponent(trackURL.lastPathComponent)
        print(destinationPath)
        return destinationPath
    }
    var isDownloaded: Bool {
        let data = FileManager.default.contents(atPath: localURL.absoluteString)
        return data != nil ? true : false
    }
    
    
    
    func download(){
//        let request = URLRequest(url: trackURL)
//
//        let downloadTask = URLSession.shared.downloadTask(with: request) { [unowned self] (url, response, error) in
//
//            guard let tempURL = url, error == nil else {
//                self.downloadCallBack?(false)
//                return
//            }
//
//            do {
//                try FileManager.default.moveItem(at: tempURL, to: localURL)
//                downloadCallBack?(true)
//            } catch  {
//                print(error)
//                downloadCallBack?(false)
//            }
//        }
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
            if FileManager.default.fileExists(atPath: self.localURL.path) {
            print("The file already exists at path")

        } else {
            URLSession.shared.downloadTask(with: self.trackURL) { location, response, error in
                guard let location = location, error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: self.localURL)
                    print("File moved to documents folder")
                } catch {
                    print(error)
                }
            }.resume()
    }
        })
        
}
}
