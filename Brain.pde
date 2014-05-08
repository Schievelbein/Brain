// sketch:  Brain Test   
//____________________________________________________
//
//This sketch creates an interactive AI Brain to view.
//Base off from RGB_Cube.pde by toni holzer on OpenProcessing.org     
//
//____________________________________________________

import processing.opengl.*;
import peasy.*;
PeasyCam cam;
PGraphicsOpenGL buffer;

//Change these two variables for number of cells and window area
int winSize = 800;  //size of display window in both directions
final static int   cells_per_side = 20;                         // ODD number of cells per side - no greater than 100

// Do NOT change anything below this line.
double currentdistance;
int scrWidth  = displayWidth;
int scrHeight = displayHeight;     

String title = ">>> Michael's Brain simulation <<<";
//String version = "Version 8.0";      //Picking colored balls based * cubed
//String version = "Version 8.1";      //From spheres to cubes and GROUP - Max out at 45/side
String version = "Version 8.2";      //Resize & segregation


color fillColor = color(222);  // light gray -background
color lineColor = color(88);   // dark gray - lines & letters
 
// cube data
float boundries = winSize *.8;                    // overall brain size in comparison to window
float d2 = cells_per_side * 0.5 - 0.5;            //used in creating matrix
float init_rescale = 0.5, rescale=init_rescale;   // 0.1 .. 1.0  percentage cell takes of allocated space
float gridSize = boundries / cells_per_side;
float cellSize = gridSize * init_rescale;
int trans = 88;                                  // transparency setting  solid=255 transparent=88
Pt[] pts;


// flags
boolean showInfo = true;       // true: draw information
boolean freemode = false;      // true: grab the brain
boolean showTrans = true;
boolean clicked = false;

// Set up type of Brain
CubeCelledBrain Brain;
//PolyCelledBrain Brain;

color[] quadBG =             { 0xFFFFFFFF, 0xFFFF0000, 0xFF00FF00, 0xFF0000FF, 0xFFFFFF00, 0xFF00FFFF, 0xFFFF00FF };
color[] quadBGtinted =       { 0xFFFFFFFF, 0x88FF0000, 0x8800FF00, 0x880000FF, 0x88FFFF00, 0x8800FFFF, 0x88FF00FF };
color   getColor(int id)     { return -(id + 2);  }                                // id 0 gives color -2, etc.
int     getId(color pt_color){ return -(pt_color + 2);  }                          // color -2 gives 0, etc.

void setup() {
  int cellnum = 0;
  size(winSize, winSize, OPENGL);
  cam = new PeasyCam(this, winSize*1.5);
  cursor(HAND);
  Brain = new CubeCelledBrain(cells_per_side, cellSize, gridSize);
  buffer = (PGraphicsOpenGL)createGraphics(winSize, winSize, P3D);                // buffer is created using applet dimensions
  
}

//________________________________________________________________________
void draw() {
  if (freemode) cam.rotateY(radians(1));
  if (freemode) cam.rotateX(radians(.5));

  pushMatrix();
  background(222);
  if (showInfo)  showHUDtext();
  Brain.draw(); 
  popMatrix();  
}

//----------------------------------------------------------
void reset()
{
  gridSize = boundries / cells_per_side;
  rescale = init_rescale;
  cellSize = gridSize * rescale;
  cam.reset();
  showInfo = true;
}

//----------------------------------------------------------
void resetnozoom()  { currentdistance = cam.getDistance(); cam.reset(); cam.setDistance(currentdistance);}
void changeTrans () {  showTrans = !showTrans;  if (showTrans) trans=88;  else trans=255; Brain.settrans(trans);  }
void updateCells()  {  }
//----------------------------------------------------------

