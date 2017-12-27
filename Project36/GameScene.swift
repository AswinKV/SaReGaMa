//
//  GameScene.swift
//  Project36
//
//  Created by Aswin.K.V on 21/12/17.
//  Copyright © 2017 Appcoder. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {

    private var backgroundMusic: SKAudioNode!
    private var worldNode: SKNode?
    private let widthForNote = 72.6
    private let xPadding = 72.6
    private lazy var totalWidth: Float64 = {
        return widthForNote * audioDuration()
    }()
    private lazy var tonic: Double = {
        if let tonicFile = Bundle.main.path(forResource: "SaReGa_SaReGaMa_2b", ofType: "tonic"),
            let pitchFileData = FileManager.default.contents(atPath: tonicFile),
            let tonic = NSString(data: pitchFileData,
                                 encoding: String.Encoding.utf8.rawValue) {
                return tonic.doubleValue
            }
        fatalError("file not available.")
    }()
    private var playingSong = false
    private var yPadding:Double  {
        return Double(size.height / 14)
    }
    private var onedp:Double {
        return Double(size.height / 1400)
    }

    override func didMove(to view: SKView) {
        worldNode = SKNode()
        self.addChild(worldNode!)
        createBackground()
        drawVerticalLine()
        addMusic()
        drawNotes()
        drawPitches()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view?.isPaused = !(view?.isPaused)!
    }

    func addMusic() {
        if let musicURL = Bundle.main.url(forResource: "SaReGa_SaReGaMa_2b", withExtension: "wav") {
            backgroundMusic = SKAudioNode(url: musicURL)
            backgroundMusic.autoplayLooped = false
            addChild(backgroundMusic)
        }
    }

    func drawVerticalLine() {
        let line = SKShapeNode()
        let path = UIBezierPath()
        let startPoint = CGPoint(x: CGFloat(xPadding), y: 0.0)
        let endPoint = CGPoint(x: CGFloat(xPadding), y: CGFloat(size.height))
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        line.path = path.cgPath
        line.strokeColor = .black
        line.lineWidth = 1
        addChild(line)
    }

    func createLine(startPoint: CGPoint, endPoint: CGPoint, color: UIColor = .white) {
        let line = SKShapeNode()
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        line.path = path.cgPath
        line.strokeColor = color
        line.lineWidth = 1
        addChild(line)
    }

    func createBackground() {
        let background = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1), size: CGSize(width: frame.width, height: frame.height ))
        background.anchorPoint = CGPoint(x: 0.5, y: 1)
        background.position = CGPoint(x: frame.midX, y: frame.height)
        addChild(background)
        background.zPosition = -40
    }

    func audioDuration() -> Float64 {
        if let audioFile = Bundle.main.url(forResource: "SaReGa_SaReGaMa_2b", withExtension: "wav") {
            let audioAsset = AVURLAsset.init(url: audioFile, options: nil)
            let duration = audioAsset.duration
            return CMTimeGetSeconds(duration)
        }
        fatalError("file not available.")
    }

    func getNotes() -> [Note] {
        var arrayOfNotes = [Note]()
        if let notesFile = Bundle.main.path(forResource: "SaReGa_SaReGaMa_2b", ofType: "trans"),
            let notesFileData = FileManager.default.contents(atPath: notesFile),
            let allNotes = NSString(data: notesFileData,
            encoding: String.Encoding.utf8.rawValue) {
                for item in allNotes.components(separatedBy: "\r\n") where !item.isEmpty {
                    let components = item.components(separatedBy: "\t")
                    if let startTime = Double(components[0]),
                    let endTime = Double(components[1]),
                    let frequency = Double(components[2]) {
                        let label = components[3]
                        let note = Note(startTime: startTime, endTime: endTime, frequency: frequency, label: label)
                            arrayOfNotes.append(note)
                }
            }
            return arrayOfNotes
        }
        fatalError("file not available.")
    }

    func getPitch() -> [Pitch] {
        var arrayOfPitches = [Pitch]()
        if let pitchFile = Bundle.main.path(forResource: "SaReGa_SaReGaMa_2b", ofType: "pitch"),
            let pitchFileData = FileManager.default.contents(atPath: pitchFile),
            let allPitches = NSString(data: pitchFileData,
                                    encoding: String.Encoding.utf8.rawValue) {
            for item in allPitches.components(separatedBy: "\r\n") where !item.isEmpty {
                let components = item.components(separatedBy: "\t")
                if let timeStamp = Double(components[0]),
                    let frequency = Double(components[1]) {
                    let pitch = Pitch(timeStamp: timeStamp, frequency: frequency)
                    arrayOfPitches.append(pitch)
                }
            }
            return arrayOfPitches
        }
        fatalError("file not available.")
    }


    func drawPitches() {
        let pitches = getPitch()
        var startPoint = CGPoint(x: CGFloat(self.xPadding), y: 0.0)
        var endPoint = CGPoint(x: CGFloat(self.xPadding), y: 0.0)
        for pitch in pitches {
                let distance = convertToCent(frequency: pitch.frequency)
                DispatchQueue.main.asyncAfter(deadline: .now() + pitch.timeStamp) {
                    let line = SKShapeNode()
                    let path = UIBezierPath()
                    endPoint = CGPoint(x: self.xPadding + pitch.timeStamp * self.widthForNote, y: self.yPadding + (distance * self.onedp))
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                    line.path = path.cgPath
                    line.strokeColor = .darkGray
                    line.lineWidth = 4
                    self.worldNode?.addChild(line)
                    startPoint = endPoint
                }
            }
    }


    func drawNotes() {
        let myNotes = getNotes()
        for note in myNotes {
            let distance = convertToCent(frequency: note.frequency)
            if !playingSong {
                self.backgroundMusic.run(SKAction.play())
                playingSong = true
            }
            let point = CGPoint(x: note.startTime * widthForNote + xPadding, y: yPadding + (distance * onedp))
            createLine(startPoint: CGPoint(x: 0, y: CGFloat(yPadding + (distance * onedp))), endPoint:  CGPoint(x: size.width, y: CGFloat(yPadding + (distance * onedp))), color: .black)
            let timeForNote = note.endTime - note.startTime
            let shape = SKShapeNode()
            shape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: timeForNote * widthForNote, height: 5), cornerRadius: 3).cgPath
            shape.position = point
            shape.strokeColor = UIColor.blue
            shape.lineWidth = 10

            let label = SKLabelNode(text: note.label)
            label.fontName = UIFont.boldSystemFont(ofSize: 24).fontName
            label.fontColor = .black
            let labelPoint = CGPoint(x: note.startTime * widthForNote + xPadding, y: 16 + yPadding + (distance * onedp))
            label.position = labelPoint

            worldNode?.addChild(label)
            worldNode?.addChild(shape)
        }
        let moveLeft = SKAction.moveBy(x: CGFloat(-totalWidth), y: 0, duration: audioDuration())
        worldNode?.run(moveLeft)
    }

    func convertToCent(frequency: Double) -> Double {
        guard frequency > 0  else {
            return 0.0
        }
        return 1200 * log2(frequency/tonic)
    }

}
