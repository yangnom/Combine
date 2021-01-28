//
//  ContentView.swift
//  Timer-X
//
//  Created by ynom on 1/27/21.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var timeLeft = 100.0
    @State var stringTimeLeft = "Nothing"
    @State var currentDate = Date()
    @State var currentDateString = "Today"
    @State var currentDateDouble = 1.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//        .map() { $0.timeIntervalSince(Date().addingTimeInterval(-20)) }
        .map() { $0.timeIntervalSince(Date()) }

    @State var subscriptions = Set<AnyCancellable>()


    // in the end I want a countdown
    
    var body: some View {
        VStack{
            
            Text("timeLeft is: \(30 - timeLeft)")
                .padding()

            Button("Reset") {
                let timer = timerFactory()
                
                timer
                    .sink() { date in
                        timeLeft = date
                    }.store(in: &subscriptions)
                
                print("reset button hit")
            }
        }
    }
    

    
}

func timerFactory() -> Publishers.Map<Publishers.Autoconnect<Timer.TimerPublisher>, TimeInterval> {
    let now = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        .map { $0.timeIntervalSince(now)}
    return timer
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