void keyPressed()
{
  int inputKeyCode = keyCode;
  if      (key == 'i') showInfo = !showInfo;      // keyCode 73
  else if (key == 't') changeTrans();             // keyCode 84
  else if (key == 's') save("Brain.png");         // keyCode 83
  else if (key == 'p') paused=!paused;            // keyCode 80
  else if (key == 'u') updateCells();             // keyCode 85
  else if (key == 'f') freemode = !freemode;      // keyCode 70
  else if (key == '-') Brain.resize(-.01);        // keyCode 109
  else if (key == '+') Brain.resize(+.01);        // keyCode 107
  else if ((keyCode ==  37) |(keyCode ==  226)|(keyCode ==  100))    cam.rotateY(radians(3));   // cursor left - nonum 4 - num4
  else if ((keyCode ==  101)|(keyCode == 65368)|(keyCode == 90))     resetnozoom();               // num 5 - nonum5 - Z
  else if ((keyCode ==  39) |(keyCode ==  227)|(keyCode ==  102))    cam.rotateY(radians(-3));  // cursor right - nonum 6 - num 6
  else if((keyCode ==  38)  |(keyCode == 224) |(keyCode == 104))     cam.rotateX(radians(-3));  // cursor up or num 8
  else if((keyCode ==  40)  |(keyCode == 225) |(keyCode ==  98))     cam.rotateX(radians(3));   // cursor down or num 2
}
//--------------------------------------------------------------

void showHUDtext()
{
  // font & text
  int fontSize = winSize/100;                // current fontsize
  PFont font1 = createFont("Agency FB Bold", fontSize); // current font
  textFont(font1, fontSize);
  
  cam.beginHUD();
  fill(0);
  textAlign(CENTER, TOP);
  text (title,                                   width/2, 0);
  text (version,                                 width/2, fontSize);
  textAlign(LEFT, TOP);
  text ("Arrows & Drag to  Rotate",              10, 0);
  text ("Double-Dlick  to  Reset view",          10, fontSize);
  textAlign(RIGHT, TOP);
  text ("Screen: " + width + "*" + height,        width*.99, 0);
  text ("Distance = "+ Math.round(cam.getDistance()),    width*.99, fontSize);
  text ("(T)ransparency = " + showTrans,          width*.99, 2*fontSize);
  text ("FrameRate = "+round(frameRate) + " fps", width*.99, 3*fontSize);
  textAlign(LEFT, BOTTOM);
  text ("Toggle (I)nfo",    10, height);
  textAlign(CENTER, BOTTOM);
  text ("S to save Brain.png",                     width/2, height);
  textAlign(RIGHT, BOTTOM);
  text ("+/- change cube size",                    width*.99, height);
  cam.endHUD();
}


//_________________________________________________________________
void mouseClicked() {                                                
  // draw the scene in the buffer
  buffer.beginDraw();
  buffer.background(getColor(-1)); // since background is not an object, its id is -1
  buffer.setMatrix(g.getMatrix());
  buffer.noStroke();
  for (int i=0; i<pts.length; i++) {    pts[i].drawBuffer(buffer);  }
  buffer.endDraw();
  
  color pick = buffer.get(mouseX, mouseY);                         // get the pixel color under the mouse
  int id = getId(pick);                                            // get object id
  if (id >= 0) { println("object ID : " + id);}//  pts[id].changeColor(); }                   // if id > 0 (background id = -1)
}

//____________________________________________________//____________________________________________________//____________________________________________________
// Extended PShape
final class MyPShape extends PShape {
  // Fields or attributes of this class:
  final PVector position    = new PVector();
  final PVector location    = new PVector();
  final PVector orientation = new PVector();
 
  // Methods of this class:
  PVector getPostition() {return position;}
  MyPShape setPostition(PVector pos) { position.set(pos); return this;  }
  
  PVector getLocation() {return location;}
  MyPShape setLocation(PVector loc)  { location.set(loc); return this;  }
  
  PVector getOrientation() {return orientation;  }
  MyPShape setOrientation(PVector orient) { orientation.set(orient); return this;  }  
}
//____________________________________________________//____________________________________________________//____________________________________________________
// Custom Cube Celled Brain Class

