import WidgetKit
import SwiftUI

@main
struct CycleWidgetBundle: WidgetBundle {
    var body: some Widget {
        CycleDayWidget()
        CountdownWidget()
    }
}
