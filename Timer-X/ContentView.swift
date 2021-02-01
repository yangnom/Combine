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
        .map() { $0.timeIntervalSince(Date()) }
    
    @State var subscriptions = Set<AnyCancellable>()
    @State var cancellable: Cancellable?
    
    
    
    
    var body: some View {
        VStack{
            
            Text("timeLeft is: \(timeLeft)")
                .font(.headline)
                .padding()
            
            // this is the basic way to make and start a Timer
            Button("Normal timer run ") {
                let timer = timerFactory(timerLength: 10)
                
                timer
                    .prefix(while: { $0 > 0.0 })
                    .sink(receiveCompletion: {
                        print("Completed with: \($0)")
                        timeLeft = 0.0
                    }, receiveValue: {
                        timeLeft = $0
                    }).store(in: &subscriptions)
            }.padding()
            
            
            Button("Several timers in a row") {
                let firstSet = 5.0
                var arrayOfTimesPublisher: [Double] = [3, 5, 7]
                let runningTimer = CurrentValueSubject<Double, Never>(firstSet)
                
                runningTimer
                    .sink(receiveValue: {
                        let timer = timerFactory(timerLength: $0)
                        
                        timer
                            .prefix(while: { $0 > 0.0 })
                            .sink(receiveCompletion: { _ in
                                
                                if arrayOfTimesPublisher.count > 0 {
                                    let nextSet = arrayOfTimesPublisher.removeFirst()
                                    timeLeft = nextSet
                                    runningTimer.send(nextSet)
                                } else {
                                    // end of all timers action(s)
                                    timeLeft = 0.0
                                }
                                
                            }, receiveValue: { timeLeft = $0 }).store(in: &subscriptions)
                    }).store(in: &subscriptions)
            }.padding()
            
            // It would be nice to have a function that takes in an array of Doubles
            // and a finishing closure (for when all timers are done)
            Button("Timer(s) made by running a function") {
                
            }
        }
    }
}

// TODO: I really want an array of values that can turn into timers
// of varying timer lengths that start when the previous has ended
func timerFactory(timerLength: Double) -> Publishers.Map<Publishers.Autoconnect<Timer.TimerPublisher>, Double> {
    let now = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        .map { $0.timeIntervalSince(now)}
        .map { round(timerLength - $0)}
    return timer
}

func timerFactoryNoAuto(timerLength: Double) -> Publishers.MakeConnectable<Publishers.Map<Timer.TimerPublisher, Double>> {
    let now = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common)
        .map { $0.timeIntervalSince(now)}
        .map { round(timerLength - $0)}
        .makeConnectable()
    return timer
}

func startATimer(with timerLength: Double) {
    //    var cancellable: Cancellable?
    var subscriptions = Set<AnyCancellable>()
    
    let timer = timerFactory(timerLength: timerLength)
    
    timer
        .print()
        .prefix(while: { $0 > 0.0 })
        .sink(receiveCompletion: {
            print("Finished with: \($0)")
        }, receiveValue: {
            print($0)
        }).store(in: &subscriptions)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
