//
//  StopwatchView.swift
//  PlateMate
//
//  Created by Märten Tropp on 1/7/25.
//

import SwiftUI

struct StopwatchView: View {
    @State private var startTime: Date? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var isRunning = false
    @State private var timer: Timer? = nil
    @State private var lapTimes: [(String, Int)] = [] // Store lap times along with lap number
    
    let timerFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss.SS" // Format for minutes:seconds.hundredths
        return formatter
    }()
    
    @State private var timerPublisher = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            // Stopwatch time display, split into components
                        HStack(spacing: 0) {
                            Text(formattedMinutes(elapsedTime))
                                .font(.custom("HelveticaNeue", size: 92))
                                .fontWeight(.thin)
                            
                            Text(":").font(.system(size: 92, design: .rounded))
                                .fontWeight(.thin)
                            
                            Text(formattedSeconds(elapsedTime))
                                .font(.custom("HelveticaNeue", size: 92))
                                .fontWeight(.thin)
                            
                            Text(".").font(.system(size: 92, design: .rounded))
                                .fontWeight(.thin)
                            
                            Text(formattedHundredths(elapsedTime))
                                .font(.custom("HelveticaNeue", size: 92))
                                .fontWeight(.thin)
                        }
                        .padding(.horizontal, 15)
                        .padding(.bottom)
                        .padding(.top, 150)

            // Buttons - Start/Pause and Lap/Reset
            HStack(spacing: 20) {
                Button(action: toggleStopwatch) {
                    Text(isRunning ? "Pause" : "Start")
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 75, height: 75)
                        .background(isRunning ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .padding()
                }
                .buttonStyle(BorderlessButtonStyle())
                
                // Lap / Reset Button
                Button(action: isRunning ? recordLap : resetStopwatch) {
                    Text(isRunning ? "Lap" : "Reset")
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 75, height: 75)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .padding()
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.bottom, 20)

            // Lap times display with a fixed layout
            ScrollView {
                VStack {
                    ForEach(lapTimes, id: \.0) { (lapTime, lapNumber) in
                        HStack {
                            // Lap number aligned to the left
                            Text("Lap \(lapNumber)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Lap time aligned to the right
                            Text(lapTime)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            // Initialize startTime when the view appears
            if startTime == nil {
                startTime = Date()
            }
        }
        .onDisappear {
            timer?.invalidate() // Clean up timer when view disappears
        }
        .onReceive(timerPublisher) { _ in
            if isRunning {
                // Update the elapsed time as the timer ticks
                updateElapsedTime()
            }
        }
        .navigationTitle("Stopwatch")
    }

    // Start or pause the stopwatch
    private func toggleStopwatch() {
        if isRunning {
            // Pause the stopwatch
            timer?.invalidate()
        } else {
            // Start the stopwatch
            startTime = Date()
            startTime = startTime?.addingTimeInterval(-elapsedTime)
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                updateElapsedTime()
            }
        }
        isRunning.toggle()
    }

    // Reset the stopwatch
    private func resetStopwatch() {
        timer?.invalidate()
        elapsedTime = 0
        startTime = nil
        isRunning = false
        lapTimes.removeAll() // Clear lap times
    }

    // Record a lap
    private func recordLap() {
        let formattedLapTime = timeFormatted(elapsedTime)
        let lapNumber = lapTimes.count + 1
        lapTimes.insert((formattedLapTime, lapNumber), at: 0) // Insert lap with number at the top
    }

    // Update the elapsed time
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
    }

    // Format elapsed time as mm:ss.SS
    private func timeFormatted(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let hundredths = Int((time - Double(minutes * 60 + seconds)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
    
    // Separate formatting methods for minutes, seconds, and hundredths
    private func formattedMinutes(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        return String(format: "%02d", minutes)
    }

    private func formattedSeconds(_ time: TimeInterval) -> String {
        let seconds = Int(time) % 60
        return String(format: "%02d", seconds)
    }

    private func formattedHundredths(_ time: TimeInterval) -> String {
        let hundredths = Int((time - Double(Int(time) / 60 * 60 + Int(time) % 60)) * 100)
        return String(format: "%02d", hundredths)
    }
}
