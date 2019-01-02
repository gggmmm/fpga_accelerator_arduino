// PINs declarations
unsigned short const F_AF=10, F_FA=11, BTN=12;
unsigned short const BIT_PIN[8] = {2,3,4,5,6,7,8,9}; // pin 2 = LSB, pin 9 MSB

// constants
byte const test_size = 5;
byte const op1[test_size]     = {7,10,8,16,3};
byte const op2[test_size]     = {1,9,5,4,7};
byte const code[test_size]    = {0,1,2,3,0}; // 0 add 1 sub 2 mul 3 div
byte const result[test_size]  = {8,1,40,4,10};

// variables
byte correct = 0;

void sendDelta() {
  digitalWrite(F_AF,LOW);
  delay(1);
  digitalWrite(F_AF,HIGH);
}

void sendCode(byte i) {
  // code is sent using the two LSB
  digitalWrite(bitRead(code[i],0), BIT_PIN[0]);
  digitalWrite(bitRead(code[i],1), BIT_PIN[1]);
  
  sendDelta();
  delay(1);
}

void sendOp(byte opnum, byte i) {
  byte b = 0;
  for(byte j=0; j<8; j++){
    if(opnum==1)
      b = bitRead(op1[i],j);
    else if(opnum==2)
      b = bitRead(op2[i],j);
    else
      Serial.println("ERROR sendOp");
    
    digitalWrite(b, BIT_PIN[j]);
  }
    
  sendDelta();
  delay(1);
}

byte readResult(){
  setBitPinsMode(INPUT); // set as input
  
  byte result = 0;
  for(byte j=0; j<8; j++)
    bitWrite(result, j, digitalRead(BIT_PIN[j]));
    
  setBitPinsMode(OUTPUT); // set back to output which is the most used case

  return result;
}

void waitForPositiveEdge(){
  byte r0=0, r1=0;
  while( not(r0==1 and r1==0) ){
    r1 = r0;
    r0 = digitalRead(F_FA);
  }
}

// v=0 INPUT, v=1 OUTPUT
void setBitPinsMode(byte v) {
  for(int i=0; i<8; i++)
    pinMode(BIT_PIN[i], v);
}

void setup() {
  Serial.begin(9600);
  
  pinMode(F_FA, INPUT);
  pinMode(BTN, INPUT);
  pinMode(F_AF, OUTPUT);
  digitalWrite(F_AF, LOW);

  setBitPinsMode(OUTPUT); // they are most of the time output
  for(int i=0; i<8; i++)
    digitalWrite(BIT_PIN[i], LOW);
}

byte state = 0;
void loop() {
  while(digitalRead(BTN)==LOW){}
  
  for(byte i=0; i<test_size; i++){
    // check if busy
    while(digitalRead(F_FA)==HIGH){}

    // send code
    sendCode(i);
    waitForPositiveEdge();
    sendOp(1,i);
    waitForPositiveEdge();
    sendOp(2,i);
    waitForPositiveEdge();
    byte r = readResult();
    if(r==result[i])
      correct++;
  }
  Serial.println("Result -- Number of correct computations");
  Serial.println(correct);
  while(1){
    Serial.println("END");
    delay(10000);  
  }
}
