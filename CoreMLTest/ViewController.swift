//
//  ViewController.swift
//  CoreMLTest
//
//  Created by Josh Smith  on 6/5/17.
//  Copyright © 2017 BottleRocketStudio. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
	let model = GoogLeNetPlaces()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let first = #imageLiteral(resourceName: "image3")
		let second = #imageLiteral(resourceName: "image2")
		let third = #imageLiteral(resourceName: "image3")
		let fourth = #imageLiteral(resourceName: "image4")
		let imageArray = [first, second, third, fourth]
		
		for image in imageArray {
			guard let firstPixelBuffer = CreatePixelBufferFromImage(image) else { fatalError("Creating Pixel buffer failed.") }
			guard let firstResult = try? model.prediction(sceneImage: firstPixelBuffer) else { fatalError("Unexpected runtime error.") }
			print(firstResult.sceneLabel)
		}
	}
	
	fileprivate func CreatePixelBufferFromImage(_ image: UIImage) -> CVPixelBuffer?{
		let size = image.size
		var pxbuffer : CVPixelBuffer?
		let pixelBufferPool = createPixelBufferPool(224, 224, FourCharCode(kCVPixelFormatType_32BGRA), 2056) // Hard coded values for demo purposes.
		let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool!, &pxbuffer)
		
		guard (status == kCVReturnSuccess) else{
			return nil
		}
		
		CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
		let pxdata = CVPixelBufferGetBaseAddress(pxbuffer!)
		let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
		let context = CGContext(data: pxdata,
		                        width: Int(size.width),
		                        height: Int(size.height),
		                        bitsPerComponent: 8,
		                        bytesPerRow: CVPixelBufferGetBytesPerRow(pxbuffer!),
		                        space: rgbColorSpace,
		                        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
		
		context?.translateBy(x: 0, y: image.size.height)
		context?.scaleBy(x: 1.0, y: -1.0)
		UIGraphicsPushContext(context!)
		image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
		UIGraphicsPopContext()
		CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
		return pxbuffer
	}
	
	fileprivate func createPixelBufferPool(_ width: Int32, _ height: Int32, _ pixelFormat: FourCharCode, _ maxBufferCount: Int32) -> CVPixelBufferPool? {
		var outputPool: CVPixelBufferPool? = nil
		let sourcePixelBufferOptions: NSDictionary = [kCVPixelBufferPixelFormatTypeKey: pixelFormat,
		                                              kCVPixelBufferWidthKey: width,
		                                              kCVPixelBufferHeightKey: height,
		                                              kCVPixelFormatOpenGLESCompatibility: true,
		                                              kCVPixelBufferIOSurfacePropertiesKey: NSDictionary()]
		
		let pixelBufferPoolOptions: NSDictionary = [kCVPixelBufferPoolMinimumBufferCountKey: maxBufferCount]
		CVPixelBufferPoolCreate(kCFAllocatorDefault, pixelBufferPoolOptions, sourcePixelBufferOptions, &outputPool)
		return outputPool
	}
}

