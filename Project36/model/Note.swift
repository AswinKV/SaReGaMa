import Foundation
import UIKit

struct Note : Comparable {
    let startTime: Double
    let endTime: Double
    let frequency: Double
    let label: String
}

struct Pitch {
    let timeStamp: Double
    let frequency: Double
}

func < (lhs: Note, rhs: Note) -> Bool {
    return lhs.frequency < rhs.frequency
}

func == (lhs: Note, rhs: Note) -> Bool {
    return lhs.frequency < rhs.frequency
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGFloat {
    let xDist = lhs.x - rhs.x
    let yDist = lhs.y - rhs.y
    return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
}
