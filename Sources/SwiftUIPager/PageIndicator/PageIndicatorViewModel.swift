import SwiftUI
import Combine
import CombineSchedulers

class PageIndicatorViewModel: ObservableObject {
    /// Ort im PageIndicator, der durch die Drag focussiert wird
    private enum FocusedArea {
        case start
        case end
    }

    /// Aktualisierungsrate wenn Rolling der Elemente aktiv ist (60 FPS)
    static var ROLL_UPDATE_RATE = Double(1) / Double(60)

    /// Distanze in Punkten, die beim automatischen Rolling zurück gelegt wird
    static var ROLL_DISTANCE_FACTOR = Double(10)

    /// Offset welches auf die Punkte angewant wird
    @Published private(set) var offset: CGFloat = 0

    /// Gesamtgröße der Kollektion von Punkten. Kann breiter sein wenn mehr Punkte existieren als mit maximaler Breite des
    /// PageIndicators dargestellt werden können
    @Published private(set) var collectionSize: CGSize = .zero

    /// Index der aktuell ausgewählten Seite
    @Published var index: Int = 0

    /// Gesamtanzahl der Seiten
    @Published private(set) var count: Int

    /// Maximale Breite des gesamten PageIndicators
    let maxWidth: CGFloat
    
    /// Das styling des PageIndicators
    let styling: PageIndicatorSytling

    private(set) var hasStartedDrag = false
    private(set) var rollTimer: Timer?
    
    private let scheduler: AnySchedulerOf<DispatchQueue>

    /// Das Offset welches auf die Kollektion an Punkten angewant werden muss, damit diese Korrekt am linken Rand des
    /// PageIndicators aligned sind
    var baseOffset: CGFloat {
        if self.collectionSize.width > self.maxWidth {
            return (self.collectionSize.width - self.maxWidth) / 2
        } else {
            return 0
        }
    }

    /// Tatsächliche Breite des PageIndicators. Kann kleiner als ``maxWidth`` wenn weniger Platz benötigt wird um alle Punkte
    /// darzustellen
    var indicatorWidth: CGFloat {
        if self.collectionSize.width > self.maxWidth {
            return maxWidth
        } else {
            return self.collectionSize.width
        }
    }

    /// Breite eines Segments in der Punkte Kollektion. Ein Segment ist definiert durch die Breite eines Punktes + die Breite des
    /// Freiraums zwischen zwei Punkten.
    var segmentWidth: CGFloat {
        self.styling.plain.shape.width + self.styling.spacing
    }

    /// Erzeugt PageIndicatorViewModel
    ///
    /// - Parameter maxWidth: Maximale breite des gesamten PageIndicators
    init(
        initialCount: Int = 0,
        maxWidth: CGFloat = 200,
        styling: PageIndicatorSytling,
        scheduler: AnySchedulerOf<DispatchQueue> = AnyScheduler.main
    ) {
        self.count = initialCount
        self.maxWidth = maxWidth
        self.styling = styling
        self.scheduler = scheduler
    }

    /// Bearbeitet eine Änderung der Drag Geste
    /// - Parameters:
    ///   - startLocation: Startort der Drag Geste
    ///   - translation: Translation der Drag Geste im Verhältnis zum Startort der Geste
    func handleTranslation(
        startLocation: CGPoint,
        translation: CGSize
    ) {
        self.hasStartedDrag = true

        let hOffset = startLocation.x + translation.width

        // Wenn PageIndicator zu klein ist um alle Punkte darzustellen, aktiviere Rolling wenn
        // Rand des PageIndicators fokussiert wird
        if self.collectionSize.width > self.maxWidth {
            // Determine if drag currently focuses start or end area and perform roll
            let focusedArea = self.calcFocusedArea(hOffset: hOffset)
            if let focusedArea = focusedArea, self.isRollRequired(area: focusedArea) {
                self.roll(focusedArea: focusedArea)
            } else {
                self.stopRoll()
            }
        }

        // Bestimme den index der durch Drag Geste fokussiert wird
        let index = calcIndexForOffset(hOffset: hOffset)
        if let index = index {
            // Dispatch UI Änderung auf Main Thread
            self.scheduler.schedule { [weak self] in
                self?.index = index
            }
        }
    }

