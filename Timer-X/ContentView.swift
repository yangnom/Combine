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
            }
            
            // this is trying to iterate over *several* times to make timers with
            // *in succession*
            Button("Three timers in a row") {
                
                let arrayOfTimesPublisher = [60, 30, 20.0]
                let taps = PassthroughSubject<Void, Never>()
                
                    
                    let timer = timerFactory(timerLength: 10)
                    timer
                        .print()
                        .prefix(while: { $0 > 0.0 })
                        .sink(receiveCompletion: {
                            print("Completed with: \($0)")
                            timeLeft = 0.0
                            taps.send()
                          
                            // need a function that does all this publisher / sink
                            // maybe use a traililng closure to start each next timer
                            let timer2 = timerFactory(timerLength: 5)
                                
                            timer2
                                .print()
                                .prefix(while: { $0 > 0.0 })
                                .sink(receiveCompletion: {
                                    print("Finished with: \($0)")
                                    timeLeft = 0.0
                                }, receiveValue: {
                                    timeLeft = $0
                                })
                                .store(in: &subscriptions)
                            
                        }, receiveValue: {
                            timeLeft = $0
                        }).store(in: &subscriptions)
                
            }
            .padding()
            
            // If I can run a function that starts a timer then
            // I can more easily nest it into completion calls for a
            // for loop over an array
            Button("Use a function") {
                
                startATimer(with: 10)
                
            }
            .padding()
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
