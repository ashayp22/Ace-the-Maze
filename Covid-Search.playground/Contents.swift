import Foundation
import PlaygroundSupport
import SpriteKit
import UIKit

// MARK: - Structs

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let User   : UInt32 = 0b1       // 1
    static let Covid: UInt32 = 0b10      // 2
    static let Soap: UInt32 = 0b100      // 4
    static let Block: UInt32 = 0b1000      // 8
    static let Mask: UInt32 = 0b10000      // 16
}

struct Maze {
    static let startX: Int = 26
    static let startY: Int = 201
    static let spriteWidth: Int = 36
    static let spriteDivide: Int = 37
}

struct Game {
    static let red: CGFloat = 207/255
    static let green: CGFloat = 252/255
    static let blue: CGFloat = 255/255
    static let font: String = "ChalkboardSE-Regular"
    static let NumBlocks: Int = 7
}

// MARK: - GameScene

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var mazeArray: [[Int]] = [] //1 is human, 2 is covid, 3 is block, 4 is soap
    private var user: SKSpriteNode? //the user sprite
    private var userX: Int = 4 //the users x pos in the array
    private var userY: Int = 0 // the ysers y pos in the array
    
    private var commandLabel: SKLabelNode? //the command label for the steps
    private var drop: SKSpriteNode? //the drop off spot for the commands
    
    private var selectedNode: SKNode? //the label clicked on by the user
    
    private var animationStarted: Bool = false //true if an animation is occuring
    
    private var collectedSoap: Bool = false //true if the user has collided with the soap
    private var collectedMask: Bool = false //true if the user has collided with the soap

    private var userAction: SKAction? //the sequence for an animation
    
    private var soapSprite: SKSpriteNode? //soap sprite
    private var maskSprite: SKSpriteNode? //mask sprite
    
    //the sprites for the for loops
    private var oneTime: SKSpriteNode?
    private var twoTime: SKSpriteNode?
    private var threeTime: SKSpriteNode?
    private var fourTime: SKSpriteNode?
    
    //the number of times to do a specific command
    var numTimes: Int = 1
    
    //lines typed total
    var linesCode: Int = 0
    //lines typed currently
    var currentCode: Int = 0
    
    var infoText: SKLabelNode?
    
    override func didMove(to view: SKView) {
        
        // Set the background color of a scene
        backgroundColor = SKColor.init(red: Game.red, green: Game.green, blue: Game.blue, alpha: 1)
        
        
        //create the maze game
        createMaze()
        
        //create the UI
        createButtons()
        
        //create the Instructions
        createInstructions()
        
        //create the block code
        createCommands()
        
        //create the block code drop off
        createDrop()
        
        // Set up the physics world to have no gravity
        physicsWorld.gravity = CGVector.zero
        
        
        // Set the scene as the delegate to be notified when two physics bodies collide
        physicsWorld.contactDelegate = self
        
        
        // Play and loop the background music
        let backgroundMusic = SKAudioNode(fileNamed: "audio/playgroundmusic1.wav")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
    }
    //instructions on the screen
    func createInstructions() {

        createText(text: "Click these blocks", fontSize: 8, x: 55, y: 147)
        createText(text: "Your Moves", fontSize: 8, x: 150, y: 150)
        
        self.infoText = createText(text: "Collect the soap and mask", fontSize: 12, x: 100, y: 390)

        
    }
    
    //function for creating text
    func createText(text: String, fontSize: CGFloat, x: Int, y: Int) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Game.font)
        label.attributedText = getCenteredText(text: text, fontsize: fontSize);
        label.fontSize = fontSize
        label.zPosition = 1
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center //center
        label.position = CGPoint(x: x, y: y) //position
        label.fontColor = UIColor.black
        label.numberOfLines = 3
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top //text starts at the top and goes down
        self.addChild(label)
        return label
    }
    
    func createDrop() {
        //create the drop off area
        self.drop = createSprite(filename: "images/dropoff.png", x: 150, y: 75, w: 80, h: 120, z: 0, physics: false, bit: 0, contact: 0, collision: 0, name: "drop")
        
        //create the label for the commands
        self.commandLabel = SKLabelNode(fontNamed: Game.font)
        commandLabel!.text = "";
        commandLabel!.fontSize = 8
        commandLabel!.zPosition = 1
        commandLabel!.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center //center
        commandLabel!.position = CGPoint(x: 150, y: 145) //position
        commandLabel!.fontColor = UIColor.black
        commandLabel!.numberOfLines = 45
        commandLabel!.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top //text starts at the top and goes down
        commandLabel!.name = "commands"
        self.addChild(commandLabel!)
        
    }
    
    func createCommands() {
        //create the commands for moving
        createSprite(filename: "images/up.png", x:  70, y: 120, w: 25, h: 25, z: 1, physics: false, bit: 0, contact: 0, collision: 0, name: "up")
        createSprite(filename: "images/down.png", x:  70, y: 90, w: 25, h: 25, z: 1, physics: false, bit: 0, contact: 0, collision: 0, name: "down")
        createSprite(filename: "images/left.png", x:  70, y: 60, w: 25, h: 25, z: 1, physics: false, bit: 0, contact: 0, collision: 0, name: "left")
        createSprite(filename: "images/right.png", x:  70, y: 30, w: 25, h: 25, z: 1, physics: false, bit: 0, contact: 0, collision: 0, name: "right")
        //create the for loop commands
        self.oneTime = createSprite(filename: "images/1time.png", x:  40, y: 120, w: 25, h: 25, z: 1, physics: false, bit: 0, contact: 0, collision: 0, name: "1time")
        self.twoTime = createSprite(filename: "images/2time.png", x:  40, y: 90, w: 25, h: 25, z: 1, physics: false, bit: 0, contact: 0, collision: 0, name: "2time")
        self.threeTime = createSprite(filename: "images/3time.png", x:  40, y: 60, w: 25, h: 25, z: 1, physics: false, bit: 0, contact: 0, collision: 0, name: "3time")
        self.fourTime = createSprite(filename: "images/4time.png", x:  40, y: 30, w: 25, h: 25, z: 1, physics: false, bit: 0, contact: 0, collision: 0, name: "4time")
        
        let blue = SKAction.colorize(with: UIColor.init(red: 253/255, green: 216/255, blue: 125/255, alpha: 1), colorBlendFactor: 1, duration: 2)

        oneTime!.run(blue)

    }
    
    func createButtons() {
        //create the play button for executing the commands
        createSprite(filename: "images/start.png", x:  55, y: 160, w: 25, h: 25, z: 1, physics: false, bit: 0, contact: 0, collision: 0, name: "start")
        //create the restart button for reseting the scene
        createSprite(filename: "images/restart.png", x:  100, y: 160, w: 25, h: 25, z: 1, physics: false, bit: 0, contact: 0, collision: 0, name: "restart")
            
        //create the restart button for reseting the scene
        createSprite(filename: "images/delete.png", x:  145, y: 160, w: 25, h: 25, z: 1, physics: false, bit: 0, contact: 0, collision: 0, name: "delete")
        }
    
    
    //sets up a 2d array of all zeros based on the length
    func setUpMazeArray(length: Int) -> [[Int]] {
        var tempMaze: [[Int]] = []
        for i in 0..<length {
            var arr: [Int] = []
            for j in 0..<length {
                arr.append(0)
            }
            tempMaze.append(arr)
        }
        return tempMaze
    }
    
    func checkBounds(num: Int, min: Int, max: Int) -> Bool { //returns true if num is greater than min (inclusive) and less than max (exclusive)
        return num >= min && num < max
    }
    
    func checkPosition(x: Int, y: Int) -> Bool { //returns true if a block can be placed at the position
        
        if mazeArray[x][y] != 0 {
            return false
        }
        
        //check in all 8 directions
        
        var inSpot: Int = 0
        
        for i in -1...1 {
            for j in -1...1 {
                if checkBounds(num: x + i, min: 0, max: 5) && checkBounds(num: y + j, min: 0, max: 5) && mazeArray[x + i][y + j] != 0 { //element already exists at the spot
                    inSpot += 1
                }
            }
        }
        
        //more than 2 blocks touching, then you don't want to place a block there
        return !(inSpot >= 2)
        
    }
    
    //depth first search
    func DFS(connections: [Connection], queue: [Int], currentNode: Int, searching: Int) -> Bool {
        
        //break case: if the current node is the target, return true
        if currentNode == searching {
            return true
        }
        
        //all the connections from this current node
        var possibleNodes = [Int]()
        
        for connection in connections {
            if connection.From == currentNode {
                possibleNodes.append(connection.To!)
            }
        }
        
        //for each of the nodes connected
        for possible in possibleNodes {
            
            if !queue.contains(possible) { //not in the current queue
                var newQueue = queue
                newQueue.append(possible)
                
                if(DFS(connections: connections, queue: newQueue, currentNode: possible, searching: searching)) { //found the target
                    return true
                }
            }
        }
        return false
    }
    
    //checks if a maze is beatable
    func checkBeatable(maze: [[Int]], maskPosition: Int, soapPosition: Int) -> Bool {
        
        //generate graph
        
        var connections = [Connection]()
        
        for i in 0..<5 {
            for j in 0..<5 {
                var current = i * 5 + j
                
                if maze[i][j] == 3 || maze[i][j] == 2 { //no connections from a block or covid
                    continue
                }
                
                //up
                
                if checkBounds(num: j + 1, min: 0, max: 5) && maze[i][j + 1] != 3 { //make sure that the connection touching is
                    connections.append(Connection(From: current, To: (i) * 5 + (j + 1)))
                }
                
                
                //down
                
                if checkBounds(num: j - 1, min: 0, max: 5) && maze[i][j - 1] != 3 { //make sure that the connection touching is
                    connections.append(Connection(From: current, To: (i) * 5 + (j - 1)))
                }
                
                
                //left
                
                if checkBounds(num: i - 1, min: 0, max: 5) && maze[i - 1][j] != 3 { //make sure that the connection touching is
                    connections.append(Connection(From: current, To: (i - 1) * 5 + (j)))
                }
                
                //right
                
                if checkBounds(num: i + 1, min: 0, max: 5) && maze[i + 1][j] != 3 { //make sure that the connection touching is
                    connections.append(Connection(From: current, To: (i + 1) * 5 + (j)))
                }
                
                
            }
        }
        
        
        var queue: [Int] = [20]
        
        //depth first search
        
        let foundMask = DFS(connections: connections, queue: queue, currentNode: 20, searching: maskPosition)
        
        let foundSoap = DFS(connections: connections, queue: queue, currentNode: 20, searching: soapPosition)
        
        let foundCovid = DFS(connections: connections, queue: queue, currentNode: 20, searching: 4)
        
        //if else
        
        return foundMask && foundSoap && foundCovid //all three must be reachable
        
    }
    
    //adds red people to the maze
    func addBlocks(maze: [[Int]]) -> [[Int]] {
        
        var tempMaze = maze
        
        //add the red people
        
        for _ in 0..<Game.NumBlocks {
            var a: Int = 0
            (tempMaze, a) = placeInMaze(item: 3, maze: tempMaze)
        }
        
        return tempMaze
        
    }
    
    //places a block in the maze (person, covid, mask, soap)
    func placeInMaze(item: Int, maze: [[Int]]) -> ([[Int]], Int) {
        
        var mazeClone: [[Int]] = maze
        
        var x: Int = Int.random(in: 0...4)
        var y: Int = Int.random(in: 0...4)
        
        while(maze[x][y] != 0) {
            x = Int.random(in: 0...4)
            y = Int.random(in: 0...4)
        }
        
        mazeClone[x][y] = item
                
        return (mazeClone, x * 5 + y)
        
    }
    
    func generateMaze() {
        self.mazeArray = setUpMazeArray(length: 5)
        
        //set up the user and covid
        self.mazeArray[0][4] = 2
        self.mazeArray[4][0] = 1
        
        var returns = placeInMaze(item: 4, maze: self.mazeArray) //add soap
        mazeArray = returns.0
        let soapPosition = returns.1
        
        returns = placeInMaze(item: 5, maze: self.mazeArray) //add mask
        mazeArray = returns.0
        let maskPosition = returns.1
        
        //add the blocks now
        var tempMaze: [[Int]] = addBlocks(maze: mazeArray)
        
        //as long as the maze isn't beatable, keep generating a maze with the blocks in different positions
        while(!checkBeatable(maze: tempMaze, maskPosition: maskPosition, soapPosition: soapPosition)) {
            tempMaze = addBlocks(maze: mazeArray)
        }
        
        mazeArray = tempMaze
        
    }
    
    //creates the maze for the user to solve
    func createMaze() {//add the maze background
                
        
        createSprite(filename: "images/grass.png", x: 100, y: 275, w: 185, h: 185, z: 0, physics: false, bit: PhysicsCategory.None,contact: PhysicsCategory.None, collision: PhysicsCategory.None, name: "background")
        
        
        //generate the maze using the maze array
        
        generateMaze()
                
        //get the textures
        
        var userFrames: [SKTexture] = []
        
        for i in 1...3 {
          let textureName = "images/User/user" + String(i) + ".png"
            userFrames.append(SKTexture(imageNamed: textureName))
        }
        
        var covidFrames: [SKTexture] = []

        for i in 1...7 {
          let textureName = "images/Covid/covid" + String(i) + ".png"
            covidFrames.append(SKTexture(imageNamed: textureName))
        }
        
        var personFrames: [SKTexture] = []

        for i in 1...4 {
          let textureName = "images/Person/person" + String(i) + ".png"
            personFrames.append(SKTexture(imageNamed: textureName))
        }
        
        for i in 0..<5 {
            for j in 0..<5 {
                let block = self.mazeArray[i][j]
                
                if block == 1 { //USER
 
                    self.user = createSprite(filename: "images/user.png", x: Maze.startX + i * Maze.spriteDivide, y: Maze.startY + j * Maze.spriteDivide, w: Maze.spriteWidth, h: Maze.spriteWidth, z: 1, physics: true, bit: PhysicsCategory.User, contact: PhysicsCategory.None, collision: PhysicsCategory.Block, name: "user")
                    
                    self.user!.run(SKAction.repeatForever(
                    SKAction.animate(with: userFrames,
                                     timePerFrame: 1.7,
                                     resize: false,
                                     restore: true)),
                    withKey:"animating")
                } else if block == 2 { //COVID
                    

                    let covid = createSprite(filename: "images/Covid/covid1.png", x: Maze.startX + i * Maze.spriteDivide, y: Maze.startY + j * Maze.spriteDivide, w: Maze.spriteWidth, h: Maze.spriteWidth, z: 1, physics: true, bit: PhysicsCategory.Covid, contact: PhysicsCategory.User, collision: PhysicsCategory.None, name: "covid")
                    
                    
                    covid.run(SKAction.repeatForever(
                       SKAction.animate(with: covidFrames,
                                        timePerFrame: 0.4,
                                        resize: false,
                                        restore: true)),
                       withKey:"animating")
                } else if block == 3 { //PERSON
                    
                    //creates the block
                    let person = createSprite(filename: "images/Person/person1.png", x: Maze.startX + i * Maze.spriteDivide, y: Maze.startY + j * Maze.spriteDivide, w: Maze.spriteWidth, h: Maze.spriteWidth, z: 1, physics: true, bit: PhysicsCategory.Block, contact: PhysicsCategory.User, collision: PhysicsCategory.User, name: "block")
                    
                    person.run(.sequence([
                               .wait(forDuration: 0.2 * Double(i)),
                               .repeatForever(SKAction.animate(with: personFrames,
                               timePerFrame: 1,
                               resize: false,
                               restore: true))
                           ]))
                } else if block == 4 { //SOAP
                    self.soapSprite = createSprite(filename: "images/soap.png", x:  Maze.startX + i * Maze.spriteDivide, y: Maze.startY + j * Maze.spriteDivide, w: Maze.spriteWidth, h: Maze.spriteWidth, z: 1, physics: true, bit: PhysicsCategory.Soap, contact: PhysicsCategory.User, collision: PhysicsCategory.None, name: "soap")
                    
                } else if block == 5 { //MASK
                     self.maskSprite = createSprite(filename: "images/mask.png", x:  Maze.startX + i * Maze.spriteDivide, y: Maze.startY + j * Maze.spriteDivide, w: Maze.spriteWidth, h: Maze.spriteWidth, z: 1, physics: true, bit: PhysicsCategory.Mask, contact: PhysicsCategory.User, collision: PhysicsCategory.None, name: "mask")
                }
            }
        }
        
        
    }
    
    //creates a spritenode based on the parameters
    func createSprite(filename: String, x: Int, y: Int, w: Int, h: Int, z: Int, physics: Bool, bit: UInt32, contact: UInt32, collision: UInt32, name: String) -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: filename)
        //size and position
        sprite.position = CGPoint(x: x, y: y)
        sprite.size.width = CGFloat(w)
        sprite.size.height = CGFloat(h)
        sprite.zPosition = CGFloat(z)
        
        if(physics) {
            //physics
            sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
                   
            // The physics engine will not control the movement of the sprite
            sprite.physicsBody?.isDynamic = true
                   
            // category you want to assign to your sprite
            sprite.physicsBody?.categoryBitMask = bit
                   
            // Notify projectile's contact listener when objects intersect
            sprite.physicsBody?.contactTestBitMask = contact
                   
            // Don't want the sprite to bounce off
            sprite.physicsBody?.collisionBitMask = collision
        }
        //name
         sprite.name = name
        
        // Make the sprite appear on the scene
        addChild(sprite)
        
        return sprite
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    //passed in a sequence of moves such as up, down, left, right
    //executes those actions on the user sprite node
    func sequenceUser(sequence: [String]) {
        
        if sequence.count == 0 { //no animation exists
            self.isUserInteractionEnabled = true
            self.animationStarted = false
            setInfoText()

            return
        }
        
        //array of SKactions for the user
        var arr: [SKAction] = []
        
        //the current position of the user (x and y)
        var userPos: CGPoint = self.user!.position
        
        //iterates over every move passed to the function
        for move in sequence {
            let action: SKAction?
            (action, userPos) = getAction(direction: move, currentPos: userPos) //gets the move and the updated position of the user
            if(action != nil) { //a move was returned
                arr.append(action!)
            }
        }
        
        if arr.count != 0 {
            
            self.userAction = SKAction.sequence(arr) //creates the animation
            user!.run(self.userAction!, completion: {
                //allow the user to interact
                self.isUserInteractionEnabled = true
                self.animationStarted = false
                self.setInfoText()

            })
        } else {
            //allow the user to interact
            self.isUserInteractionEnabled = true
            self.animationStarted = false
            setInfoText()

        }
    }
    
    //based on the parameter, the function returns an SKAction and the updated position of the user after the SKAction completes
    func getAction(direction: String, currentPos: CGPoint) -> (SKAction?, CGPoint) {
                
        if(direction == "up") {
            if (userY < 4 && mazeArray[userX][userY + 1] != 3) { //make sure the user will stay inbounds and that the user isn't running into a block
                let moveUp = SKAction.move(to: CGPoint(x: currentPos.x, y: currentPos.y + CGFloat(Maze.spriteDivide)), duration:1.0)
                userY += 1
                return (moveUp, CGPoint(x: currentPos.x, y: currentPos.y + CGFloat(Maze.spriteDivide)))
            }
        } else if(direction == "down") {
            if (userY > 0 && mazeArray[userX][userY - 1] != 3) { //make sure the user will stay inbounds and that the user isn't running into a block
                let moveDown = SKAction.move(to: CGPoint(x: currentPos.x, y: currentPos.y - CGFloat(Maze.spriteDivide)), duration:1.0)
                userY -= 1
                return (moveDown, CGPoint(x: currentPos.x, y: currentPos.y - CGFloat(Maze.spriteDivide)))
            }
        } else if(direction == "left") {
            if (userX > 0 && mazeArray[userX - 1][userY] != 3) { //make sure the user will stay inbounds and that the user isn't running into a block
                let moveLeft = SKAction.move(to:CGPoint(x: currentPos.x - CGFloat(Maze.spriteDivide), y: currentPos.y), duration:1.0)
                userX -= 1
                return (moveLeft, CGPoint(x: currentPos.x - CGFloat(Maze.spriteDivide), y: currentPos.y))
            }
        } else if(direction == "right") {
            if (userX < 4 && mazeArray[userX + 1][userY] != 3) { //make sure the user will stay inbounds and that the user isn't running into a block
                let moveRight = SKAction.move(to:CGPoint(x: currentPos.x + CGFloat(Maze.spriteDivide), y: currentPos.y), duration:1.0)
                userX += 1
                return (moveRight, CGPoint(x: currentPos.x + CGFloat(Maze.spriteDivide), y: currentPos.y))
            }
        }
        return (nil, currentPos)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first! as UITouch
        let positionInScene = touch.location(in: self)
        let previousPosition = touch.previousLocation(in: self)
        let touchedNode = self.atPoint(positionInScene)
        
        selectedNode = touchedNode //updates the selected node
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first! as UITouch
        let positionInScene = touch.location(in: self)
        let previousPosition = touch.previousLocation(in: self)
        
        //code for moving a sprite when dragging
//        if let name = selectedNode!.name {
//            if name == "up" || name == "down" || name == "left" || name == "right" { //only the blocks that can be moved
//                //moves the blocks
//                let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
//                panForTranslation(translation: translation)
//            }
//        }
        
    }
    
    //executes the commands
    func executeCommands() {
        if(!animationStarted) { //makes sure that an animation isn't occuring
            let commandString: String = commandLabel!.text! //the commands in text form
            var commands: [String] = commandString.components(separatedBy: ["\n"]) //splits the commands
            commands = commands.filter { $0 != "" } //removes ""
            
            //more parsing
            var parsedCommands: [String] = []
            
            for command in commands {
                var parsedCommand: String = command.substring(from: 5) //removes the 'move'
                var direction = parsedCommand.substring(to: parsedCommand.distance(of: " ")!) //gets the direction - up, down, left, right
                parsedCommand = parsedCommand.substring(from: parsedCommand.distance(of: " ")! + 1) //removes everything before the direction, including the direction
                var timesString = parsedCommand.substring(to: parsedCommand.distance(of: " ")!) //gets the number of times
                var timesInt: Int = Int(timesString) ?? 0 //string to int
                
                //for the number of times the command should be run it is appended to the array
                for i in 0..<timesInt {
                    parsedCommands.append(direction)
                }
                
            }
            
            //start the animation
            animationStarted = true
            self.isUserInteractionEnabled = false
            self.infoText?.attributedText = getCenteredText(text: "Playing...", fontsize: 12)
            sequenceUser(sequence: parsedCommands)
            //clear the label
            commandLabel!.text = ""
            currentCode = 0

        }
    }
    
    //restart the level
    func restart() {
        //clear the commands
        commandLabel!.text = ""
        
        //clear the animation
        if(animationStarted) {
            self.user?.removeAllActions()
            animationStarted = false
            self.isUserInteractionEnabled = true
        }
        
        //show the soap
        
        soapSprite?.isHidden = false
        collectedSoap = false
        
        maskSprite?.isHidden = false
        collectedMask = false
        
        //reset the user
        user?.position = CGPoint(x: Maze.startX + 4 * Maze.spriteDivide, y: Maze.startY + 0 * Maze.spriteDivide)
        
        userX = 4
        userY = 0
        
        linesCode = 0
        currentCode = 0
        setInfoText()
    }
    
    func setInfoText() {
        if !collectedMask && !collectedSoap {
            self.infoText?.attributedText = getCenteredText(text: "Collect the soap and mask", fontsize: 12)
        } else if !collectedSoap {
            self.infoText?.attributedText = getCenteredText(text: "Collect the soap", fontsize: 12)
        } else if !collectedMask {
            self.infoText?.attributedText = getCenteredText(text: "Collect the mask", fontsize: 12)
        } else {
            self.infoText?.attributedText = getCenteredText(text: "Go destroy the red COVID-19", fontsize: 12)
        }
    }
    
    //translate the selectedNode
    func panForTranslation(translation: CGPoint) {
        let position = selectedNode?.position
        
        selectedNode!.position = CGPoint(x: position!.x + translation.x, y: position!.y + translation.y)
    }
    
    //returns the number of times in text format
    func getTimes() -> String {
        if numTimes == 1 {
            return "1 time"
        }
        return String(numTimes) + " times"
    }
   
    //touches has ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch:UITouch = touches.first! as UITouch
        let positionInScene = touch.location(in: self)
               
        if let name = selectedNode!.name {
            if name == "start" {
                executeCommands() //start the animation
            } else if name == "restart" {
                restart() //reset
            } else if name == "delete" {
                var currentCommands: String = commandLabel?.text ?? ""
                
                if currentCommands != "" {
                    commandLabel!.text  = currentCommands.substring(to: currentCommands.lastIndex(of: "\n")!)
                    linesCode -= 1
                    currentCode -= 1
                }
                
            } else {
                //if the selected node that the user is dragging is within the bounds of the drop off spot
                //the user also can't have too many lines on the screen
//                let withinDrop: Bool = selectedNode!.position.x > drop!.position.x - drop!.size.width / 2 &&  selectedNode!.position.x < drop!.position.x + drop!.size.width / 2 && selectedNode!.position.y > drop!.position.y - drop!.size.height / 2 &&  selectedNode!.position.y < drop!.position.y + drop!.size.height / 2 && linesCode <= 9
                let withinDrop = currentCode <= 9
                
                if (name == "up") {
                    if (withinDrop) {
                        commandLabel!.text = commandLabel!.text! + "\n" + "move up " + getTimes()
                        linesCode += 1
                        currentCode += 1
                    }
                    selectedNode!.position = CGPoint(x: 70, y: 120)
                
                } else if (name == "down") {
                    if (withinDrop) {
                        commandLabel!.text = commandLabel!.text! + "\n" + "move down " + getTimes()
                        linesCode += 1
                        currentCode += 1
                    }
                    selectedNode!.position = CGPoint(x: 70, y: 90)
                
                } else if (name == "left") {
                    if (withinDrop) {
                        commandLabel!.text = commandLabel!.text! + "\n" + "move left " + getTimes()
                        linesCode += 1
                        currentCode += 1
                    }
                    selectedNode!.position = CGPoint(x: 70, y: 60)
                   
                } else if(name == "right") {
                    if (withinDrop) {
                        commandLabel!.text = commandLabel!.text! + "\n" + "move right " + getTimes()
                        linesCode += 1
                        currentCode += 1
                    }
                    selectedNode!.position = CGPoint(x: 70, y: 30)
                    
                } else if(name == "1time") {
                    
                    //colorize the buttons
                    
                    self.infoText?.attributedText = getCenteredText(text: "Changing...", fontsize: 12)
                    
                    let color = SKAction.colorize(with: UIColor.init(red: 253/255, green: 216/255, blue: 125/255, alpha: 1), colorBlendFactor: 1, duration: 1)
                    let white = SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 1)
                    self.isUserInteractionEnabled = false
                    oneTime!.run(color, completion: {
                        self.isUserInteractionEnabled = true
                        self.setInfoText()
                    })
                    twoTime!.run(white)
                    threeTime!.run(white)
                    fourTime!.run(white)
                    
                    numTimes = 1
                    
                } else if(name == "2time") {
                    
                    self.infoText?.attributedText = getCenteredText(text: "Changing...", fontsize: 12)
                    
                    //colorize the buttons
                    
                    let color = SKAction.colorize(with: UIColor.init(red: 253/255, green: 216/255, blue: 125/255, alpha: 1), colorBlendFactor: 1, duration: 1)
                    let white = SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 1)
                    self.isUserInteractionEnabled = false

                    oneTime!.run(white, completion: {
                        self.isUserInteractionEnabled = true
                        self.setInfoText()
                    })
                    twoTime!.run(color)
                    threeTime!.run(white)
                    fourTime!.run(white)
                    
                    numTimes = 2
                    
                } else if(name == "3time") {
                    
                    self.infoText?.attributedText = getCenteredText(text: "Changing...", fontsize: 12)
                    
                    //colorize the buttons
                    
                    let color = SKAction.colorize(with: UIColor.init(red: 253/255, green: 216/255, blue: 125/255, alpha: 1), colorBlendFactor: 1, duration: 1)
                    let white = SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 1)
                    self.isUserInteractionEnabled = false

                    oneTime!.run(white, completion: {
                        self.isUserInteractionEnabled = true
                        self.setInfoText()

                    })
                    twoTime!.run(white)
                    threeTime!.run(color)
                    fourTime!.run(white)
                    
                    numTimes = 3
                    
                } else if(name == "4time") {
                    
                    self.infoText?.attributedText = getCenteredText(text: "Changing...", fontsize: 12)
                    
                    //colorize the buttons
                    
                    let color = SKAction.colorize(with: UIColor.init(red: 253/255, green: 216/255, blue: 125/255, alpha: 1), colorBlendFactor: 1, duration: 1)
                    let white = SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 1)
                    self.isUserInteractionEnabled = false

                    oneTime!.run(white, completion: {
                        self.isUserInteractionEnabled = true
                        self.setInfoText()

                    })
                    twoTime!.run(white)
                    threeTime!.run(white)
                    fourTime!.run(color)
                    
                    numTimes = 4
                    
                }
            }
        }
    }
    
    func getCenteredText(text: String, fontsize: CGFloat) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let range = NSRange(location: 0, length: text.count)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: Game.font, size: fontsize)], range: range)
        return attrString
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
    

    
    // Called whenever two physics bodies collide
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Sort by category bit masks
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Chech if the two bodies that collide are the projectile and monster
        if ((firstBody.categoryBitMask & PhysicsCategory.User == 1)) {
            if (secondBody.categoryBitMask & PhysicsCategory.Covid != 0) {
                let reveal = SKTransition.flipHorizontal(withDuration: 2)
                let gameOverScene = GameOverScene(size: self.size, soap: collectedSoap, mask: collectedMask, code: linesCode)
                self.view?.presentScene(gameOverScene, transition: reveal)
            } else if (secondBody.categoryBitMask & PhysicsCategory.Soap != 0) {
                secondBody.node?.isHidden = true
                collectedSoap = true
            } else if (secondBody.categoryBitMask & PhysicsCategory.Mask != 0) {
                secondBody.node?.isHidden = true
                collectedMask = true
            }
        }
            
        
    }
}