    /// Bearbeitet das Endevent der Drag Geste
    func handleDragEnding() {
        // Unset that drag has started
        self.hasStartedDrag = false
        self.stopRoll()
    }

    /// Setzt die Größe der Kollektion von Punkten
    func setCollectionSize(size: CGSize) {
        self.collectionSize = size
    }

    /// Setzt den aktuell ausgewählten Index
    func setIndex(_ index: Int) {
        guard index >= 0 && index < self.count else { return }
        withAnimation {
            self.index = index
        }
    }

    /// Setzt die Gesamtanzahl der Punkte des PageIndicator
    func setCount(_ count: Int) {
        self.count = count
    }

    /// Berechnet den Index desjenigen Punktes in der Punktekollektion der mit dem aktuellen Offset focusiert wird
    ///
    /// - Parameter hOffset: Offset innerhalb von ``self.indicatorWidth``
    /// - Returns: Index des fokussierten Elements oder nil wenn freier Raum zwischen Punkten focussiert wird
    private func calcIndexForOffset(hOffset: CGFloat) -> Int? {
        if hOffset >= 0 && hOffset <= self.indicatorWidth {
            // Bestimme Segment
            let segment = Int(hOffset - self.offset) / Int(self.segmentWidth)

            // Bestimme Position innerhalb von collectionSize.width
            let pos = hOffset - (CGFloat(segment) * self.segmentWidth)

            return pos < self.styling.plain.shape.width ? segment : nil
        } else if hOffset < 0 {
            return self.calcIndexForOffset(hOffset: 0)
        } else if hOffset > self.indicatorWidth {
            return self.calcIndexForOffset(hOffset: self.indicatorWidth)
        } else {
            return nil
        }
    }

    /// Berechnet ob offset den start, das Ende oder anderen Bereich innerhalb des PageIndicators fokussiert. Die Breite des Start
    /// und Endbereichs entsprechen der Größe eines Segments
    ///
    /// - Parameter hOffset: Offset innerhalb von ``self.indicatorWidth``
    /// - Returns: Den focussierten Bereich oder nil wenn keiner der Bereiche fokussiert ist
    private func calcFocusedArea(hOffset: CGFloat) -> FocusedArea? {
        let startInterval = 0 ..< self.segmentWidth
        let endInterval = self.maxWidth - self.segmentWidth ..< self.maxWidth

        // Bestimme focussierten Bereich
        if startInterval.upperBound > hOffset {
            return .start
        } else if endInterval.lowerBound < hOffset {
            return .end
        } else {
            return nil
        }
    }

    private func isRollRequired(area: FocusedArea) -> Bool {
        switch area {
        case .start:
            return self.offset < 0
        case .end:
            return self.offset > self.maxWidth - self.collectionSize.width
        }
    }

    /// Startet Rolling (automatisches Scrolling) der Kollektion von Punkten
    /// - Parameter focusedArea: Ort welcher fokusiert ist
    private func roll(focusedArea: FocusedArea) {
        guard self.rollTimer == nil else {
            return
        }

        self.rollTimer = Timer.scheduledTimer(
            withTimeInterval: Self.ROLL_UPDATE_RATE,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }

            let totalSlice = Self.ROLL_DISTANCE_FACTOR * self.segmentWidth
            let slice = totalSlice * Self.ROLL_UPDATE_RATE

            let newOffset = {
                switch focusedArea {
                case .start:
                    var newOffset = self.offset + slice

                    if newOffset > 0 {
                        newOffset = 0
                    }

                    return newOffset
                case .end:
                    var newOffset = self.offset - slice

                    if newOffset < self.maxWidth - self.collectionSize.width {
                        newOffset = self.maxWidth - self.collectionSize.width
                    }

                    return newOffset
                }
            }()

            // Dispatch UI Änderung auf Main Thread
            self.scheduler.schedule { [weak self] in
                self?.offset = newOffset
            }
        }
    }

    /// Stopt das Rolling der Kollektion von Punkten
    private func stopRoll() {
        self.rollTimer?.invalidate()
        self.rollTimer = nil
    }
}
