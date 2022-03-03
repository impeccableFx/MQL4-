//+------------------------------------------------------------------+
//|                                           BeginnerStrategyEA.mq4 |
//|                                                   Bonga Phuthuzo |
//|                         https://www.instagram.com/phuthuzobonga/ |
//+------------------------------------------------------------------+
#property copyright "Bonga Phuthuzo"
#property link      "https://www.instagram.com/phuthuzobonga/"
#property version   "1.00"
#property strict

#define LIC_TRADE_MODES { ACCOUNT_TRADE_MODE_CONTEST, ACCOUNT_TRADE_MODE_DEMO, ACCOUNT_TRADE_MODE_REAL}
//#define  LIC_EXPIRES_DAYS 30
//#define  LIC_EXPIRES_START D'2022.03.01'
#define  LIC_PRIVATE_KEY "it's impeccable"
  
  
   string InpLicence [2] ={"AB7mbRlHbEjHRWpIUldwSVVsZHdTVlZzWkhkVFZsWnpX", "AFlCQzUuVXUvWFV2V0ZWMlYwWldNbFl3V2xkTmJGbDNW", "AM4SUwrpcnCTbkNUYmtOVVltdE9WVmx0ZEU5V1ZteDBa"}; // Mine

#include <TrendLevel.mqh>

input string InpTrendLevelName = "P";   //Name of trendline
input int maxLossInPips        = 25;
input int takeProfitPips       = 80;
input int maxRiskPrc           = 2;
input int InpMagicNumber       = 369; //Magic number


input string InpTradeComment   = __FILE__; //Trade Comment


 int      TimeOfDayStartHour    =  1;
 int      TimeOfDayEndHour      =  9;
 int      DaysToDraw            = 14;

int ticket;

//  double bbLower1 = iBands(NULL,0,20,1,0,PRICE_CLOSE,MODE_LOWER,0);
//  double bbUper1  = iBands(NULL,0,20,1,0,PRICE_CLOSE,MODE_UPPER,0);
//  double bbMid    = iBands(NULL,0,20,1,0,PRICE_CLOSE,MODE_CLOSE,0);
  
