
import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

  @IBOutlet weak var drawView: DrawView!
  @IBOutlet weak var predictLabel: UILabel!

  // TODO: Define lazy var classificationRequest

  override func viewDidLoad() {
    super.viewDidLoad()
    predictLabel.isHidden = true
  }

  @IBAction func clearTapped() {
    drawView.lines = []
    drawView.setNeedsDisplay()
    predictLabel.isHidden = true
  }

  @IBAction func predictTapped() {
    guard let context = drawView.getViewContext(),
      let inputImage = context.makeImage()
      else { fatalError("Get context or make image failed.") }
    // TODO: Perform request on model
    let ciImage = CIImage(cgImage: inputImage)
    let handler = VNImageRequestHandler(ciImage: ciImage)
    do {
      try handler.perform([classificationRequest])
    } catch {
      print(error)
    }

  }
    
    
    lazy var classificationRequest: VNCoreMLRequest = {
      // Load the ML model through its generated class and create a Vision request for it.
      do {
        let model = try VNCoreMLModel(for: MNISTClassifier().model)
        return VNCoreMLRequest(model: model, completionHandler: handleClassification)
      } catch {
        fatalError("Can't load Vision ML model: \(error).")
      }
    }()

    func handleClassification(request: VNRequest, error: Error?) {
      guard let observations = request.results as? [VNClassificationObservation]
        else { fatalError("Unexpected result type from VNCoreMLRequest.") }
      guard let best = observations.first
        else { fatalError("Can't get best result.") }

      DispatchQueue.main.async {
        self.predictLabel.text = best.identifier
        self.predictLabel.isHidden = false
      }
    }


}

