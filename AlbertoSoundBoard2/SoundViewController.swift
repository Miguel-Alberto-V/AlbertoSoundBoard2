//
//  SoundViewController.swift
//  AlbertoSoundBoard2
//
//  Created by Miguel on 22/05/24.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var tiempoLabel: UILabel!
    @IBOutlet weak var volumenSlider: UISlider! 

    var grabarAudio: AVAudioRecorder?
    var reproducirAudio: AVAudioPlayer?
    var audioURL: URL?
    var timer: Timer?
    var tiempoTranscurrido: TimeInterval = 0

    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            grabarAudio?.stop()
            grabarButton.setTitle("   GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            tiempoLabel.isHidden = true
            volumenSlider.isHidden = true
            timer?.invalidate()
        } else {
            grabarAudio?.record()
            
            grabarButton.setTitle("   DETENER", for: .normal)
            reproducirButton.isEnabled = false
            agregarButton.isEnabled = false
            tiempoTranscurrido = 0
            tiempoLabel.isHidden = false
            
            iniciarTimer()
        }
    }

    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio?.play()
            reproducirAudio?.volume = volumenSlider.value
            volumenSlider.isHidden = false
            print("Reproduciendo")
        } catch {
            print("Error al reproducir el audio")
        }
    }

    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }

    @IBAction func volumenSliderChanged(_ sender: UISlider) {
        reproducirAudio?.volume = sender.value
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        tiempoLabel.isHidden = true // Ocultar el label al inicio
        volumenSlider.isHidden = true // Ocultar el slider al inicio
        volumenSlider.value = 0.5 // Valor inicial del slider
    }

    func configurarGrabacion() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)

            let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!

            print("***************************")
            print(audioURL!)
            print("***************************")

            var settings: [String: AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?

            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }

    func iniciarTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actualizarTiempoLabel), userInfo: nil, repeats: true)
    }

    @objc func actualizarTiempoLabel() {
        tiempoTranscurrido += 1
        let minutos = Int(tiempoTranscurrido) / 60
        let segundos = Int(tiempoTranscurrido) % 60
        tiempoLabel.text = String(format: "%02d:%02d", minutos, segundos)
    }
}