// MARK: - Connection Class

class Connection {
    
    public var From: Int?
    public var To: Int?
    
    init(From: Int, To: Int) {
        self.From = From
        self.To = To
    }
    
    
}

// MARK: - EXTENSIONS

extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}

extension StringProtocol {
    func distance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
    func distance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}


// MARK: - Game Over Scene

class GameOverScene: SKScene, SKPhysicsContactDelegate {
    
    private var won: Bool = true
    private var code: Int = 0
    
    init(size: CGSize, soap:Bool, mask: Bool, code: Int) {
        
        super.init(size: size)
        
        // Set the background color to white
        backgroundColor = SKColor.init(red: Game.red, green: Game.green, blue: Game.blue, alpha: 1)
        
        // Set the message to either "You Won" or "You Lose"
        
        var message = "You Defeated\nCOVID-19!"
        var message2 = "Click to try again!"
        
        won = soap && mask
        self.code = code
        
        if !soap && !mask {
            message = "You forgot\nSoap and a Mask!"
        } else if !mask {
            message = "You forgot\na Mask!"
        } else if !soap {
            message = "You forgot\nSoap!"
        } else {
            //convert the code drag and dropped to swift
            if code == 1 {
                message2 = "You just typed 1 line code!\n\nClick to learn more about code"
            } else {
                message2 = "You just typed " + String(code) + " lines of code!\n\nClick to learn more about code"
            }
        }
        if won {
            let codeExample = SKSpriteNode(imageNamed: "images/smilingemoji.png")
                   //size and position
                   codeExample.position = CGPoint(x: 100, y: 100)
                   codeExample.size.width = CGFloat(75)
                   codeExample.size.height = CGFloat(75)
                   codeExample.zPosition = CGFloat(1)
                   
                   // Make the sprite appear on the scene
                   addChild(codeExample)
        } else {
            let codeExample = SKSpriteNode(imageNamed: "images/sadface.png")
            //size and position
            codeExample.position = CGPoint(x: 100, y: 100)
            codeExample.size.width = CGFloat(75)
            codeExample.size.height = CGFloat(75)
            codeExample.zPosition = CGFloat(1)
            
            // Make the sprite appear on the scene
            addChild(codeExample)
        }
        
       
        
        // Display a label of text to the screen
        var label = SKLabelNode(fontNamed: Game.font)
        label.attributedText = getCenteredText(text: message, fontSize: 20)
        label.fontSize = 20
        label.numberOfLines = 3
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: 250)
        addChild(label)
        
