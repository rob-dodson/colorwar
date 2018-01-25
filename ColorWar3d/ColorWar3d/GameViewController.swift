//
//  GameViewController.swift
//  CW
//
//  Created by Robert Dodson on 1/25/18.
//  Copyright © 2018 Robert Dodson. All rights reserved.
//

import GameplayKit
import SceneKit
import QuartzCore

class GameViewController: NSViewController
{
    var colorlookuptable:[NSColor]?
    var colormat:[Int]?
    var xcells:Int = 75
    var ycells:Int = 75
    var xoffset:Int = 10
    var yoffset:Int = 10
    var boxes:[SCNBox]?
    var cellwidth: Int = 8
    var cellheight: Int = 8
    var celldepth: Int = 8
    var numColors:Int = 256

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        buildmat()
        
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        let xcam = (xcells * cellwidth) / 2
        let ycam = (ycells * cellwidth) / 2
        cameraNode.position = SCNVector3(x: CGFloat(xcam), y: CGFloat(ycam), z: 250)
        cameraNode.camera?.automaticallyAdjustsZRange = true
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 50, y: 50, z: 100)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        // boxes
        boxes = [SCNBox]()
        boxes?.reserveCapacity(xcells * ycells)
        var savenode:SCNNode?
        for xpos in 0..<xcells
        {
            for ypos in 0..<ycells
            {
                let yy = xcells * ypos
                
                let colorindex = colormat![xpos + yy]
                let color = colorlookuptable![colorindex]
                
                let box = SCNBox(width:CGFloat(cellwidth), height:CGFloat(cellheight), length:CGFloat(celldepth), chamferRadius:1)
                let boxnode = SCNNode(geometry:box)
                boxnode.position = SCNVector3(x:CGFloat(xpos * xoffset), y:CGFloat(ypos * yoffset), z:0)
                
                let mat = SCNMaterial()
                mat.diffuse.contents = color
                box.materials = [mat]
                
                scene.rootNode.addChildNode(boxnode)
                
                boxes!.append(box)
                savenode = boxnode
            }
        }
        

       
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        
        
        let actionwait = SCNAction.wait(duration: 0.001)
        let run = SCNAction.run { _ in
            self.draw()
        }
        let moveSequence = SCNAction.sequence([actionwait, run])
        let forever = SCNAction.repeatForever(moveSequence)
        savenode?.runAction(forever) // attach colorwar animations to a single box node.
    }
    
    
    func buildmat()
    {
        colorlookuptable = [NSColor]()
        
        let randomSource = GKARC4RandomSource()
        let colorrand = GKRandomDistribution(randomSource:randomSource,lowestValue: 0, highestValue: 100)
        let colormatrand = GKRandomDistribution(randomSource:randomSource,lowestValue: 0, highestValue: numColors - 1)

        for _ in 0..<numColors
        {
            let red: CGFloat = CGFloat(colorrand.nextInt()) / 100.0
            let green: CGFloat = CGFloat(colorrand.nextInt()) / 100.0
            let blue: CGFloat = CGFloat(colorrand.nextInt()) / 100.0
            
            let color = NSColor(red: red, green: green, blue: blue, alpha: 1.0)
            
            colorlookuptable?.append(color)
        }
        
        
        colormat = [Int](repeating:0,count:xcells * ycells)
        
        for i in 0..<xcells * ycells
        {
            colormat?[i] = (Int(colormatrand.nextInt()))
        }
    }
    
    
    func draw()
    {
        for _ in 1...10
        {
            let x = Int(arc4random_uniform(UInt32(xcells)))
            let y = Int(arc4random_uniform(UInt32(ycells)))
            
            let colorindex = colormat![x + (xcells * y)]
            let color = colorlookuptable![colorindex];
            
            if (x < xcells - 1)
            {
                let index = (x + 1) + (xcells * y)
                colormat![index] = colorindex
                let box = boxes![index]
                box.firstMaterial?.diffuse.contents = color
            }
            
            if (x > 0)
            {
                let index = (x - 1) + (xcells * y)
                colormat![index] = colorindex
                let box = boxes![index]
                box.firstMaterial?.diffuse.contents = color
            }
            
            if (y < ycells - 1)
            {
                let index = x + (xcells * (y + 1))
                colormat![index] = colorindex
                let box = boxes![index]
                box.firstMaterial?.diffuse.contents = color
            }
            
            if (y > 0)
            {
                let index = x + (xcells * (y - 1))
                colormat![index] = colorindex
                let box = boxes![index]
                box.firstMaterial?.diffuse.contents = color
            }
        }
    }
}
