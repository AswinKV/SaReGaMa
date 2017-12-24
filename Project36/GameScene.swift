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

    var backgroundMusic: SKAudioNode!

    let widthForNote = 72.6
    lazy var totalWidth: Float64 = {
        return widthForNote * audioDuration()
    }()

    override func didMove(to view: SKView) {
        createBackground()
//        drawCents()
        addMusic()
        drawNotes()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    func addMusic() {
        if let musicURL = Bundle.main.url(forResource: "SaReGa_SaReGaMa_2b", withExtension: "wav") {
            backgroundMusic = SKAudioNode(url: musicURL)
            backgroundMusic.autoplayLooped = false
            addChild(backgroundMusic)
        }
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

    func drawCents() {
        let height = size.height / 14
        for i in (1...14) {
            createLine(startPoint: CGPoint(x: 0, y: height * CGFloat(i)), endPoint:  CGPoint(x: size.width, y: height * CGFloat(i)))
        }
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

    func drawNotes() {
        let myNotes = getNotes()
        var playingSong = false
        var lastPoint:Double = Double(size.height / 14)
        for (index, note) in myNotes.enumerated() {
            if index != myNotes.count - 1 && index != 0 {
                let frequency1 = note.frequency
                let frequency2 = myNotes[index + 1].frequency
                let distance = convertToCent(from: frequency1, frequency2: frequency2)
                lastPoint += distance
//                print("distance is \(distance) and lastpoint is \(lastPoint)")
            }
            if !playingSong {
                self.backgroundMusic.run(SKAction.play())
                playingSong = true
            }
            let point = CGPoint(x: note.startTime * widthForNote, y: lastPoint)
            createLine(startPoint: CGPoint(x: 0, y: CGFloat(lastPoint)), endPoint:  CGPoint(x: size.width, y: CGFloat(lastPoint)), color: .black)
            let timeForNote = note.endTime - note.startTime
            let shape = SKShapeNode()
            shape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: timeForNote * widthForNote, height: 5), cornerRadius: 3).cgPath
            shape.position = point
            let moveLeft = SKAction.moveBy(x: CGFloat(-totalWidth), y: 0, duration: audioDuration())
            shape.run(moveLeft)
            shape.strokeColor = UIColor.blue
            shape.lineWidth = 10

            let label = SKLabelNode(text: note.label)
            label.fontName = UIFont.boldSystemFont(ofSize: 24).fontName
            label.fontColor = .black
            let labelPoint = CGPoint(x: note.startTime * widthForNote, y: lastPoint + 16)
            label.position = labelPoint
            label.run(moveLeft)
            addChild(label)
            addChild(shape)
        }
    }

    func convertToCent(from frequency1: Double, frequency2: Double) -> Double {
            return 1200 * log2(frequency2/frequency1)
    }

}