        // Display a label of text to the screen
        var label2 = SKLabelNode(fontNamed: Game.font)
        label2.attributedText = getCenteredText(text: message2, fontSize: 12)
        label2.fontSize = 12
        label2.numberOfLines = 3
        label2.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label2.fontColor = SKColor.black
        label2.position = CGPoint(x: size.width/2, y: 175)
        addChild(label2)
        
        let backgroundMusic = SKAudioNode(fileNamed: "audio/playgroundmusic3.wav")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
    }
    
    func getCenteredText(text: String, fontSize: Int) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let range = NSRange(location: 0, length: text.count)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: Game.font, size: CGFloat(fontSize))], range: range)
        return attrString
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            if(self.won) {
                let reveal = SKTransition.flipHorizontal(withDuration: 2)
                let scene = CodeScene(size: self.size, code: self.code)
                self.view?.presentScene(scene, transition:reveal)
            } else {
                // Transition to a new scene in SpriteKit
                let scene = GameScene(size: self.size)
                self.view?.presentScene(scene)
                self.isUserInteractionEnabled = false
            }
    }
    
    // Dummy implementation with a fatalError(_:)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - CodeScene

class CodeScene: SKScene {
    
    
    init(size: CGSize, code: Int) {
        
        super.init(size: size)
        // Set the background color to white
        backgroundColor = SKColor.init(red: Game.red, green: Game.green, blue: Game.blue, alpha: 1)
        
        // Display a label of text to the screen
        var label = SKLabelNode(fontNamed: Game.font)
        label.attributedText = getCenteredText(text: "What do the block commands\nyou used mean in Swift?", fontSize: 14)
        label.fontSize = 14
        label.numberOfLines = 3
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: 385)
        addChild(label)
        