//  double bbLower2 = iBands(NULL,0,20,4,0,PRICE_CLOSE,MODE_LOWER,0);
//  double bbUpper2 = iBands(NULL,0,20,4,0,PRICE_CLOSE,MODE_UPPER,0);

 
    double SL = Ask - maxLossInPips * GetPipValue();
    double TP = Ask + takeProfitPips * GetPipValue();
    
    double SL1 = Bid + maxLossInPips * GetPipValue();
    double TP1 = Bid - takeProfitPips * GetPipValue();
  
  CTrendLevel * TrendLevel;
  
  double stopLossPrice = NormalizeDouble(SL,Digits);
  double takeProfitPrice = NormalizeDouble(TP,Digits);
  
  double stopLossPrice1 = NormalizeDouble(SL1,Digits);
  double takeProfitPrice1 = NormalizeDouble(TP1,Digits);
  
  double lotSize = OptimalLotSize(maxRiskPrc * 0.01,Ask,stopLossPrice);
  double lotSize1 = OptimalLotSize(maxRiskPrc * 0.01,Bid,stopLossPrice);



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(!LicenceCheck(InpLicence[2])) return(INIT_FAILED);
  
   
   TrendLevel = new CTrendLevel(InpTrendLevelName);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   delete TrendLevel;
   
  
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      string      vsGlobalDebug         = "";
    datetime    vdCurrentDayStart       = iTime(Symbol(), PERIOD_D1, 0);    //Get Broker Today DateTime as of Midnight
 
   
    //---------------------------------------------------------------
    //Process [viDaysToDraw] number of days (**Sat/Sun is included)
    //---------------------------------------------------------------
    for(int viDay=0; viDay<DaysToDraw; viDay++) {
        datetime vdDateOfSection        = vdCurrentDayStart-(viDay*PERIOD_D1*60);                     //Get Section Midnight DateTime
        datetime    vdSectionStart      = vdDateOfSection + (TimeOfDayStartHour*PERIOD_H1*60);        //Add Hours to Mark start of section
        datetime    vdSectionEnd        = vdDateOfSection + (TimeOfDayEndHour  *PERIOD_H1*60);        //Add Hours to mark End of section
        
        
    string  vsObjName   = "HLDay" + IntegerToString(viDay);
         ObjectDelete(vsObjName);

        //----------------------------------------------------------------------
        //Calculate the number of bars between (inclusive) Start and End time
        //----------------------------------------------------------------------
        int     viSectionEndBarIndex         = iBarShift(Symbol(), PERIOD_M15, vdSectionEnd,false);
        int     viSectionStartBarIndex       = iBarShift(Symbol(), PERIOD_M15, vdSectionStart,false);
        int     viBarCountBtwStartAndEndHour = viSectionStartBarIndex-viSectionEndBarIndex+1;
        //-----------------------------------------------------------------

        //-----------------------------------------------------------------
        //Find the Highest/Lowest Bar index within the Day Section
        //-----------------------------------------------------------------
        int     viSectionHighestBar     = iHighest(Symbol(), PERIOD_M15, MODE_HIGH, viBarCountBtwStartAndEndHour, viSectionEndBarIndex);
        int     viSectionLowestBar      = iLowest(Symbol(), PERIOD_M15, MODE_LOW, viBarCountBtwStartAndEndHour, viSectionEndBarIndex);
        //-----------------------------------------------------------------

        //-----------------------------------------------------------------
        //Find the Highest/Lowest Price within the Day Section
        //-----------------------------------------------------------------
        double  viSectionHighestPrice   = iHigh(Symbol(), PERIOD_M15, viSectionHighestBar);
        double  viSectionLowestPrice    = iLow( Symbol(), PERIOD_M15, viSectionLowestBar);
        //-----------------------------------------------------------------

        //-----------------------------------------------------------------
        //Add Verbose/Debug Info for display
        //-----------------------------------------------------------------
        StringAdd(
            vsGlobalDebug, "\n[Day" + IntegerToString(viDay) + "]: "
                + "Start: "     + TimeToString(vdSectionStart)
                + ", Lowest: "  + DoubleToString(viSectionLowestPrice,Digits)
                + ", End: "     + TimeToString(vdSectionEnd)
                + ", Highest: " + DoubleToString(viSectionHighestPrice,Digits));
        //-----------------------------------------------------------------

        //-----------------------------------------------------------------
        //Crete Rectangle Object for the Day section
        //-----------------------------------------------------------------
     //   string  vsObjName   = "HLDay" + IntegerToString(viDay);
        ObjectCreate(0, vsObjName, OBJ_RECTANGLE, 0, vdSectionStart, viSectionLowestPrice, vdSectionEnd, viSectionHighestPrice);
        ObjectSetInteger(0, vsObjName, OBJPROP_COLOR, clrGold);
        ObjectSetInteger(0, vsObjName, OBJPROP_WIDTH, 0);
        ObjectSetInteger(0, vsObjName, OBJPROP_BACK, true);
        ObjectSetInteger(0, vsObjName, OBJPROP_SELECTABLE, false);
        
          
        //-----------------------------------------------------------------
    }
    ChartRedraw();
     
 
 
    //-----------------------------------------------------------------
    // Show Debug/Verbose Info
    //-----------------------------------------------------------------
    Print("\n" + vsGlobalDebug );


  Comment ("Let's be pips magnets");
   double price  = 0.0;
   int    ticket = 0;
   

   if (IsNewBar())
   {
   ENUM_OFX_TREND_BREAK brk = TrendLevel.GetBreak(1); //Did the closed bar break
   switch(brk)
     {
     case OFX_TREND_BREAK_NONE:
       break;
       
     case OFX_TREND_BREAK_ABOVE:
     price  = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
     ticket = OrderSend(NULL, ORDER_TYPE_BUY, lotSize, Ask, 10, stopLossPrice, takeProfitPrice,
               InpTradeComment, InpMagicNumber);
               if (ticket < 0)
               {
                Alert("Order rejected error is: " + GetLastError());
               }
      ExpertRemove();
      break;
     
      case OFX_TREND_BREAK_BELOW:
      price  = SymbolInfoDouble(Symbol(),SYMBOL_BID);
      ticket = OrderSend(NULL, ORDER_TYPE_SELL, lotSize1, Bid, 10, stopLossPrice1, takeProfitPrice1,
               InpTradeComment, InpMagicNumber);
               if (ticket < 0)
               {
                Alert("Order rejected error is: " + GetLastError());
               }
      ExpertRemove();
      break;
      }
     
   }
   return;
  }
 
  bool IsNewBar()
  {
  datetime  currentTime      = iTime(Symbol(),Period(), 0);
  static datetime prevTime   = currentTime;
  if (currentTime > prevTime)
     {
      prevTime = currentTime;
      return(true);
     }
   return(false);
   }
 

//+------------------------------------------------------------------+

