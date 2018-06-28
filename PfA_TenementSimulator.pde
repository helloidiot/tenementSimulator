////////////////////////////////////////////////////
//                                               //
//            TENEMENT SIMULATOR                //
//                                             //
//  Press 'B' to move to a new tenement       //
//        'S' to save a screenshot           //
//    and move the mouse for a new day      //
//                                         //
////////////////////////////////////////////

int [][] imgData;
int sz = 540; //150
int counter = 0;

int numOfBuildings;
int distance = 1000;

int windowWidth = 10;
int windowHeight = 10;
int windowDepth = 3;
int windowSpacing = windowWidth;
int numOfWindows = 20;                   //buildingSizes.get(0).x / windowSpacing;

int buildingMin = 200;
int buildingMax = 400;
int dist = 100;
float telegraphRotation;

boolean doDrawBuildings = false;

//declare the data structures
ArrayList<PVector> buildingPositions;
ArrayList<PVector> buildingSizes;
ArrayList<PVector> roofElementSizes;
ArrayList<PVector> roofElementPositions;

PVector camPos;

void setup(){
  size(1080, 1080, P3D);
  noStroke();

  imgData = new int [sz][sz];
  populateImg(0);

  buildingSetup();
}

void draw(){
  background(200);

  //calculate camera position
  ortho();
  float m = 2000;
  float oneOverSqrt = 1 / sqrt(2);
  camPos = new PVector(m * oneOverSqrt, -m * oneOverSqrt, m * oneOverSqrt);
  camera(camPos.x, camPos.y, camPos.z, buildingPositions.get(0).x, 0, buildingPositions.get(0).z, 0, 1, 0);

  //map lighting to mouse poistion to choose time of day
  float lightPosX = map(mouseX, 0, width, -1, 1);
  float lightPosY = map(mouseY, 0, height, 0.2, 1);
  directionalLight(255, 255, 255, lightPosX, lightPosY, -1);

  //translate roughly tp the centre and draw
  push();
  translate(150, 0, 100);
  drawBuildings();
  pop();

  //reset camera to draw a 2D plane of noise
  camera();
  noLights();
  hint(DISABLE_DEPTH_TEST);
  push();
  randomiseImg();
  drawImg();
  pop();
  hint(ENABLE_DEPTH_TEST);
}


void buildingSetup(){

  numOfBuildings = (int)random(1, 10);
  telegraphRotation = random(PI);

  //building data structures
  buildingPositions = new ArrayList<PVector>();
  buildingSizes = new ArrayList<PVector>();

  //roof elements
  roofElementSizes = new ArrayList<PVector>();
  roofElementPositions = new ArrayList<PVector>();

  //Populate Building array
  for (int i = 0; i < numOfBuildings; i++){
    push();

    PVector buildingSz = new PVector((int)floor(random(windowWidth + (windowSpacing * 2), 100) * 2),
                                    (int)floor(random(windowHeight + (windowSpacing * 2), 200) * 2),
                                    (int)floor(random(windowWidth + (windowSpacing * 2), 100) * 2)); //w, h, d

    buildingSizes.add(buildingSz);

    PVector buildingPos = new PVector(random(-100, 100), -buildingSizes.get(i).y / 2, 0);
    buildingPositions.add(buildingPos);

    PVector roofSize = new PVector(random(10, 50), random(10, 50), random(10, 50));
    roofElementSizes.add(roofSize);

    PVector roofPos = new PVector(random(buildingSizes.get(i).x / 4), 0, random(-buildingSizes.get(i).z / 4));
    roofElementPositions.add(roofPos);

    pop();
  }
}

void drawBuildings(){

  // Drawing the main structures
    fill(200);
    for (int i = 0; i < buildingPositions.size(); i++){
      push();
      translate(buildingPositions.get(i).x, buildingPositions.get(i).y, buildingPositions.get(i).z);
      box(buildingSizes.get(i).x, buildingSizes.get(i).y, buildingSizes.get(i).z);
      pop();

      // Draw windows front
      push();
      fill(255, 180);
      translate(-buildingSizes.get(i).x / 2  + buildingPositions.get(i).x, -buildingSizes.get(i).y, buildingSizes.get(i).z / 2  + buildingPositions.get(i).z);
      for (int x = windowSpacing; x < buildingSizes.get(i).x; x+=windowSpacing * 2){
        for (int y = windowSpacing; y < buildingSizes.get(i).y; y+=windowSpacing * 2){
          push();
          translate(x, y, 0);
          box(windowWidth, windowHeight, windowDepth);
          pop();
        }
      }
      pop();

      // Draw windows near
      push();
      fill(255, 180);
      rotateY(PI * 0.5);
      translate(-buildingSizes.get(i).z / 2 + buildingPositions.get(i).z, -buildingSizes.get(i).y, buildingSizes.get(i).x / 2 + buildingPositions.get(i).x);

      for (int x = windowSpacing; x < buildingSizes.get(i).z; x+=windowSpacing * 2){
        for (int y = windowSpacing; y < buildingSizes.get(i).y; y+=windowSpacing * 2){
          push();
          translate(x, y, 0);
          box(windowWidth, windowHeight, windowDepth);
          pop();
        }
      }
      pop();


      //Draw roof elements
      push();
      translate(buildingPositions.get(i).x + roofElementPositions.get(i).x, buildingPositions.get(i).y + buildingPositions.get(i).y, buildingPositions.get(i).z + roofElementPositions.get(i).z);
      box(roofElementSizes.get(i).x, roofElementSizes.get(i).y, roofElementSizes.get(i).z);
      rotateY(PI * 0.5);
      translate(roofElementPositions.get(i).z / 2, -roofElementSizes.get(i).y / 2, roofElementPositions.get(i).x / 2);
      rotateY(telegraphRotation);
      //drawTelegraph();
      pop();
    }
  }

void drawTelegraph(){
  push();
  stroke(0);
  fill(0);
  line(0, 0, 0, 0, -windowHeight * 4, 0);
  line(-13, -windowHeight * 2, 0, 13, -windowHeight * 2, 0);
  line(-14, -windowHeight * 2.5, 0, 14, -windowHeight * 2.5, 0);
  line(-15, -windowHeight * 3, 0, 15, -windowHeight * 3, 0);
  pop();
}


// GRAIN //

void populateImg(int n){

  //populate the grain array
  for (int i = 0; i < sz; i++){
    for (int j = 0; j < sz; j++){
      imgData[i][j] = n;
    }
  }
}

void randomiseImg(){

  //randomise the grain array
  for (int i = 0; i < sz; i++){
    for (int j = 0; j < sz; j++){
      imgData[i][j] = floor(random(100));
    }
  }
}

void drawImg(){

  float rectSize = width / sz;
  noStroke();

  //draw the grain array
  for (int i = 0; i < sz; i++){
    for (int j = 0; j < sz; j++){
      fill(imgData[i][j], 30);
      rect(i * rectSize, j * rectSize, rectSize, rectSize);
    }
  }
}

// KEY INPUTS //

void keyPressed(){

  if (key == 'b'){
    buildingSetup();
    numOfBuildings = (int)random(1, 5);
  }

  if (key == 's'){
    counter++;
    saveFrame("tenement" + counter + ".jpg");
  }
}


// HELPERS //

void push(){
  pushMatrix();
  pushStyle();
}

void pop(){
  popMatrix();
  popStyle();
}