        var label2 = SKLabelNode(fontNamed: Game.font)
        label2.attributedText = getCenteredText(text: "- The 1x, 2x, 3x, and 4x blocks were for loops.\n- For loops are a way for you to run the same code multiple times.\n- In your case, you may have wanted to move up 3 times or to the left 2 times.\n\n- The arrow blocks were for functions.\n- A function is a bunch of code that does something.\n- In your case, the arrow blocks were functions that moved your character up, down, left, or right.\n\nBelow is an example of real Swift code!", fontSize: 10)
        label2.fontSize = 10
        label2.numberOfLines = 10
        label2.preferredMaxLayoutWidth = 150
        label2.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label2.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        label2.fontColor = SKColor.black
        label2.position = CGPoint(x: 100, y: 340)
        addChild(label2)
                
        let codeExample = SKSpriteNode(imageNamed: "images/codeexample.png")
        //size and position
        codeExample.position = CGPoint(x: 100, y: 60)
        codeExample.size.width = CGFloat(140)
        codeExample.size.height = CGFloat(75)
        codeExample.zPosition = CGFloat(1)
        
        // Make the sprite appear on the scene
        addChild(codeExample)
        
        var label3 = SKLabelNode(fontNamed: Game.font)
        label3.attributedText = getCenteredText(text: "Click to learn how to stay healthy!", fontSize: 10)
        label3.fontSize = 10
        label3.numberOfLines = 1
        label3.preferredMaxLayoutWidth = 150
        label3.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label3.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        label3.fontColor = SKColor.black
        label3.position = CGPoint(x: 100, y: 15)
        addChild(label3)
        
