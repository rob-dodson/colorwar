//
//  GameViewController.swift
//  ColorWar3d
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
    var colormatrix:[Int]?
    var xcells:Int = 75
    var ycells:Int = 75
    var xspacing:Int = 10
    var yspacing:Int = 10
    var boxes:[SCNBox]?
    var cellwidth: Int = 8
    var cellheight: Int = 8
    var celldepth: Int = 8
    var numColors:Int = 256
    var scene:SCNScene?
    var timewait:Double = 0.001
    var loopCount:Int = 30
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        buildmatrix()
        buildscene()
        runscene()
    }
    
    
    func buildscene()
    {
        //
        // create a new scene
        //
        scene = SCNScene()
        
        
        //
        // create and add a camera to the scene
        //
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene?.rootNode.addChildNode(cameraNode)
        let xcam = (xcells * cellwidth) / 2
        let ycam = (ycells * cellwidth) / 2
        cameraNode.position = SCNVector3(x: CGFloat(xcam), y: CGFloat(ycam), z: 250)
        cameraNode.camera?.automaticallyAdjustsZRange = true
        
        
        //
        // create and add a light to the scene
        //
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 50, y: 50, z: 100)
        scene?.rootNode.addChildNode(lightNode)
        
        //
        // create and add an ambient light to the scene
        //
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene?.rootNode.addChildNode(ambientLightNode)
        
        
        //
        // create boxes and save them in the boxes array
        //
        boxes = [SCNBox]()
        boxes?.reserveCapacity(xcells * ycells)
        
        for xpos in 0..<xcells
        {
            for ypos in 0..<ycells
            {
                let yy = xcells * ypos
                
                let colorindex = colormatrix![xpos + yy]
                let color = colorlookuptable![colorindex]
                
                let box = SCNBox(width:CGFloat(cellwidth), height:CGFloat(cellheight), length:CGFloat(celldepth), chamferRadius:1)
                let boxnode = SCNNode(geometry:box)
                boxnode.position = SCNVector3(x:CGFloat(xpos * xspacing), y:CGFloat(ypos * yspacing), z:0)
                
                let mat = SCNMaterial()
                mat.diffuse.contents = color
                box.materials = [mat]
                
                scene?.rootNode.addChildNode(boxnode)
                boxes!.append(box)
            }
        }
        
        
        //
        // misc scene set up
        //
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
    }
    
    
    func runscene()
    {
        //
        // time wait action
        //
        let actionwait = SCNAction.wait(duration:timewait)
        
        //
        // run action: colorwar animation is done in this action
        //
        let run = SCNAction.run
        { _ in
            self.draw()
        }
        
        //
        // the sequence is an array of two actions
        //
        let moveSequence = SCNAction.sequence([actionwait, run])
        let forever = SCNAction.repeatForever(moveSequence)
        
        //
        // attach colorwar animation to the root node
        //
        scene?.rootNode.runAction(forever)
    }
    
    
    //
    // build a color lookup table and a matrix of colors, one color for each box in the wall of boxes
    //
    func buildmatrix()
    {
        colorlookuptable = [NSColor]()
        
        let randomSource = GKARC4RandomSource()
        let colorrand = GKRandomDistribution(randomSource:randomSource,lowestValue: 0, highestValue: 100)
        let colormatrixrand = GKRandomDistribution(randomSource:randomSource,lowestValue: 0, highestValue: numColors - 1)

        for _ in 0..<numColors
        {
            let red: CGFloat = CGFloat(colorrand.nextInt()) / 100.0
            let green: CGFloat = CGFloat(colorrand.nextInt()) / 100.0
            let blue: CGFloat = CGFloat(colorrand.nextInt()) / 100.0
            
            let color = NSColor(red: red, green: green, blue: blue, alpha: 1.0)
            
            colorlookuptable?.append(color)
        }
        
        colormatrix = [Int](repeating:0,count:xcells * ycells)
        for i in 0..<xcells * ycells
        {
            colormatrix?[i] = (Int(colormatrixrand.nextInt()))
        }
    }
    
    //
    // colorwar's only rule
    //
    func draw()
    {
        for _ in 1...loopCount // this loop count and the timewait setting above seem to make a smooth animation
        {
            let x = Int(arc4random_uniform(UInt32(xcells)))
            let y = Int(arc4random_uniform(UInt32(ycells)))
            
            let colorindex = colormatrix![x + (xcells * y)]
            let color = colorlookuptable![colorindex];
            
            if (x < xcells - 1)
            {
                let index = (x + 1) + (xcells * y)
                colormatrix![index] = colorindex
                let box = boxes![index]
                box.firstMaterial?.diffuse.contents = color
            }
            
            if (x > 0)
            {
                let index = (x - 1) + (xcells * y)
                colormatrix![index] = colorindex
                let box = boxes![index]
                box.firstMaterial?.diffuse.contents = color
            }
            
            if (y < ycells - 1)
            {
                let index = x + (xcells * (y + 1))
                colormatrix![index] = colorindex
                let box = boxes![index]
                box.firstMaterial?.diffuse.contents = color
            }
            
            if (y > 0)
            {
                let index = x + (xcells * (y - 1))
                colormatrix![index] = colorindex
                let box = boxes![index]
                box.firstMaterial?.diffuse.contents = color
            }
        }
    }
}
