#define AZstepPin 8
#define FOCUSstepPin 7
#define AZdirPin 10
#define FOCUSdirPin 9
#define ALTstepPin 6
#define ALTdirPin 5
#define I_HANDLE_THE_MOTORS 60 // <
#define ACK 61                 // =

bool enableAZ = false;
bool enableALT = false;
bool enableFOCUS = false;
bool dirAZ = LOW;
bool dirALT = LOW;
bool dirFOCUS = LOW;
int step = 0;

void disable()
{
  digitalWrite(AZstepPin, LOW);
  digitalWrite(AZdirPin, LOW);
  digitalWrite(FOCUSstepPin, LOW);
  digitalWrite(FOCUSdirPin, LOW);
  digitalWrite(ALTstepPin, LOW);
  digitalWrite(ALTdirPin, LOW);
}

void setup()
{
  pinMode(AZstepPin, OUTPUT);
  pinMode(AZdirPin, OUTPUT);
  pinMode(FOCUSstepPin, OUTPUT);
  pinMode(FOCUSdirPin, OUTPUT);
  pinMode(ALTstepPin, OUTPUT);
  pinMode(ALTdirPin, OUTPUT);
  disable();
  Serial.begin(115200);
  while (!Serial.available() || Serial.read() != ACK)
  {
    Serial.write(I_HANDLE_THE_MOTORS);
    Serial.write(13);
    Serial.write(10);
    delay(50);
  }
}

void handleSerialData()
{
  char c = Serial.read();
  if (c == 10 || c == 13)
    return;
  char control = c & 0b00000011;
  if (control != 0)
    return;
  enableAZ = (c & 0b10000000) >> 7;
  enableALT = (c & 0b01000000) >> 6;
  enableFOCUS = (c & 0b00100000) >> 5;
  dirAZ = (c & 0b00010000) >> 4;
  dirALT = (c & 0b00001000) >> 3;
  dirFOCUS = (c & 0b00000100) >> 2;
}

void loop()
{
  if (Serial.available())
  {
    handleSerialData();
  }
  step++;
  if (enableAZ)
  {
    digitalWrite(AZdirPin, dirAZ);
    digitalWrite(AZstepPin, step & 0b00000001);
  }
  if (enableFOCUS)
  {
    digitalWrite(FOCUSdirPin, dirFOCUS);
    digitalWrite(FOCUSstepPin, (step & 0b00000010) >> 1);
  }
  if (enableALT)
  {
    digitalWrite(ALTdirPin, dirALT);
    digitalWrite(ALTstepPin, (step & 0b00000100) >> 2);
  }
  if (step % 8 == 0)
  {
    step = 0;
  }
  delay(2);
}