        let backgroundMusic = SKAudioNode(fileNamed: "audio/playgroundmusic3.wav")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
    }
    
    func getCenteredText(text: String, fontSize: Int) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let range = NSRange(location: 0, length: text.count)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: Game.font, size: CGFloat(fontSize))], range: range)
        return attrString
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            
        let reveal = SKTransition.flipHorizontal(withDuration: 2)
        let scene = CovidScene(size: self.size)
        self.view?.presentScene(scene, transition:reveal)
        self.isUserInteractionEnabled = false
  
      }
    
    // Dummy implementation with a fatalError(_:)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - COVIDScene

class CovidScene: SKScene {
    
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        // Set the background color to white
        backgroundColor = SKColor.init(red: Game.red, green: Game.green, blue: Game.blue, alpha: 1)
        
        // Display a label of text to the screen
        var label = SKLabelNode(fontNamed: Game.font)
        label.attributedText = getCenteredText(text: "How can you stay safe\nduring this pandemic?", fontSize: 14)
        label.fontSize = 14
        label.numberOfLines = 3
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: 385)
        addChild(label)
        
        var label2 = SKLabelNode(fontNamed: Game.font)
        label2.attributedText = getCenteredText(text: "You may be able to stay safe and healthy by:\n\n1. Staying clean and washing your hands\n2. Not touching your face\n3. Wearing a mask when around other people\n4. Staying at home\n5. Letting a trusted adult know if you feel sick", fontSize: 10)
        label2.fontSize = 10
        label2.numberOfLines = 10
        label2.preferredMaxLayoutWidth = 150
        label2.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label2.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        label2.fontColor = SKColor.black
        label2.position = CGPoint(x: 100, y: 340)
        addChild(label2)
                
        let codeExample = SKSpriteNode(imageNamed: "images/stayhealthy.png")
        //size and position
        codeExample.position = CGPoint(x: 100, y: 90)
        codeExample.size.width = CGFloat(140)
        codeExample.size.height = CGFloat(140)
        codeExample.zPosition = CGFloat(1)
        
        // Make the sprite appear on the scene
        addChild(codeExample)

        let backgroundMusic = SKAudioNode(fileNamed: "audio/playgroundmusic3.wav")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)

        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
           
           let touch:UITouch = touches.first! as UITouch
           let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)

           let reveal = SKTransition.flipHorizontal(withDuration: 2)
           let scene = LastScene(size: self.size)
           self.view?.presentScene(scene, transition:reveal)
    }
    
    func getCenteredText(text: String, fontSize: Int) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let range = NSRange(location: 0, length: text.count)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: Game.font, size: CGFloat(fontSize))], range: range)
        return attrString
    }
    
    // Dummy implementation with a fatalError(_:)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - LastScene

