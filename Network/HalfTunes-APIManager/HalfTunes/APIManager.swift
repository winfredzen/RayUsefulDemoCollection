/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

/* API for querying iTunes and managing download of tunes
 - Run query data task, store results in array of Tracks
 - Run download task, store file locally
 - Allow for pause/resume and cancel of download task
 */

typealias JSONDictionary = [String: Any]
typealias QueryResult = ([Track]?, String) -> ()

class APIManager {
  
  var tracks: [Track] = []
  var dataTask: URLSessionDataTask?
  let defaultSession = URLSession(configuration: .default)
  //下载的session
  var downloadsSession: URLSession!
  var activeDownloads: [URL: Download] = [:]
  var errorMessage = ""
  
  
  /// 获取搜索的结果
  ///
  /// - Parameters:
  ///   - searchTerm: 搜索的字符串
  ///   - completion: 搜索结果的回调
  func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
    dataTask?.cancel()
    if var url = URLComponents(string: "https://itunes.apple.com/search") {
      url.query = "media=music&entity=song&term=\(searchTerm)"
      dataTask = defaultSession.dataTask(with: url.url!) { data, response, error in
        //闭包退出时执行
        defer { self.dataTask = nil }
        
        if let error = error {
          self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
        } else if let data = data,
          let response = response as? HTTPURLResponse,
          response.statusCode == 200 {
          
          self.updateSearchResults(data)
          
          DispatchQueue.main.async {
            completion(self.tracks, self.errorMessage)
          }
        }
      }
      dataTask?.resume()
    }
  }
  
  // MARK: - Download methods called by TrackCell delegate methods
  
  // Called when the Download button for a track is tapped
  func startDownload(_ track: Track) {
    let download = Download(url: track.previewURL)
    download.task = downloadsSession.downloadTask(with: track.previewURL)
    download.task!.resume()
    download.isDownloading = true
    activeDownloads[download.url] = download
  }
  
  // Called when the Pause button for a track is tapped
  func pauseDownload(_ track: Track) {
    guard let download = activeDownloads[track.previewURL] else { return }
    if download.isDownloading {
      //暂停下载，保存已下载的数据
      download.task?.cancel(byProducingResumeData: { data in
        download.resumeData = data
      })
      download.isDownloading = false
    }
  }
  
  // Called when the Cancel button for a track is tapped
  func cancelDownload(_ track: Track) {
    if let download = activeDownloads[track.previewURL] {
      //取消下载
      download.task?.cancel()
      activeDownloads[track.previewURL] = nil
    }
  }
  
  // Called when the Resume button for a track is tapped
  
  /// 继续下载
  ///
  /// - Parameter track: 数据模型
  func resumeDownload(_ track: Track) {
    guard let download = activeDownloads[track.previewURL] else { return }
    if let resumeData = download.resumeData {
      download.task = downloadsSession.downloadTask(withResumeData: resumeData)
      download.task!.resume()
      download.isDownloading = true
    } else {
      download.task = downloadsSession.downloadTask(with: download.url)
      download.task!.resume()
      download.isDownloading = true
    }
  }
  
  // MARK: - Helper methods
  
  /// 处理搜索数据
  ///
  /// - Parameter data: data数据
  fileprivate func updateSearchResults(_ data: Data) {
    var response: JSONDictionary?
    tracks.removeAll()
    
    do {
      response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
    } catch let parseError as NSError {
      errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
      return
    }
    
    guard let array = response!["results"] as? [Any] else {
      errorMessage += "Dictionary does not contain results key\n"
      return
    }
    
    for trackDictionary in array {
      if let trackDictionary = trackDictionary as? JSONDictionary,
        let previewURLString = trackDictionary["previewUrl"] as? String,
        let previewURL = URL(string: previewURLString),
        let name = trackDictionary["trackName"] as? String,
        let artist = trackDictionary["artistName"] as? String {
        tracks.append(Track(name: name, artist: artist, previewURL: previewURL))
      } else {
        errorMessage += "Problem parsing trackDictionary\n"
      }
    }
  }
  
  // This method generates a permanent local file path to save a track to by appending
  // the lastPathComponent of the URL (i.e. the file name and extension of the file)
  // to the path of the app’s Documents directory.
  func localFilePath(for url: URL) -> URL {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documentsPath.appendingPathComponent(url.lastPathComponent)
  }
  
  // This method checks if the local file exists at the path generated by localFilePath(_:)
  func localFileExists(for track: Track) -> Bool {
    let localUrl = localFilePath(for: track.previewURL)
    var isDir: ObjCBool = false
    return FileManager.default.fileExists(atPath: localUrl.path, isDirectory: &isDir)
  }
  
}