class CubeCelledBrain {
  
  float cellwidth, cellheight, celldepth, cellsize, cs, gridsize;  // width, height, depth, size of cell
  int cells_per_side, half_cells_per_side;
  int face_number=0, n = 0, count=0, cellnum=0;
  String  name;
  
  // Position & location vectors 
  PVector[] vertices = new PVector[9];
  PVector tempvec, up, down, left, right, backwards;
  
  PShape  brain, bigbrain, cell, tempcell, tempface, pickedcell;
  PShape[] face = new PShape[7];
  
  //*****************************************************************************************************
  CubeCelledBrain(int tempN, float tempS, float tempG) {  // CONSTRUCTOR
    cells_per_side = tempN; 
    cs = tempS;                   
    gridsize = tempG;
    pts = new Pt[cells_per_side * cells_per_side * cells_per_side];    
    
        
    // cube composed of 8 verticies
    vertices[0] = new PVector(0,0,0);
    vertices[1] = new PVector(-cs/2, -cs/2, cs/2);
    vertices[2] = new PVector(cs/2, -cs/2, cs/2);
    vertices[3] = new PVector(cs/2, cs/2, cs/2);
    vertices[4] = new PVector(-cs/2, cs/2, cs/2);
    vertices[5] = new PVector(cs/2, -cs/2, -cs/2); 
    vertices[6] = new PVector(-cs/2, -cs/2, -cs/2);
    vertices[7] = new PVector(-cs/2, cs/2, -cs/2);
    vertices[8] = new PVector(cs/2, cs/2, -cs/2);  
    //up          = new PVector (0, 1, 0);
    
    // fv=faceverticies     mapping of the verticies to faces  
    int[][] fv ={{0,0,0,0},{1,2,3,4},{1,6,7,4},{2,5,8,3},{6,5,8,7},{1,6,5,2},{4,7,8,3}};
    
// Create the shape group
    brain = createShape(GROUP);
    for (int i = 0; i < cells_per_side; i++) {
      for (int j = 0; j < cells_per_side; j++) {
          for (int k = 0; k < cells_per_side; k++) {  
            pts[cellnum] = new Pt(cellnum, i*gridSize, j*gridSize, k*gridSize, cellSize);cellnum++;    // will this work ?       
            cell = createShape(GROUP);
               for (int fn = 0; fn < 7; fn++) {
               face[fn]=createShape();
               face[fn].beginShape();
                  face[fn].fill(quadBG[fn]);
                  face[fn].vertex(vertices[fv[fn][0]].x, vertices[fv[fn][0]].y, vertices[fv[fn][0]].z);
                  face[fn].vertex(vertices[fv[fn][1]].x, vertices[fv[fn][1]].y, vertices[fv[fn][1]].z);
                  face[fn].vertex(vertices[fv[fn][2]].x, vertices[fv[fn][2]].y, vertices[fv[fn][2]].z);
                  face[fn].vertex(vertices[fv[fn][3]].x, vertices[fv[fn][3]].y, vertices[fv[fn][3]].z);
                  face[fn].setName("Cell "+i+" "+j+" "+k+":Face " + fn);
                  face[fn].endShape();
                  cell.addChild(face[fn]);     }
            cell.translate((i-d2)*gridsize, (j-d2)*gridsize, (k-d2)*gridsize);
            name=("Cell "+i+" "+j+" "+k);
            cell.setName(name);
            brain.addChild(cell);
            //println("Creating Cell :"+cellnum + "  "+name);
            }}}
        
        println("******************** Finished Creating small brain **************************");
        bigbrain = createShape(GROUP);
        bigbrain.beginShape();  
           bigbrain.addChild(brain);
           println("CPS = "+cells_per_side+" GridSize = "+gridSize);
           
           //bigbrain.translate(gridSize,0,0); bigbrain.addChild(brain);
           //brain.translate(cells_per_side*gridSize,0,cells_per_side*gridSize); bigbrain.addChild(brain);
           //brain.translate(cells_per_side*gridSize,cells_per_side*gridSize,0); bigbrain.addChild(brain);
           //brain.translate(cells_per_side*gridSize,cells_per_side*gridSize,cells_per_side*gridSize); bigbrain.addChild(brain);
           //brain.translate(cells_per_side*gridSize,0,0); bigbrain.addChild(brain);
           //brain.translate(0,0,cells_per_side*gridSize); bigbrain.addChild(brain);
           //brain.translate(0,cells_per_side*gridSize,0); bigbrain.addChild(brain);
           //brain.translate(0,cells_per_side*gridSize,cells_per_side*gridSize); bigbrain.addChild(brain);
         //bigbrain.endShape();  
    }
 
             
void resize(float delta) {   
  //delta is +1 for increae size or -1 for decrease size 
  int braincells = brain.getChildCount();
  double testlength = brain.getChild(braincells-1).getChild(6).getVertex(0).x;

  println("DELTA = "+delta);
  println("Math.round = "+(abs(Math.round(testlength))));
  
  if ((abs(Math.round(testlength))>4) & ((testlength+(delta*testlength))>(-gridsize/2)) & ((testlength+(delta*testlength))<(gridsize/2))){
      println("BIG ENOUGH");
      
  for (int cellnum = 0; cellnum < braincells; ++cellnum) {
    //pts[cellnum] = Pt(cellnum, i*gridSize, j*gridSize, k*gridSize, cellSize);cellnum++;    // will this work ?
    tempcell= brain.getChild(cellnum);
    for (int j = 0; j<7; j++) {
      tempface=tempcell.getChild(j);
      for (int k=0; k<4; k++) {
      tempvec=tempface.getVertex(k);
      //if ((abs(tempvec.x)>4) & (abs(tempvec.y)>4) & (abs(tempvec.z)>4)){
      tempvec.x = constrain(tempvec.x+(delta*tempvec.x), -gridsize/2, gridsize/2);
      tempvec.y = constrain(tempvec.y+(delta*tempvec.y), -gridsize/2, gridsize/2);
      tempvec.z = constrain(tempvec.z+(delta*tempvec.z), -gridsize/2, gridsize/2);//}
      tempface.setVertex(k,tempvec);
        }  // end k 
      } // end j  
    }  //end cellnum
  }  // endif
  shape(brain);      // Draw the brain
  }  // end resize

void settrans(int trans) { 
  int braincells = brain.getChildCount();
    for (int cellnum = 0; cellnum < braincells; ++cellnum) {
      tempcell= brain.getChild(cellnum);
      for (int j = 0; j<7; j++) {
        tempface=tempcell.getChild(j);
        if (trans==88) { tempface.setFill(quadBGtinted[j]);}
        else { tempface.setFill(quadBG[j]);}}}
   shape(brain);}      // Draw the brain
  

void draw() {  
pushMatrix(); 
//if (freemode) {rotateY(radians(2));}
//println("Drawing Big Brain ");
shape(brain);
popMatrix(); }        // Draw the brain
} 



//____________________________________________________//____________________________________________________//____________________________________________________

class Pt {
  // variables
  int   id;       // id
  float x, y, z;  // position
  float pt_size;  // pt size
 
  public Pt(int id_, float x_, float y_, float z_, float pt_s_)   // constructor
     {this.id = id_;    this.x = x_;    this.y = y_;    this.z = z_;    this.pt_size = pt_s_;}

  private void drawBuffer(PGraphics buffer) 
    {buffer.pushMatrix();buffer.translate(x,y,z);buffer.fill(getColor(id));buffer.box(pt_size);buffer.popMatrix();  } // draw the pt in the buffer______________________________________________
}  // end Pt