class LastScene: SKScene {
    
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        // Set the background color to white
        backgroundColor = SKColor.init(red: Game.red, green: Game.green, blue: Game.blue, alpha: 1)
        

        var label3 = SKLabelNode(fontNamed: Game.font)
        label3.attributedText = getCenteredText(text: "Click me to play again", fontSize: 10)
        label3.fontSize = 10
        label3.numberOfLines = 3
        label3.preferredMaxLayoutWidth = 150
        label3.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label3.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        label3.fontColor = SKColor.black
        label3.position = CGPoint(x: 100, y: 290)
        addChild(label3)
        
        let game = SKSpriteNode(imageNamed: "images/User/user1.png")
        //size and position
        game.position = CGPoint(x: 100, y: 220)
        game.size.width = CGFloat(75)
        game.size.height = CGFloat(75)
        game.zPosition = CGFloat(1)
        game.name = "game"
        
        // Make the sprite appear on the scene
        addChild(game)
        
        var label4 = SKLabelNode(fontNamed: Game.font)
        label4.attributedText = getCenteredText(text: "Click me to go to the start", fontSize: 10)
        label4.fontSize = 10
        label4.numberOfLines = 3
        label4.preferredMaxLayoutWidth = 150
        label4.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label4.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        label4.fontColor = SKColor.black
        label4.position = CGPoint(x: 100, y: 150)
        addChild(label4)
        
