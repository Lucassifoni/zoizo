#include <Adafruit_GFX.h>
#include <Adafruit_GrayOLED.h>
#include <Adafruit_SPITFT.h>
#include <Adafruit_SPITFT_Macros.h>
#include <gfxfont.h>

#include <Adafruit_ST7735.h>
#include <Adafruit_ST7789.h>
#include <Adafruit_ST77xx.h>

#define TFT_CS 3
#define TFT_RST 2
#define TFT_DC A0
#define HAUT 6    // ok
#define BAS 10    // ok
#define GAUCHE 4  // ok
#define DROITE 5  // ok
#define CAPTURE 8 // ok
#define FOUT 12   // ok
#define AF 9      // ok
#define FIN 7     // ok
#define I_HANDLE_THE_REMOTE 59 // ;
#define ACK 61 // =
Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

uint16_t color565(uint8_t r, uint8_t g, uint8_t b)
{
  return ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3);
}

void setup()
{

  Serial.begin(115200);
  pinMode(HAUT, INPUT_PULLUP);
  pinMode(BAS, INPUT_PULLUP);
  pinMode(GAUCHE, INPUT_PULLUP);
  pinMode(DROITE, INPUT_PULLUP);
  pinMode(CAPTURE, INPUT_PULLUP);
  pinMode(FOUT, INPUT_PULLUP);
  pinMode(AF, INPUT_PULLUP);
  pinMode(FIN, INPUT_PULLUP);
  tft.initR(INITR_144GREENTAB);
  tft.fillScreen(ST7735_BLACK);
  while (!Serial.available() || Serial.read() != ACK) {
    Serial.println(I_HANDLE_THE_REMOTE);
    delay(50);
  }
}

#define PIC_WIDTH 100
#define PIC_HEIGHT 100
#define ERASE '+'
#define START '.'
#define END '-'
#define CR '\r'
#define LF '\n'
#define RX_ACK '<'
#define TX_ACL '>'

int x = 0;
int y = 0;
char buffer[24];

int maybeDraw()
{
      while (Serial.available()) {
          int v = Serial.read();
          if (v == ERASE) {
            tft.fillScreen(ST7735_BLACK);
            x = 0;
            y = 0;
            continue;
          }
          if (v == CR || v == LF) continue;
          char p1 = ((v & 0b11000000) >> 6) * 63;
          char p2 = ((v & 0b00110000) >> 4) * 63;
          char p3 = ((v & 0b00001100) >> 2) * 63;
          char p4 = ((v & 0b00000011)) * 63;
          tft.drawPixel(x + 14, y + 14, color565(p1, p1, p1));
          tft.drawPixel(x + 15, y + 14, color565(p2, p2, p2));
          tft.drawPixel(x + 16, y + 14, color565(p3, p3, p3));
          tft.drawPixel(x + 17, y + 14, color565(p4, p4, p4));
          x += 4;
          if (x >= PIC_WIDTH)
          {
            x = 0;
            y += 1;
          }
        
    }
  
}

void loop()
{
  int mask = digitalRead(HAUT) * 1 +
             digitalRead(BAS) * 2 +
             digitalRead(GAUCHE) * 4 +
             digitalRead(DROITE) * 8 +
             digitalRead(CAPTURE) * 16 +
             digitalRead(FOUT) * 32 +
             digitalRead(AF) * 64 +
             digitalRead(FIN) * 128;
  Serial.print('.');
  Serial.println(mask);
  delay(10);
  maybeDraw();
}