// PINs declarations
unsigned short const F_AF=10, F_FA=11, BTN=12;
unsigned short const BIT_PIN[8] = {2,3,4,5,6,7,8,9}; // pin 2 = LSB, pin 9 MSB

// constants
byte const test_size = 6;
byte const op1[test_size]     = {7,10,8,16,3};
byte const op2[test_size]     = {1,9,5,4,7};
byte const code[test_size]    = {0,1,2,3,0}; // 0 add 1 sub 2 mul 3 div
byte const result[test_size]  = {8,1,40,4,10};

// variables
byte correct = 0;

void notify() {
  digitalWrite(F_AF,HIGH);
  while(digitalRead(F_FA)==0){}  
  digitalWrite(F_AF,LOW);
  while(digitalRead(F_FA)==1){}
}

void sendCode(byte i) {
  // code is sent using the two LSB
  digitalWrite(BIT_PIN[0], bitRead(code[i],0));
  digitalWrite(BIT_PIN[1], bitRead(code[i],1));
  
  notify();
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
    
    digitalWrite(BIT_PIN[j], b);
  }
    
  notify();
}

byte readResult(){
  while(digitalRead(F_FA)==0){}
    
  setBitPinsMode(INPUT); // set as input
  
  byte result = 0;
  for(byte j=0; j<8; j++)
    bitWrite(result, j, digitalRead(BIT_PIN[j]));
    
  setBitPinsMode(OUTPUT); // set back to output which is the most used case

  digitalWrite(F_AF, HIGH);
  while(digitalRead(F_FA)==1){}
  digitalWrite(F_AF, LOW);
  
  return result;
}

// v=0 INPUT, v=1 OUTPUT
void setBitPinsMode(byte v) {
  for(int i=0; i<8; i++)
    pinMode(BIT_PIN[i], v);
}

void setup() {
  Serial.begin(9600);
  Serial.println("Setup");
  
  pinMode(F_FA, INPUT);
  pinMode(BTN, INPUT);
  pinMode(F_AF, OUTPUT);
  digitalWrite(F_AF, LOW);

  setBitPinsMode(OUTPUT); // they are most of the time output
  for(int i=0; i<8; i++)
    digitalWrite(BIT_PIN[i], LOW);
}

void loop() {
  while(digitalRead(BTN)==LOW){}
  Serial.println("Loop");
  
  for(byte i=0; i<test_size; i++){
    Serial.print("Test num: ");
    Serial.println(i);
    // check if busy
    while(digitalRead(F_FA)==HIGH){}

    // send code
    // Serial.println(1);
    sendCode(i);

    // send op1
    // Serial.println(2);
    sendOp(1,i);

    // send op2
    // Serial.println(3);
    sendOp(2,i);

    // Serial.println(4);
    
    byte r = 0;
    r = readResult();
    // Serial.print("Result: ");
    // Serial.println(r);
    
    if(r==result[i])
      correct++;
  }
  Serial.print("Correct computations: ");
  Serial.print(correct);
  Serial.print("/");
  Serial.println(test_size);
  
  while(1){
    delay(10000);  
  }
}
