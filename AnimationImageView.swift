//
//  AnimationImageView.swift
//
//  Created by mizutani-bravesoft on 2016/11/16.
//  Copyright © 2016年 bravesoft. All rights reserved.
//

import UIKit

protocol AnimationImageViewDelegate: class {
    func animationImageView(didFinishedAnimation animationImageView: AnimationImageView)
}

class AnimationImageView: UIImageView {
    
    /// アニメーションフレームリスト
    var animationFrameList = Array<AnimationFrame>()
    
    /// ループ回数（0なら無限）
    var numberOfLoopTimes = 0
    
    /// アニメーション終了後に初期画像に戻すかどうか
    var backToFirstImage = false
    
    weak var delegate: AnimationImageViewDelegate?
    
    private var loopFlag = false
    
    /// アニメーションを開始する
    func startAnimation() {
        let defaultImage = self.image
        if !loopFlag {
            loopFlag = true
            DispatchQueue.global().async {
                var loopCounter = self.numberOfLoopTimes
                while self.loopFlag {
                    for i in 0..<self.animationFrameList.count {
                        DispatchQueue.main.async {
                            self.image = self.animationFrameList[i].image
                        }
                        if let time = self.animationFrameList[i].time {
                            Thread.sleep(forTimeInterval: time)
                        }
                    }
                    if loopCounter == 1 {
                        self.loopFlag = false
                        DispatchQueue.main.async {
                            if self.backToFirstImage {
                                self.image = defaultImage
                            }
                            self.delegate?.animationImageView(didFinishedAnimation: self)
                        }
                    }
                    loopCounter -= 1
                }
            }
        }
    }
}

/// アニメーションフレーム
class AnimationFrame {
    private(set) var image: UIImage?
    private(set) var time: TimeInterval?
    
    /// アニメーションフレーム
    ///
    /// - Parameters:
    ///   - image: フレームの画像
    ///   - time: フレームを表示する時間
    init(image: UIImage, time: TimeInterval) {
        self.image = image
        self.time = time
    }
}
