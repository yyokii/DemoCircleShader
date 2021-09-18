//
//  ViewController.swift
//  MetalShaderColorFill
//
//  Created by Shuichi Tsutsumi on 2017/09/10.
//  Copyright © 2017 Shuichi Tsutsumi. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController, MTKViewDelegate {

    private let device = MTLCreateSystemDefaultDevice()!
    private var commandQueue: MTLCommandQueue!

    private let vertexData: [Float] = [
        -1, -1, 0, 1,
         1, -1, 0, 1,
        -1,  1, 0, 1,
         1,  1, 0, 1
    ]
    
    private var vertexBuffer: MTLBuffer!
    private var resolutionBuffer : MTLBuffer! = nil
    
    private var renderPipeline: MTLRenderPipelineState!
    private let renderPassDescriptor = MTLRenderPassDescriptor()

    @IBOutlet private weak var mtkView: MTKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMetal()
        makeBuffers()
        makePipeline()
        mtkView.enableSetNeedsDisplay = true
        mtkView.setNeedsDisplay()
    }

    private func setupMetal() {
        commandQueue = device.makeCommandQueue()
        mtkView.device = device
        mtkView.delegate = self
    }

    private func makeBuffers() {
        let size = vertexData.count * MemoryLayout<Float>.size
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: size)
        resolutionBuffer = device.makeBuffer(length: 2 * MemoryLayout<Float>.size, options: [])
    }
    
    private func makePipeline() {
        guard let library = device.makeDefaultLibrary() else {fatalError()}
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        descriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipeline = try! device.makeRenderPipelineState(descriptor: descriptor)
    }
    
    // MARK: - MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateResolution(width: Float(size.width), height: Float(size.height))
    }
    
    func updateResolution(width: Float, height: Float) {
        memcpy(resolutionBuffer.contents(), [width, height], MemoryLayout<Float>.size * 2)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {return}
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {fatalError()}

        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        
        let renderEncoder =
            commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        guard let renderPipeline = renderPipeline else {fatalError()}
        renderEncoder.setRenderPipelineState(renderPipeline)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentBuffer(resolutionBuffer, offset: 0, index: 0)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}