        let home = SKSpriteNode(imageNamed: "images/home.png")
        //size and position
        home.position = CGPoint(x: 100, y: 100)
        home.size.width = CGFloat(75)
        home.size.height = CGFloat(75)
        home.zPosition = CGFloat(1)
        home.name = "home"
        
        // Make the sprite appear on the scene
        addChild(home)

        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
           
           let touch:UITouch = touches.first! as UITouch
           let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)

           if let name = touchedNode.name {
            if name == "home" {
                let reveal = SKTransition.flipHorizontal(withDuration: 2)
                let scene = IntroScene(size: self.size)
                self.view?.presentScene(scene, transition:reveal)
            } else if name == "game" {
                // Transition to a new scene in SpriteKit
                let scene = GameScene(size: self.size)
                self.view?.presentScene(scene)
                self.isUserInteractionEnabled = false
            }
        }
    }
    
    func getCenteredText(text: String, fontSize: Int) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let range = NSRange(location: 0, length: text.count)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: Game.font, size: CGFloat(fontSize))], range: range)
        return attrString
    }
    
    // Dummy implementation with a fatalError(_:)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - IntroScene

class IntroScene: SKScene {
    
    
    var loading: SKLabelNode?
        
    override init(size: CGSize) {
        
        super.init(size: size)
        
        // Set the background color to white
        backgroundColor = SKColor.init(red: Game.red, green: Game.green, blue: Game.blue, alpha: 1)
                
        // Display a label of text to the screen

        // Display a label of text to the screen
        var label = SKLabelNode(fontNamed: Game.font)
        label.attributedText = getCenteredText(text: "COVID Maze", fontSize: 25)
        label.fontSize = 20
        label.numberOfLines = 3
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: 300)
        addChild(label)
            
        
        //COVID

                       
        let covid = SKSpriteNode(imageNamed: "images/covidhome.png")
        //size and position
        covid.position = CGPoint(x: 100, y: 200)
        covid.size.width = CGFloat(100)
        covid.size.height = CGFloat(100)
        covid.zPosition = CGFloat(1)

