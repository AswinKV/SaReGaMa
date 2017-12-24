import Foundation

struct Note : Comparable {
    let startTime: Double
    let endTime: Double
    let frequency: Double
    let label: String
}

func < (lhs: Note, rhs: Note) -> Bool {
    return lhs.frequency < rhs.frequency
}

func == (lhs: Note, rhs: Note) -> Bool {
    return lhs.frequency < rhs.frequency
}
