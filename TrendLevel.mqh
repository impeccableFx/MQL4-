//+------------------------------------------------------------------+
//|                                                   TrendLevel.mqh |
//|                                                   Bonga Phuthuzo |
//|                         https://www.instagram.com/phuthuzobonga/ |
//+------------------------------------------------------------------+
#property copyright "Bonga Phuthuzo"
#property link      "https://www.instagram.com/phuthuzobonga/"
#property strict

// class for dedating a trendbreak

enum ENUM_OFX_TREND_BREAK 
  {
   OFX_TREND_BREAK_NONE,
   OFX_TREND_BREAK_ABOVE,
   OFX_TREND_BREAK_BELOW
  };
   
class CTrendLevel 
{
   private:
   
   string  mLevelName;
  
   public:

 CTrendLevel(string levelName)   
 {
 SetLevelName(levelName);
 }
 
  ~CTrendLevel()
  {
  }
  
  void SetLevelName(string levelName)
  {
  mLevelName = levelName;
  }
  
  string GetLevelName()
  {
  return(mLevelName);
  }
  
  ENUM_OFX_TREND_BREAK GetBreak(int index);

};

ENUM_OFX_TREND_BREAK CTrendLevel::GetBreak(int index)
{
  if (ObjectFind(0,mLevelName)<0)
  return(OFX_TREND_BREAK_NONE); // No trendline found
  
  double prevOpen  = iOpen(Symbol(), Period(), index+1);
  double prevClose = iClose(Symbol(), Period(), index+1);
  double close     = iClose(Symbol(), Period(), index);
  
  double prevTime  = iTime(Symbol(), Period(), index+1);
  double time      = iTime(Symbol(), Period(), index);
  
  double prevValue = ObjectGetValueByTime(0, mLevelName, prevTime);
  double value     = ObjectGetValueByTime(0, mLevelName,time);
  
  if (prevValue == 0 || value == 0)
  return (OFX_TREND_BREAK_NONE);
  
  if ((prevOpen < prevValue && prevClose < prevValue)
    && close>value)
    {
    return (OFX_TREND_BREAK_ABOVE);
    }
    
  if ((prevOpen > prevValue && prevClose > prevValue)
    && close<value)
    {
    return (OFX_TREND_BREAK_BELOW);
    }
    
    return(OFX_TREND_BREAK_NONE);
  
}

// -------------
 double GetPipValue()
 {
   if (_Digits >=4)
     {
       return 0.0001;
     }
   else
     {
       return 0.01;
     }
 }


// ------------------
// Risk Management

double OptimalLotSize(double maxRiskPrc, int maxLossInPips)
{

  Alert("");
  Alert("");
 
  double accEquity = AccountEquity();
  Alert("accEquity: " + accEquity);
  
  double lotSize = MarketInfo(NULL,MODE_LOTSIZE);
  Alert("lotSize: " + lotSize);
  
  double tickValue = MarketInfo(NULL,MODE_TICKVALUE);
  
  if(Digits <= 3)
  {
   tickValue = tickValue /100;
  }
  
  Alert("tickValue: " + tickValue);
  
  double maxLossDollar = accEquity * maxRiskPrc;
  Alert("maxLoss" + AccountCurrency() + ": " + maxLossDollar);
  
  double maxLossInQuoteCurr = maxLossDollar / tickValue;
  Alert("maxLossInQuoteCurr: " + maxLossInQuoteCurr);
  
  
  double optimalLotSize = NormalizeDouble(maxLossInQuoteCurr /(maxLossInPips * GetPipValue())/lotSize,2);
//Alert ("optimalLotSize: " + optimalLotSize);
  
  return optimalLotSize;
 
}


double OptimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss)
{
   int maxLossInPips = MathAbs(entryPrice - stopLoss)/GetPipValue();
   return OptimalLotSize(maxRiskPrc,maxLossInPips);
}

// -------------------

  double GetStopLossPrice (bool bIsLongPosition, double entryPrice, int maxLossInPips)
  {
    double stopLossPrice;
    
    if(bIsLongPosition)
    {
     stopLossPrice = entryPrice - maxLossInPips * 0.0001;
    }
    else
    {
     stopLossPrice = entryPrice + maxLossInPips * 0.0001;
    }
   return stopLossPrice;
  }
  
// --------------------------------------------------

// LicenceCheck

 bool LicenceCheck(string licence = ""){
 
   bool valid = false;

#ifdef LIC_TADE_MODES
  valid = false;
  int validModes[] = LIC_TRADE_MODES;
  
   long accountTradeMode = AccountInfoInteger(ACCOUNT_TRADE_MODE);
  
  for (int i = ArraySize (ValidModes)- 1; i >= 0; 1--)
  {
  if (accountTradeMode == validModes[i])
   {
   valid = true;
   break;
   }
  }
  if (!valid)
  {
  Alert("This is a limited trail version, it will not work on this type of account");
  return(false);
  }
#endif 

#ifdef  LIC_EXPIRES_DAYS
 #ifndef LIC_EXPIRES_START
  #define LIC_EXPIRES_START __DATETIME__
 #endif 
 
 datetime expiredDate = LIC_EXPIRES_START + (LIC_EXPIRES_DAYS * 86400);
 Alert ("Time limited copy, licence to use expires at ", TimeToString(expiredDate));
 if (TimeCurrent() > expiredDate) 
 {
 Alert("Licence to use has expired, contact the owner B.P to renew your Licence");
 return(false);
 }
 #endif 


#ifdef LIC_PRIVATE_KEY
  long account = AccountInfoInteger(ACCOUNT_LOGIN);
  string result = KeyGen(IntegerToString(account), LIC_PRIVATE_KEY);

  if (result != licence)
  {
  Alert("Invalid licence code");
 // Alert("Should be " + result);
  return(false);
  }
#endif 
 
 return(true);

 }
 
string KeyGen (string account, string privateKey)
{
  uchar accountChar[];
  StringToCharArray(account, accountChar);
  
  uchar keyChar[];
  StringToCharArray(privateKey, keyChar);
  
  uchar resultChar[];
  CryptEncode(CRYPT_HASH_SHA256, accountChar, keyChar, resultChar);
  CryptEncode(CRYPT_BASE64, resultChar, resultChar, resultChar);
  
  string result = CharArrayToString(resultChar);
  return(result);
}

//----------------------------------

bool CheckIfOpenOrdersByMagicNB(int InpMagicNumber)
{
    int openOrders = OrdersTotal();
  
  for(int i = 0; i < openOrders; i++)
  {
    if(OrderSelect(i,SELECT_BY_POS) == true)
     {
     if (OrderMagicNumber() == InpMagicNumber)
        {
          return true;
        }
     }
  } 
  return false;
}

