//
//  ViewController.swift
//  QRcodeTest
//
//  Created by jay on 2017/3/13.
//  Copyright © 2017年 Jay. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    //支援的碼別陣列
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        getQRcode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func getQRcode() {

        // 取得 AVCaptureDevice 類別的實體來初始化一個device物件，並提供video 作為媒體型態參數
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // 使用前面的 device 物件取得 AVCaptureDeviceInput 類別的實體
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // 初始化 captureSession 物件
            captureSession = AVCaptureSession()
            
            // 在capture session 設定輸入裝置
            captureSession?.addInput(input)
            
            // 初始化 captureSession 物件
            let captureMetadataOutput = AVCaptureMetadataOutput()
            
            // 在capture session 設定輸入裝置
            captureSession?.addOutput(captureMetadataOutput)
            
            // 設定代理並使用預設的調度佇列來執行回呼（call back）
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            //設定支援全部的碼別
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // 初始化影像預覽層，並將其加為 viewPreview 視圖層的子層
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            
            // 開始影像擷取
            captureSession?.startRunning()
            
            // 將訊息標籤移到最上層視圖
            view.bringSubview(toFront: messageLabel)
            
            // 初始化 QR Code Frame 來突顯 QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // 假如有錯誤產生、 單純記錄其狀況，不再繼續。
            print(error)
            return
        }
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // 檢查 metadataObjects 陣列是否為非空值，它至少需包含一個物件
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No barcode/QR code is detected"
            return
        }
        
        // 取得原資料（metadata）物件
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        
        
        //        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
        //        qrCodeFrameView?.frame = barCodeObject.bounds
        
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        
        if supportedBarCodes.contains(metadataObj.type) {
            //        if metadataObj.type == AVMetadataObjectTypeQRCode {
            
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            //倘若發現的原資料與 QR code 原資料相同，便更新狀態標籤的文字並設定邊界
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
            }
        }
    }

}


