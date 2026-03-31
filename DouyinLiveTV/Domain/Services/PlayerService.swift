//
//  PlayerService.swift
//  DouyinLiveTV
//
//  Service for managing AVPlayer lifecycle and playback state.
//  Handles Picture in Picture configuration and basic playback controls.
//

import AVKit
import Combine

public class PlayerService: ObservableObject {
    @Published public private(set) var player: AVPlayer?
    @Published public private(set) var isPlaying: Bool = false

    public init() {}

    public func loadVideo(url: URL) {
        reset()
        let player = AVPlayer(url: url)
        player.allowsPictureInPicturePlayback = true
        self.player = player
    }

    public func play() {
        player?.play()
        isPlaying = true
    }

    public func pause() {
        player?.pause()
        isPlaying = false
    }

    public func resume() {
        player?.play()
        isPlaying = true
    }

    public func reset() {
        player?.pause()
        player = nil
        isPlaying = false
    }
}
