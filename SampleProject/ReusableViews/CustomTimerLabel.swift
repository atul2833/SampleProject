//
//  CustomTimerLabel.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 15/01/2024.
//

import UIKit

class CustomTimerLabel: UILabel {
    
    private var timer: Timer?
    private var remainingSeconds: Int = 0
    private var completion: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.text = "01:00"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.text = "01:00"
    }
    
    deinit {
        stopTimer()
    }
    
    func startTimer(
        seconds: Int,
        textColor: UIColor = .black,
        font: UIFont = AppFont.semi(
            .description
        ),
        completion: @escaping () -> Void
    ) {
        self.textColor = textColor
        self.font = font
        self.remainingSeconds = seconds
        self.completion = completion
        setupTimer()
    }
    
    private func setupTimer() {
        // Timer scheduled to update label text every second
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            updateLabelText()
        } else {
            stopTimer()
        }
    }
    
    private func updateLabelText() {
        DispatchQueue.main.async {
            let minutes = self.remainingSeconds / 60
            let seconds = self.remainingSeconds % 60
            self.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        completion?() // Call completion when the timer is finished
    }
}

