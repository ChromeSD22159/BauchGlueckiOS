//
//  BGWidgetExtentionLiveActivity.swift
//  BGWidgetExtention
//
//  Created by Frederik Kohler on 23.10.24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BGWidgetExtentionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
       var state: String
       var startDate: Date
       var endDate: Date
       var remainingDuration: Int
   }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BGWidgetExtentionLiveActivity: Widget {
    var theme = Theme.shared
     
     var body: some WidgetConfiguration {
         return ActivityConfiguration(for: BGWidgetExtentionAttributes.self) { context in
             
             lockScreen(endDate: context.state.endDate, name: context.attributes.name)
             

         } dynamicIsland: { context in
             DynamicIsland {
                     DynamicIslandExpandedRegion(.leading) {
                         DynamicIslandCompact(endDate: context.state.endDate, name: context.attributes.name, position: .LargeLeading)
                     }
                 
                     DynamicIslandExpandedRegion(.trailing) {
                         DynamicIslandCompact(endDate: context.state.endDate, name: context.attributes.name, position: .LargeTrailing)
                     }
                     
                     DynamicIslandExpandedRegion(.bottom) {
                         DynamicIslandCompact(endDate: context.state.endDate, name: context.attributes.name, position: .LargeBottom)
                     }
             } compactLeading: {
                 DynamicIslandCompact(endDate: context.state.endDate, name: context.attributes.name, position: .SmallLeading)
             } compactTrailing: {
                 DynamicIslandCompact(endDate: context.state.endDate, name: context.attributes.name, position: .SmallTrailing)
             } minimal: {
                 DynamicIslandCompact(endDate: context.state.endDate, name: context.attributes.name, position: .Minimal)
             }
             .widgetURL(URL(string: "BauchGlueck://test"))
             .keylineTint(Color.red)
         }
     }
     
     @ViewBuilder func TimerView(date: Date) -> some View {
        HStack {
            let range = Date()...Date().addingTimeInterval((date.timeIntervalSinceNow))
            Text(
               timerInterval: range,
               pauseTime: range.lowerBound
            )
            .multilineTextAlignment(.trailing)
            .foregroundStyle(theme.onPrimary)
        }
    }
     
     @ViewBuilder func lockScreen(endDate: Date, name: String) -> some View {
         let range = Date()...Date().addingTimeInterval((endDate.timeIntervalSinceNow))
         
         ZStack {
             theme.background
             
             VStack {
                 HStack(spacing: 12) {
                     Image(.iconStromach)
                         .font(.subheadline)
                         .foregroundStyle(theme.onBackground)
                     
                     Text("\(name) timer")
                         .font(.title)
                 }
                 
                 Spacer()

                 Text(
                    timerInterval: range,
                    pauseTime: range.lowerBound
                 )
                 .font(.largeTitle)
                 .multilineTextAlignment(.center)
                 
                 Spacer()
                 
                 Text("end \(name)")
                     .font(.caption)
                     .foregroundStyle(theme.onPrimary)
                     .padding(.vertical, 5)
                     .padding(.horizontal, 10)
                     .background {
                         RoundedRectangle(cornerRadius: theme.radius)
                             .fill(.ultraThinMaterial)
                             .strokeBorder(.primary, lineWidth: 1)
                     }
                     
             }
             .padding()
             .background {
                 ZStack {
                     HStack {
                         Image(.iconStromach)
                             .font(.largeTitle)
                             .foregroundStyle(theme.onBackground.opacity(0.05))
                         
                         Text("BauchGlück")
                             .font(.system(size: 75))
                             .foregroundStyle(theme.onBackground.opacity(0.0))
                     }
                     
                     Text("BauchGlück")
                         .font(.system(size: 50))
                         .foregroundStyle(theme.onBackground.opacity(0.05))
                 }
             }

         }
     }
     
     @ViewBuilder func DynamicIslandCompact(endDate: Date, name:String, position: ActivityPosition) -> some View {
         switch position {
            case .LargeLeading: Image(.iconStromach).foregroundStyle(theme.primary)
             case .LargeTrailing: Text(name).font(.footnote)
             case .LargeBottom: ZStack {
                 
                 VStack {
                     Spacer()
                     HStack {
                         VStack(alignment: .leading) {
                             Spacer()
                             
                             HStack(alignment: .bottom, spacing: 12) {
                                 Image(systemName: "timer")
                                     .font(.system(size: 36))
                                     .foregroundStyle(theme.onBackground)
                             }
                         }
                         Spacer()
                         VStack(alignment: .trailing) {
                             Spacer()
                             
                             TimerView(date: endDate)
                                 .font(.footnote)
                             
                         }
                     }
                 }
                 .padding(12)
             }
             case .SmallLeading: Image(systemName: "timer")
             case .SmallTrailing: TimerView(date: endDate).font(.footnote)
             case .Minimal: TimerView(date: endDate).font(.footnote)
         }
         
     }
     
}

enum ActivityPosition {
    case LargeLeading, LargeTrailing, LargeBottom, SmallLeading, SmallTrailing, Minimal
}

extension BGWidgetExtentionAttributes {
    fileprivate static var preview: BGWidgetExtentionAttributes {
        BGWidgetExtentionAttributes(name: "Essen Timer")
    }
}

extension BGWidgetExtentionAttributes.ContentState {
    fileprivate static var smiley: BGWidgetExtentionAttributes.ContentState {
        BGWidgetExtentionAttributes.ContentState(state: "running", startDate: Date(), endDate: Calendar.current.date(byAdding: .second, value: 60, to: Date())!, remainingDuration: 2200)
     }
     
     fileprivate static var starEyes: BGWidgetExtentionAttributes.ContentState {
         BGWidgetExtentionAttributes.ContentState(state: "running", startDate: Date(), endDate: Calendar.current.date(byAdding: .second, value: 60, to: Date())!, remainingDuration: 2200)
     }
}

#Preview("Notification", as: .content, using: BGWidgetExtentionAttributes.preview) {
   BGWidgetExtentionLiveActivity()
} contentStates: {
    BGWidgetExtentionAttributes.ContentState.smiley
    BGWidgetExtentionAttributes.ContentState.starEyes
}
