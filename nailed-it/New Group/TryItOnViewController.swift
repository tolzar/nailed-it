import UIKit
import CoreImage
import TCMask
import NVActivityIndicatorView

class TryItOnViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TCMaskViewDelegate, TryItOnLibraryViewControllerDelegate, NVActivityIndicatorViewable {
    @IBOutlet weak var imageView: UIImageView!
    weak var delegate: HamburgerDelegate?
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var selectColorView: UIView!
    @IBOutlet weak var emptyStateText: UILabel!
    
    let imagePicker = UIImagePickerController()
    let size = CGSize(width: 30, height: 30)
    
    var image: UIImage!
    var initialImage: UIImage!
    var mask: TCMask!
    var colorPickedFromLib: PolishColor?
    var currentPolishColor: PolishColor?
    var polishLibraryViewController: TryItOnLibraryViewController!
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get initial image mask data if it exists
        if let loadedImageData = UserDefaults.standard.object(forKey: "savedImage") as? Data {
            if let loadedMaskData = UserDefaults.standard.object(forKey: "savedMask") as? [String:Any] {
                image = UIImage(data: loadedImageData)!
                mask = TCMask(data: loadedMaskData["data"] as! [UInt8], size: CGSizeFromString(loadedMaskData["size"] as! String))
                
                applyImageMask()
                if let colorPickedFromLib = colorPickedFromLib {
                    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
                    polishColor(with: colorPickedFromLib)
                }
                selectColorView.isHidden = false
                emptyStateText.isHidden = true
            }
        } else {
            selectColorView.isHidden = true
            emptyStateText.isHidden = false
        }
        
        cameraView.layer.cornerRadius = cameraView.frame.width / 2
        cameraView.clipsToBounds = true
        
        selectColorView.layer.cornerRadius = cameraView.frame.width / 2
        selectColorView.clipsToBounds = true
    }

    func applyImageMask() {
        imageView.image = mask.blend(foregroundImage: image.tint(tintColor: UIColor.white), backgroundImage: image)
        stopAnimating()
    }
    
    func selectImageFromLibrary() {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func takePhotoFromCamera() {
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func saveImageMaskData() {
        let defaults = UserDefaults.standard
        let maskData: [String:Any] = [
            "data": mask.data,
            "size": NSStringFromCGSize(mask.size)
        ]
        
        defaults.set(UIImagePNGRepresentation(image), forKey: "savedImage")
        defaults.set(maskData, forKey: "savedMask")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        startAnimating(size, message: "Getting your photo ready...", type: NVActivityIndicatorType.ballTrianglePath)
        self.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.image = self.image.resizeImage(targetSize: imageView.frame.size)
        self.initialImage = self.image
        self.imagePicker.dismiss(animated: false, completion: {})
        
        let maskView = TCMaskView(image: self.image)
        maskView.delegate = self
        
        maskView.presentFrom(rootViewController: self, animated: true)
    }
    
    func tcMaskViewDidComplete(mask: TCMask, image: UIImage) {
        startAnimating(size, message: "Getting your photo ready...", type: NVActivityIndicatorType.ballTrianglePath)
        self.mask = mask
        selectColorView.isHidden = false
        emptyStateText.isHidden = true
        applyImageMask()
        saveImageMaskData()
    }
    
    func tcMaskViewWillPushViewController(mask: TCMask, image: UIImage) -> UIViewController! {
        stopAnimating()
        return self
    }
    
    func tcMaskViewDidExit(mask: TCMask, image: UIImage) {
        stopAnimating()
    }
    
    func polishColor(with polishColor: PolishColor?) {
        self.currentPolishColor = polishColor
        let templateImage = image.tint(tintColor: (polishColor?.getUIColor())!)
        
        imageView.image = mask.blend(foregroundImage: templateImage, backgroundImage: image)
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onImageLongPress)))
        
        updateCurrentColorView()
    }
    
    func updateCurrentColorView() {
        // display additional view with color data
        print(self.currentPolishColor)
    }
    
    @objc func onImageLongPress(sender: UILongPressGestureRecognizer) {
        prepareForShareImage()
    }
    
    @IBAction func onSelectCamera(_ sender: Any) {
        
        let actionSheetController = UIAlertController(title: "Upload new photo?", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            // Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        let selectFromLibrary = UIAlertAction(title: "Select From Library", style: .default) { action -> Void in
            self.selectImageFromLibrary()
        }
        actionSheetController.addAction(selectFromLibrary)
        
        let takeAPicture = UIAlertAction(title: "Use Camera", style: .default) { action -> Void in
            self.takePhotoFromCamera()
        }
        actionSheetController.addAction(takeAPicture)
        
        if imageView.image != nil {
            let shareImage = UIAlertAction(title: "Share This Look", style: .default) { action -> Void in
                self.prepareForShareImage()
            }
            actionSheetController.addAction(shareImage)
        }
        
        actionSheetController.popoverPresentationController?.sourceView = self.view as UIView
        self.present(actionSheetController, animated: true, completion: {() -> Void in
            actionSheetController.view.tintColor = UIColor(red:0.98, green:0.66, blue:0.65, alpha:1.0)
        })
    }
    
    @IBAction func onHamburgerPressed(_ sender: Any) {
        delegate?.hamburgerPressed()
    }
    
    func prepareForShareImage() {
        let image = imageView.image
        let imageToShare = [ image!, "Check out this nail polish color by \(self.currentPolishColor!.brand!). It's called \(self.currentPolishColor!.displayName!). Shared via Nailed It"] as [Any]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion:  {() -> Void in
            activityViewController.view.tintColor = UIColor(red:0.98, green:0.66, blue:0.65, alpha:1.0)
        })
    }
    
    @IBAction func onSelectManicure(_ sender: Any) {
        performSegue(withIdentifier: "tryItOnLibSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TryItOnLibraryNavController {
            let polishLib = vc.viewControllers[0] as! TryItOnLibraryViewController
            polishLib.delegate = self
            self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: vc)
            
            segue.destination.modalPresentationStyle = .custom
            segue.destination.transitioningDelegate = self.halfModalTransitioningDelegate
        }
    }
}

extension UIImage {
    // create a UIImage with solid color
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    // colorize image with given tint color
    // this is similar to Photoshop's "Color" layer blend mode
    // this is perfect for non-greyscale source images, and images that have both highlights and shadows that should be preserved
    // white will stay white and black will stay black as the lightness of the image is preserved
    func tint(tintColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw black background - workaround to preserve color of partially transparent pixels
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            // draw original image
            context.setBlendMode(.normal)
            context.draw(self.cgImage!, in: rect)
            
            // tint image (loosing alpha) - the luminosity of the original image is preserved
            let alphaColor = tintColor.withAlphaComponent(0.8)
            alphaColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    // fills the alpha channel of the source image with the given color
    // any color information except to the alpha channel will be ignored
    func fillAlpha(fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw tint color
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
            //            context.fillCGContextFillRect(context, rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