        covid.run(.sequence([
            .wait(forDuration: 0.2),
            .repeatForever(.sequence([
                .scale(to: 1.35, duration: 0.3),
                .scale(to: 1, duration: 0.3),
                .wait(forDuration: 1.25)
            ]))
        ]))
        
               
        // Make the sprite appear on the scene
        addChild(covid)
               
        var label2 = SKLabelNode(fontNamed: Game.font)
        label2.attributedText = getCenteredText(text: "Click to play and learn!", fontSize: 12)
        label2.fontSize = 12
        label2.numberOfLines = 10
        label2.preferredMaxLayoutWidth = 150
        label2.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label2.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        label2.fontColor = SKColor.black
        label2.position = CGPoint(x: 100, y: 100)
        addChild(label2)
                       
        self.loading = SKLabelNode(fontNamed: Game.font)
        self.loading!.attributedText = getCenteredText(text: "turn sound on\nloading may take some time", fontSize: 9)
        self.loading!.fontSize = 12
        self.loading!.numberOfLines = 10
        self.loading!.preferredMaxLayoutWidth = 150
        self.loading!.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        self.loading!.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        self.loading!.fontColor = SKColor.black
        self.loading!.position = CGPoint(x: 100, y: 70)
        addChild(self.loading!)
        
        let backgroundMusic = SKAudioNode(fileNamed: "audio/playgroundmusic2.wav")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)

        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
           
        let reveal = SKTransition.flipHorizontal(withDuration: 2)
        let scene = InstructionScene(size: self.size)
        self.view?.presentScene(scene, transition:reveal)


    }
    
    
    func getCenteredText(text: String, fontSize: Int) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let range = NSRange(location: 0, length: text.count)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: Game.font, size: CGFloat(fontSize))], range: range)
        return attrString
    }
    
    // Dummy implementation with a fatalError(_:)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - InstructionScene

class InstructionScene: SKScene {
    
    
    override init(size: CGSize) {
        
        super.init(size: size)
        // Set the background color to white
        backgroundColor = SKColor.init(red: Game.red, green: Game.green, blue: Game.blue, alpha: 1)
        
        // Display a label of text to the screen
        createText(text: "How to play", fontSize: 14, x: 100, y: 390)
        
        createSprite(filename: "images/User/user1.png", x: 50, y: 340, w: 45, h: 45)
        createText(text: "This is you", fontSize: 8, x: 50, y: 315)

        createSprite(filename: "images/covidhome.png", x: 150, y: 340, w: 45, h: 45)
        createText(text: "You have to reach this", fontSize: 8, x: 150, y: 315)

        createSprite(filename: "images/soap.png", x: 30, y: 270, w: 45, h: 45)
        createSprite(filename: "images/mask.png", x: 70, y: 270, w: 45, h: 45)
        createText(text: "Before that, you must\ncollect soap and a mask", fontSize: 8, x: 50, y: 240)
        
        createSprite(filename: "images/Person/person1.png", x: 150, y: 270, w: 45, h: 45)
        createText(text: "Avoid other people", fontSize: 8, x: 150, y: 240)

        createSprite(filename: "images/up.png", x: 50, y: 190, w: 35, h: 35)
        createText(text: "Click these blocks\nto move", fontSize: 8, x: 50, y: 165)

        createSprite(filename: "images/dropoff.png", x: 150, y: 195, w: 40, h: 55)
        createText(text: "You moves are here", fontSize: 8, x: 150, y: 165)

        createSprite(filename: "images/3time.png", x: 50, y: 120, w: 35, h: 35)
        createText(text: "Click these to move\nmore than once", fontSize: 8, x: 50, y: 100)

        createSprite(filename: "images/start.png", x: 150, y: 120, w: 30, h: 30)
        createText(text: "Click this\nto start moving", fontSize: 8, x: 150, y: 100)

        createSprite(filename: "images/restart.png", x: 50, y: 60, w: 30, h: 30)
        createText(text: "Click this to restart", fontSize: 8, x: 50, y: 40)

        createSprite(filename: "images/delete.png", x: 150, y: 60, w: 30, h: 30)
        createText(text: "Click this to\ndelete a block", fontSize: 8, x: 150, y: 50)

        createText(text: "Click to play the game", fontSize: 10, x: 100, y: 25)
        
        
        let backgroundMusic = SKAudioNode(fileNamed: "audio/playgroundmusic2.wav")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)

    }
    
    func createText(text: String, fontSize: CGFloat, x: Int, y: Int) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Game.font)
        label.attributedText = getCenteredText(text: text, fontSize: Int(fontSize));
        label.fontSize = fontSize
        label.zPosition = 1
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center //center
        label.position = CGPoint(x: x, y: y) //position
        label.fontColor = UIColor.black
        label.numberOfLines = 3
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top //text starts at the top and goes down
        self.addChild(label)
        return label
    }
    
    //creates a spritenode based on the parameters
    func createSprite(filename: String, x: Int, y: Int, w: Int, h: Int) -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: filename)
        //size and position
        sprite.position = CGPoint(x: x, y: y)
        sprite.size.width = CGFloat(w)
        sprite.size.height = CGFloat(h)

        //name
         sprite.name = name
        
        // Make the sprite appear on the scene
        addChild(sprite)
        
        return sprite
    }
    
    func getCenteredText(text: String, fontSize: Int) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let range = NSRange(location: 0, length: text.count)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: Game.font, size: CGFloat(fontSize))], range: range)
        return attrString
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            
        let scene = GameScene(size: self.size)
        self.view?.presentScene(scene)
  
      }
    
    // Dummy implementation with a fatalError(_:)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Game View Controller

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = SKView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
        view = skView
        let scene = IntroScene(size: view.bounds.size)
//        skView.showsFPS = true
//        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

    


// MARK: - Setting Up the Live View

PlaygroundPage.current.liveView = GameViewController()
