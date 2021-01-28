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
    @State var cancellable: Cancellable?



    // in the end I want a countdown
    
    var body: some View {
        VStack{
            
            Text("timeLeft is: \(timeLeft)")
                .font(.headline)
                .padding()
            
            Button("timer with completion to finish") {
                let timer = timerFactory(timerLength: 10)
                
                timer
                    .prefix(while: { $0 > 0.0 })
                    .sink(receiveCompletion: {
                        print("Completed with: \($0)")
                        timeLeft = 0.0
                    }, receiveValue: {
                        timeLeft = $0
                    }).store(in: &subscriptions)
            }
        }
    }
    

    
}


func timerFactory(timerLength: Double) -> Publishers.Map<Publishers.Autoconnect<Timer.TimerPublisher>, Double> {
    let now = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//        .prefix(while: { (Date().addingTimeInterval(30) + $0) > 0.0 })
        .map { $0.timeIntervalSince(now)}
        .map { round(timerLength - $0)}
    return timer
}

//extension Double {
//    func roundDouble() -> Double {
//        var roundedNumber =
//        return 0.1
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
