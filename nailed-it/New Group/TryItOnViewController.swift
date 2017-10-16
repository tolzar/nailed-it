import UIKit
import CoreImage
import TCMask

class TryItOnViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TCMaskViewDelegate, PolishLibraryViewControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectColorButton: UIBarButtonItem!
    weak var delegate: HamburgerDelegate?


    let imagePicker = UIImagePickerController()
    var image: UIImage!
    var initialImage: UIImage!
    var mask: TCMask!
    var polishLibraryViewController: PolishLibraryViewController! {
        didSet {
            polishLibraryViewController.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectColorButton.isEnabled = false
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        polishLibraryViewController = storyboard.instantiateViewController(withIdentifier: "PolishLibraryViewController") as! PolishLibraryViewController
    }
    
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func onTakePhotoSelected(_ sender: Any) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.image = self.image.resizeImage(targetSize: imageView.frame.size)
        self.initialImage = self.image
        self.imagePicker.dismiss(animated: false, completion: {})
        
        let maskView = TCMaskView(image: self.image)
        maskView.delegate = self
        
        maskView.presentFrom(rootViewController: self, animated: true)
    }
    
    func tcMaskViewDidComplete(mask: TCMask, image: UIImage) {
        self.mask = mask
        selectColorButton.isEnabled = true
        
        // adjust the size of image view to make it fit the image size and put it in the center of screen
        var x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat
        if (image.size.width > image.size.height) {
            width = self.view.frame.width
            height = width * image.size.height / image.size.width
            x = 0
            y = (width - height) / 2
        }
        else {
            height = self.imageView.frame.height
            width = self.imageView.frame.width
            x = (height - width) / 2
            y = 0
        }
        //imageView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        imageView.image = mask.blend(foregroundImage: image.fillAlpha(fillColor: UIColor.white.withAlphaComponent(0.6)), backgroundImage: image)
    }
    
    func polishColor(with polishColor: PolishColor?) {
        let templateImage = image.tint(tintColor: polishColor!.getUIColor())
        
        imageView.image = mask.blend(foregroundImage: templateImage.resizeImage(targetSize: mask.size), backgroundImage: image.resizeImage(targetSize: mask.size))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onImageLongPress)))
    }
    
    @objc func onImageLongPress(sender: UILongPressGestureRecognizer) {
        let image = sender.view as! UIImageView
        let imageToShare = [ image.image!, "Image created with Nailed It!" ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func onSelectColor(_ sender: Any) {
        present(polishLibraryViewController, animated: true)
    }
    
    @IBAction func onHamburgerPressed(_ sender: Any) {
        delegate?.hamburgerPressed()
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
            context.setBlendMode(.color)
            tintColor.setFill()
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


