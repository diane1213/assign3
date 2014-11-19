int[][] slot;
boolean[][] flagSlot;// use for flag
int bombCount; // 共有幾顆炸彈
int clickCount; // 共點了幾格
int flagCount; // 共插了幾支旗
int nSlot; // 分割 nSlot*nSlot格
int totalSlots; // 總格數
int countOpenedSlot = 0;
final int SLOT_SIZE = 100; //每格大小

int sideLength; // SLOT_SIZE * nSlot
int ix; // (width - sideLength)/2
int iy; // (height - sideLength)/2

// game state
final int GAME_START = 1;
final int GAME_RUN = 2;
final int GAME_WIN = 3;
final int GAME_LOSE = 4;
int gameState;

// slot state for each slot
final int SLOT_OFF = 0;
final int SLOT_SAFE = 1;
final int SLOT_BOMB = 2;
final int SLOT_FLAG = 3;
final int SLOT_FLAG_BOMB = 4;
final int SLOT_DEAD = 5;
final int SLOT_OPENED = 6;

PImage bomb, flag, cross, bg;

void setup() {
  size (640, 480);
  textFont(createFont("font/Square_One.ttf", 20));
  bomb=loadImage("data/bomb.png");
  flag=loadImage("data/flag.png");
  cross=loadImage("data/cross.png");
  bg=loadImage("data/bg.png");

  nSlot = 4;
  totalSlots = nSlot*nSlot;
  // 初始化二維陣列
  slot = new int[nSlot][nSlot];
  flagSlot = new boolean[nSlot][nSlot];
  sideLength = SLOT_SIZE * nSlot;
  ix = (width - sideLength)/2; // initial x
  iy = (height - sideLength)/2; // initial y

  gameState = GAME_START;
}

void draw() {
  switch (gameState) {
  case GAME_START:
    background(180);
    image(bg, 0, 0, 640, 480);
    textFont(loadFont("font/Square_One.ttf"),16);
    fill(0);
    text("Choose # of bombs to continue:", 10, width/3-24);
    int spacing = width/9;
    for (int i=0; i<9; i++) {
      fill(255);
      rect(i*spacing, width/3, spacing, 50);
      fill(0);
      text(i+1, i*spacing, width/3+24);
    }
    // check mouseClicked() to start the game
    break;
  case GAME_RUN:
    for (int col = 0; col<4; col++) {
      for (int row = 0; row<4; row++) {
        if (slot[col][row] == SLOT_OPENED) {
          countOpenedSlot ++;
        }
      }
    }
    if (countOpenedSlot == 16-bombCount) {
      gameState = GAME_WIN;
    }
    countOpenedSlot = 0;
    break;
  case GAME_WIN:
    textFont(loadFont("font/Square_One.ttf"),18);
    fill(0);
    text("YOU WIN !!", width/3, 30);
    for (int col = 0; col<4; col++) {
      for (int row = 0; row<4; row++) {
        if (flagSlot[col][row] == true && slot[col][row] != SLOT_BOMB) {
          showSlot(col, row, SLOT_FLAG);
        } else {
          if (slot[col][row]==SLOT_BOMB && flagSlot[col][row] == true) {
            slot[col][row] = SLOT_FLAG_BOMB;
          }
          showSlot(col, row, slot[col][row]);
        }
      }
    }

    break;
  case GAME_LOSE:
    textFont(loadFont("font/Square_One.ttf"),18);
    fill(0);
    text("YOU LOSE !!", width/3, 30);
    for (int col = 0; col<4; col++) {
      for (int row = 0; row<4; row++) {
        if (flagSlot[col][row] == true && slot[col][row] != SLOT_BOMB) {
          showSlot(col, row, SLOT_FLAG);
        } else {
          if (slot[col][row]==SLOT_BOMB && flagSlot[col][row] == true) {
            slot[col][row] = SLOT_FLAG_BOMB;
          }
          showSlot(col, row, slot[col][row]);
          showSlot(col, row, slot[col][row]);
        }
      }
    } 
    break;
  }
}

int countNeighborBombs(int col, int row) {
  // -------------- Requirement B ---------
  int count=0;
  int i =col-1;
  if (i<0) {
    i=0;
  }  
  int j =row-1;
  if (j<0) {
    j=0;
  }
  int x = col+1;
  if (x>=3) {
    x=3;
  }
  int y = row+1;
  if (y>=3) {
    y=3;
  }
  int inij = j;
  while (i<=x) {
    while (j<=y) {
      if (slot[i][j] == SLOT_BOMB || slot[i][j] == SLOT_DEAD) {
        count++;
      }
      j++;
    }
    j=inij;
    i++;
  }
  return count;
}

void setBombs() {
  // initial slot
  for (int col=0; col < nSlot; col++) {
    for (int row=0; row < nSlot; row++) {
      slot[col][row] = SLOT_OFF;
      flagSlot[col][row] = false;
    }
  }
  //rondomly set bomb
  for (int i=0; i<bombCount; i++) {
    boolean reapeatedChoice =true;
    while (reapeatedChoice == true) {
      int col = int(random(4));
      int row = int(random(4));
      if (slot[col][row] == SLOT_OFF) {
        slot[col][row]=SLOT_BOMB;
        reapeatedChoice = false;
      }
    }
  }
  for (int col = 0; col<4; col++) {
    for (int row = 0; row<4; row++) {
      if (slot[col][row] == SLOT_OFF) {
        slot[col][row] = SLOT_SAFE;
      }
    }
  }
}

void drawEmptySlots() {
  background(180);
  image(bg, 0, 0, 640, 480);
  for (int col=0; col < nSlot; col++) {
    for (int row=0; row < nSlot; row++) {
      showSlot(col, row, SLOT_OFF);
    }
  }
}

void showSlot(int col, int row, int slotState) {
  int x = ix + col*SLOT_SIZE;
  int y = iy + row*SLOT_SIZE;
  switch (slotState) {
  case SLOT_OFF:
    fill(222, 119, 15);
    stroke(0);
    rect(x, y, SLOT_SIZE, SLOT_SIZE);
    break;
  case SLOT_BOMB:
    fill(255);
    rect(x, y, SLOT_SIZE, SLOT_SIZE);
    image(bomb, x, y, SLOT_SIZE, SLOT_SIZE);
    break;
  case SLOT_SAFE:
    fill(255);
    rect(x, y, SLOT_SIZE, SLOT_SIZE);
    int count = countNeighborBombs(col, row);
    if (count != 0) {
      fill(0);
      textSize(SLOT_SIZE*3/5);
      text( count, x+15, y+15+SLOT_SIZE*3/5);
    }
    slot[col][row]=SLOT_OPENED;
    break;
  case SLOT_FLAG:
    image(flag, x, y, SLOT_SIZE, SLOT_SIZE);
    break;
  case SLOT_FLAG_BOMB:
    image(cross, x, y, SLOT_SIZE, SLOT_SIZE);
    break;
  case SLOT_DEAD:
    fill(255, 255, 0);
    rect(x, y, SLOT_SIZE, SLOT_SIZE);
    image(bomb, x, y, SLOT_SIZE, SLOT_SIZE);
    break;
  }
}

// select num of bombs
void mouseClicked() {
  if ( gameState == GAME_START &&
    mouseY > width/3 && mouseY < width/3+50) {
    // select 1~9
    //int num = int(mouseX / (float)width*9) + 1;
    int num = (int)map(mouseX, 0, width, 0, 9) + 1;
    // println (num);
    bombCount = num;
    // start the game
    clickCount = 0;
    flagCount = num;
    setBombs();
    drawEmptySlots();
    gameState = GAME_RUN;
  }
}

void mousePressed() {
  if ( gameState == GAME_RUN &&
    mouseX >= ix && mouseX <= ix+sideLength && 
    mouseY >= iy && mouseY <= iy+sideLength) {
    if (mouseButton == LEFT) {

      for (int col = 0; col<4; col++) {
        for (int row = 0; row<4; row++) {
          if (mouseX>=ix+col*SLOT_SIZE&&mouseX<=ix+(col+1)*SLOT_SIZE
            &&mouseY>=iy+row*SLOT_SIZE&&mouseY<=iy+(row+1)*SLOT_SIZE && flagSlot[col][row] == false) {
            if (slot[col][row] == SLOT_BOMB) {
              slot[col][row] = SLOT_DEAD;
              showSlot(col, row, SLOT_DEAD);
              gameState = GAME_LOSE;
            } else {
              showSlot(col, row, slot[col][row]);
            }
          }
        }
      }
    } else if (mouseButton == RIGHT) {
      int countFlag = 0;
      for (int col = 0; col<4; col++) {  
        for (int row = 0; row<4; row++) {
          if (flagSlot[col][row] == true) {
            countFlag++;
          }
        }
      }
      for (int col = 0; col<4; col++) {
        for (int row = 0; row<4; row++) {
          if (mouseX>=ix+col*SLOT_SIZE&&mouseX<=ix+(col+1)*SLOT_SIZE
            &&mouseY>=iy+row*SLOT_SIZE&&mouseY<=iy+(row+1)*SLOT_SIZE) {
            if (flagSlot[col][row]==false&&slot[col][row]!=SLOT_OPENED&&countFlag<flagCount) {
              flagSlot[col][row] = true;
              showSlot(col, row, SLOT_FLAG);
            } else if (flagSlot[col][row]==true&&slot[col][row]!=SLOT_OPENED) {
              flagSlot[col][row] = false;
              showSlot(col, row, SLOT_OFF);
            }
          }
        }
      }
    }
  }
}

// press enter to start
void keyPressed() {
  if (key==ENTER && (gameState == GAME_WIN || 
    gameState == GAME_LOSE)) {
    for (int col=0; col<4; col++) {
      for (int row =0; row<4; row++) {
        slot[col][row] = SLOT_OFF;
        flagSlot[col][row] = false;
      }
    }
    gameState = GAME_START;
  }
}
