//+------------------------------------------------------------------+
//|                                              EasyMQL Helpers     |
//|                                    Copyright 2026, EasyMQL Team  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, EasyMQL Team"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <EasyCore.mqh>

// Forward declarations
class EasyHelpers;

//+------------------------------------------------------------------+
//| Easy Helpers Static Class                                        |
//+------------------------------------------------------------------+
class EasyHelpers
{
public:
   // Price access helpers
   static double      price(PriceType type, int shift = 0);
   static double      open(int shift = 0);
   static double      high(int shift = 0);
   static double      low(int shift = 0);
   static double      close(int shift = 0);
   static double      median(int shift = 0);
   static double      typical(int shift = 0);
   static double      weighted(int shift = 0);
   
   // Common indicators
   static bool        simpleMA(double &source[], int period, double &result[]);
   static bool        ema(double &source[], int period, double &result[]);
   static bool        sma(double &source[], int period, double &result[]);
   static bool        wma(double &source[], int period, double &result[]);
   static bool        rsi(double &source[], int period, double &result[]);
   static bool        macd(double &source[], int fast, int slow, int signal, 
                           double &macd_line[], double &signal_line[], double &histogram[]);
   static bool        bollinger(double &source[], int period, double deviation, 
                                double &upper[], double &middle[], double &lower[]);
   
   // Array helpers
   static bool        copyArray(double &source[], double &dest[], int start = 0, int count = -1);
   static double      arrayMax(double &array[], int start = 0, int count = -1);
   static double      arrayMin(double &array[], int start = 0, int count = -1);
   static double      arrayAvg(double &array[], int start = 0, int count = -1);
   static int         arraySize(const double &array[]);
   
   // Time and date helpers
   static string      timestamp(void);
   static datetime    currentTime(void);
   static int         currentBar(void);
   
   // Drawing helpers
   static bool        drawArrowUp(double price, Color color = Green, string name = "");
   static bool        drawArrowDown(double price, Color color = Red, string name = "");
   static bool        drawHorizontalLine(double price, Color color = Blue, string name = "");
   static bool        drawVerticalLine(int bar, Color color = Gray, string name = "");
   static bool        drawText(double price, string text, Color color = White, string name = "");
   
   // Logging helpers
   static void        log(string message);
   static void        logInfo(string message);
   static void        logWarning(string message);
   static void        logError(string message);
   
   // Math helpers
   static double      normalize(double value, double min_val, double max_val, 
                                double new_min = 0.0, double new_max = 1.0);
   static bool        isTrendingUp(double &data[], int period = 5);
   static bool        isTrendingDown(double &data[], int period = 5);
   static double      percentChange(double old_val, double new_val);
   
   // Order helpers
   static double      calculateLotSize(double risk_percent, double stop_distance);
   static double      getPointValue(void);
   static double      getMinimumLot(void);
   static double      getMaximumLot(void);
   static double      getLotStep(void);
   
private:
   static double      emaMultiplier(int period);
};

//+------------------------------------------------------------------+
//| Get price by type and shift                                      |
//+------------------------------------------------------------------+
double EasyHelpers::price(PriceType type, int shift)
{
   switch(type)
   {
      case Open:
         return iOpen(Symbol(), PERIOD_CURRENT, shift);
      case High:
         return iHigh(Symbol(), PERIOD_CURRENT, shift);
      case Low:
         return iLow(Symbol(), PERIOD_CURRENT, shift);
      case Close:
         return iClose(Symbol(), PERIOD_CURRENT, shift);
      case Median:
         return (iHigh(Symbol(), PERIOD_CURRENT, shift) + iLow(Symbol(), PERIOD_CURRENT, shift)) / 2.0;
      case Typical:
         return (iHigh(Symbol(), PERIOD_CURRENT, shift) + iLow(Symbol(), PERIOD_CURRENT, shift) + 
                 iClose(Symbol(), PERIOD_CURRENT, shift)) / 3.0;
      case Weighted:
         return (iHigh(Symbol(), PERIOD_CURRENT, shift) + iLow(Symbol(), PERIOD_CURRENT, shift) + 
                 2 * iClose(Symbol(), PERIOD_CURRENT, shift)) / 4.0;
      default:
         return iClose(Symbol(), PERIOD_CURRENT, shift);
   }
}

//+------------------------------------------------------------------+
//| Get open price helper                                            |
//+------------------------------------------------------------------+
double EasyHelpers::open(int shift)
{
   return iOpen(Symbol(), PERIOD_CURRENT, shift);
}

//+------------------------------------------------------------------+
//| Get high price helper                                            |
//+------------------------------------------------------------------+
double EasyHelpers::high(int shift)
{
   return iHigh(Symbol(), PERIOD_CURRENT, shift);
}

//+------------------------------------------------------------------+
//| Get low price helper                                             |
//+------------------------------------------------------------------+
double EasyHelpers::low(int shift)
{
   return iLow(Symbol(), PERIOD_CURRENT, shift);
}

//+------------------------------------------------------------------+
//| Get close price helper                                           |
//+------------------------------------------------------------------+
double EasyHelpers::close(int shift)
{
   return iClose(Symbol(), PERIOD_CURRENT, shift);
}

//+------------------------------------------------------------------+
//| Get median price helper                                          |
//+------------------------------------------------------------------+
double EasyHelpers::median(int shift)
{
   return (iHigh(Symbol(), PERIOD_CURRENT, shift) + iLow(Symbol(), PERIOD_CURRENT, shift)) / 2.0;
}

//+------------------------------------------------------------------+
//| Get typical price helper                                         |
//+------------------------------------------------------------------+
double EasyHelpers::typical(int shift)
{
   return (iHigh(Symbol(), PERIOD_CURRENT, shift) + iLow(Symbol(), PERIOD_CURRENT, shift) + 
           iClose(Symbol(), PERIOD_CURRENT, shift)) / 3.0;
}

//+------------------------------------------------------------------+
//| Get weighted price helper                                        |
//+------------------------------------------------------------------+
double EasyHelpers::weighted(int shift)
{
   return (iHigh(Symbol(), PERIOD_CURRENT, shift) + iLow(Symbol(), PERIOD_CURRENT, shift) + 
           2 * iClose(Symbol(), PERIOD_CURRENT, shift)) / 4.0;
}

//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
bool EasyHelpers::simpleMA(double &source[], int period, double &result[])
{
   int size = ArraySize(source);
   if(period <= 0 || size < period)
      return false;
      
   ArrayResize(result, size);
   ArrayInitialize(result, 0.0);
   
   for(int i = period - 1; i < size; i++)
   {
      double sum = 0.0;
      for(int j = 0; j < period; j++)
      {
         sum += source[i - j];
      }
      result[i] = sum / period;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
bool EasyHelpers::ema(double &source[], int period, double &result[])
{
   int size = ArraySize(source);
   if(period <= 0 || size < period)
      return false;
      
   ArrayResize(result, size);
   ArrayInitialize(result, 0.0);
   
   // Calculate multiplier
   double multiplier = emaMultiplier(period);
   
   // First EMA value is the SMA of the first period
   double sum = 0.0;
   for(int i = 0; i < period; i++)
   {
      sum += source[i];
   }
   result[period - 1] = sum / period;
   
   // Calculate subsequent EMA values
   for(int i = period; i < size; i++)
   {
      result[i] = (source[i] * multiplier) + (result[i - 1] * (1.0 - multiplier));
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Simple Moving Average (alias for simpleMA)                       |
//+------------------------------------------------------------------+
bool EasyHelpers::sma(double &source[], int period, double &result[])
{
   return simpleMA(source, period, result);
}

//+------------------------------------------------------------------+
//| Weighted Moving Average                                          |
//+------------------------------------------------------------------+
bool EasyHelpers::wma(double &source[], int period, double &result[])
{
   int size = ArraySize(source);
   if(period <= 0 || size < period)
      return false;
      
   ArrayResize(result, size);
   ArrayInitialize(result, 0.0);
   
   for(int i = period - 1; i < size; i++)
   {
      double sum = 0.0;
      double weight_sum = 0.0;
      
      for(int j = 0; j < period; j++)
      {
         double weight = period - j; // Weight decreases with older values
         sum += source[i - j] * weight;
         weight_sum += weight;
      }
      
      result[i] = sum / weight_sum;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
bool EasyHelpers::rsi(double &source[], int period, double &result[])
{
   int size = ArraySize(source);
   if(period <= 0 || size < period + 1)
      return false;
      
   ArrayResize(result, size);
   ArrayInitialize(result, 0.0);
   
   // Calculate gains and losses
   double gains[size];
   double losses[size];
   ArrayInitialize(gains, 0.0);
   ArrayInitialize(losses, 0.0);
   
   for(int i = 1; i < size; i++)
   {
      double change = source[i] - source[i - 1];
      if(change > 0)
         gains[i] = change;
      else
         losses[i] = MathAbs(change);
   }
   
   // Calculate initial average gain and loss
   double avg_gain = 0.0;
   double avg_loss = 0.0;
   
   for(int i = 1; i <= period; i++)
   {
      avg_gain += gains[i];
      avg_loss += losses[i];
   }
   
   avg_gain /= period;
   avg_loss /= period;
   
   // Calculate RSI values
   for(int i = period; i < size; i++)
   {
      if(avg_loss == 0.0)
      {
         result[i] = 100.0;
      }
      else
      {
         double rs = avg_gain / avg_loss;
         result[i] = 100.0 - (100.0 / (1.0 + rs));
      }
      
      // Update averages for next iteration
      avg_gain = ((avg_gain * (period - 1)) + gains[i]) / period;
      avg_loss = ((avg_loss * (period - 1)) + losses[i]) / period;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| MACD Indicator                                                   |
//+------------------------------------------------------------------+
bool EasyHelpers::macd(double &source[], int fast, int slow, int signal, 
                      double &macd_line[], double &signal_line[], double &histogram[])
{
   int size = ArraySize(source);
   if(fast <= 0 || slow <= 0 || signal <= 0 || size < MathMax(fast, MathMax(slow, signal)))
      return false;
      
   // Create temporary arrays for calculations
   double fast_ema[];
   double slow_ema[];
   ArrayResize(fast_ema, size);
   ArrayResize(slow_ema, size);
   
   // Calculate EMAs
   ema(source, fast, fast_ema);
   ema(source, slow, slow_ema);
   
   // Calculate MACD line
   ArrayResize(macd_line, size);
   for(int i = 0; i < size; i++)
   {
      macd_line[i] = fast_ema[i] - slow_ema[i];
   }
   
   // Calculate signal line
   ema(macd_line, signal, signal_line);
   
   // Calculate histogram
   ArrayResize(histogram, size);
   for(int i = 0; i < size; i++)
   {
      histogram[i] = macd_line[i] - signal_line[i];
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Bollinger Bands                                                  |
//+------------------------------------------------------------------+
bool EasyHelpers::bollinger(double &source[], int period, double deviation, 
                           double &upper[], double &middle[], double &lower[])
{
   int size = ArraySize(source);
   if(period <= 0 || size < period)
      return false;
      
   ArrayResize(upper, size);
   ArrayResize(middle, size);
   ArrayResize(lower, size);
   
   // Calculate middle band (SMA)
   sma(source, period, middle);
   
   // Calculate standard deviation and bands
   for(int i = period - 1; i < size; i++)
   {
      // Calculate variance
      double sum = 0.0;
      for(int j = 0; j < period; j++)
      {
         double diff = source[i - j] - middle[i];
         sum += diff * diff;
      }
      double variance = sum / period;
      double std_dev = MathSqrt(variance);
      
      // Calculate upper and lower bands
      upper[i] = middle[i] + (deviation * std_dev);
      lower[i] = middle[i] - (deviation * std_dev);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Copy array helper                                                |
//+------------------------------------------------------------------+
bool EasyHelpers::copyArray(double &source[], double &dest[], int start, int count)
{
   int src_size = ArraySize(source);
   if(start < 0 || start >= src_size)
      return false;
   
   int copy_count = (count < 0) ? (src_size - start) : count;
   if(copy_count <= 0)
      return false;
   
   ArrayResize(dest, copy_count);
   for(int i = 0; i < copy_count; i++)
   {
      dest[i] = source[start + i];
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Find array maximum                                               |
//+------------------------------------------------------------------+
double EasyHelpers::arrayMax(double &array[], int start, int count)
{
   int size = ArraySize(array);
   if(start < 0 || start >= size)
      return 0.0;
   
   int end = (count < 0) ? size : MathMin(start + count, size);
   if(start >= end)
      return 0.0;
   
   double max_val = array[start];
   for(int i = start + 1; i < end; i++)
   {
      if(array[i] > max_val)
         max_val = array[i];
   }
   
   return max_val;
}

//+------------------------------------------------------------------+
//| Find array minimum                                               |
//+------------------------------------------------------------------+
double EasyHelpers::arrayMin(double &array[], int start, int count)
{
   int size = ArraySize(array);
   if(start < 0 || start >= size)
      return 0.0;
   
   int end = (count < 0) ? size : MathMin(start + count, size);
   if(start >= end)
      return 0.0;
   
   double min_val = array[start];
   for(int i = start + 1; i < end; i++)
   {
      if(array[i] < min_val)
         min_val = array[i];
   }
   
   return min_val;
}

//+------------------------------------------------------------------+
//| Calculate array average                                          |
//+------------------------------------------------------------------+
double EasyHelpers::arrayAvg(double &array[], int start, int count)
{
   int size = ArraySize(array);
   if(start < 0 || start >= size)
      return 0.0;
   
   int end = (count < 0) ? size : MathMin(start + count, size);
   if(start >= end)
      return 0.0;
   
   double sum = 0.0;
   for(int i = start; i < end; i++)
   {
      sum += array[i];
   }
   
   return sum / (end - start);
}

//+------------------------------------------------------------------+
//| Get array size                                                   |
//+------------------------------------------------------------------+
int EasyHelpers::arraySize(const double &array[])
{
   return ArraySize(array);
}

//+------------------------------------------------------------------+
//| Get current timestamp                                            |
//+------------------------------------------------------------------+
string EasyHelpers::timestamp(void)
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   string result = StringFormat("%04d.%02d.%02d %02d:%02d:%02d", 
                                dt.year, dt.mon, dt.day, dt.hour, dt.min, dt.sec);
   return result;
}

//+------------------------------------------------------------------+
//| Get current time                                                 |
//+------------------------------------------------------------------+
datetime EasyHelpers::currentTime(void)
{
   return TimeCurrent();
}

//+------------------------------------------------------------------+
//| Get current bar index                                            |
//+------------------------------------------------------------------+
int EasyHelpers::currentBar(void)
{
   return Bars(Symbol(), PERIOD_CURRENT) - 1;
}

//+------------------------------------------------------------------+
//| Draw arrow up                                                    |
//+------------------------------------------------------------------+
bool EasyHelpers::drawArrowUp(double price, Color color, string name)
{
   if(name == "")
      name = "ArrowUp_" + IntegerToString(TimeCurrent());
      
   return ObjectCreate(0, name, OBJ_ARROW_UP, 0, TimeCurrent(), price);
}

//+------------------------------------------------------------------+
//| Draw arrow down                                                  |
//+------------------------------------------------------------------+
bool EasyHelpers::drawArrowDown(double price, Color color, string name)
{
   if(name == "")
      name = "ArrowDown_" + IntegerToString(TimeCurrent());
      
   return ObjectCreate(0, name, OBJ_ARROW_DOWN, 0, TimeCurrent(), price);
}

//+------------------------------------------------------------------+
//| Draw horizontal line                                             |
//+------------------------------------------------------------------+
bool EasyHelpers::drawHorizontalLine(double price, Color color, string name)
{
   if(name == "")
      name = "HLine_" + IntegerToString(TimeCurrent());
      
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, color);
   return true;
}

//+------------------------------------------------------------------+
//| Draw vertical line                                               |
//+------------------------------------------------------------------+
bool EasyHelpers::drawVerticalLine(int bar, Color color, string name)
{
   if(name == "")
      name = "VLine_" + IntegerToString(TimeCurrent());
      
   datetime time = iTime(Symbol(), PERIOD_CURRENT, bar);
   ObjectCreate(0, name, OBJ_VLINE, 0, time, 0);
   ObjectSetInteger(0, name, OBJPROP_COLOR, color);
   return true;
}

//+------------------------------------------------------------------+
//| Draw text on chart                                               |
//+------------------------------------------------------------------+
bool EasyHelpers::drawText(double price, string text, Color color, string name)
{
   if(name == "")
      name = "Text_" + IntegerToString(TimeCurrent());
      
   datetime time = TimeCurrent();
   ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, color);
   return true;
}

//+------------------------------------------------------------------+
//| Log message                                                      |
//+------------------------------------------------------------------+
void EasyHelpers::log(string message)
{
   Print("[" + timestamp() + "] " + message);
}

//+------------------------------------------------------------------+
//| Log info message                                                 |
//+------------------------------------------------------------------+
void EasyHelpers::logInfo(string message)
{
   Print("[" + timestamp() + "] [INFO] " + message);
}

//+------------------------------------------------------------------+
//| Log warning message                                              |
//+------------------------------------------------------------------+
void EasyHelpers::logWarning(string message)
{
   Print("[" + timestamp() + "] [WARNING] " + message);
}

//+------------------------------------------------------------------+
//| Log error message                                                |
//+------------------------------------------------------------------+
void EasyHelpers::logError(string message)
{
   Print("[" + timestamp() + "] [ERROR] " + message);
}

//+------------------------------------------------------------------+
//| Normalize value to range                                         |
//+------------------------------------------------------------------+
double EasyHelpers::normalize(double value, double min_val, double max_val, 
                             double new_min, double new_max)
{
   if(max_val == min_val)
      return new_min;
      
   double ratio = (value - min_val) / (max_val - min_val);
   return new_min + ratio * (new_max - new_min);
}

//+------------------------------------------------------------------+
//| Check if data is trending up                                     |
//+------------------------------------------------------------------+
bool EasyHelpers::isTrendingUp(double &data[], int period)
{
   int size = ArraySize(data);
   if(size < period + 1)
      return false;
      
   for(int i = 0; i < period; i++)
   {
      int idx1 = size - 1 - i;
      int idx2 = size - 2 - i;
      
      if(idx1 < 0 || idx2 < 0)
         break;
         
      if(data[idx2] > data[idx1]) // Previous value higher than current
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if data is trending down                                   |
//+------------------------------------------------------------------+
bool EasyHelpers::isTrendingDown(double &data[], int period)
{
   int size = ArraySize(data);
   if(size < period + 1)
      return false;
      
   for(int i = 0; i < period; i++)
   {
      int idx1 = size - 1 - i;
      int idx2 = size - 2 - i;
      
      if(idx1 < 0 || idx2 < 0)
         break;
         
      if(data[idx2] < data[idx1]) // Previous value lower than current
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculate percent change                                         |
//+------------------------------------------------------------------+
double EasyHelpers::percentChange(double old_val, double new_val)
{
   if(old_val == 0.0)
      return 0.0;
   return ((new_val - old_val) / old_val) * 100.0;
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk                                |
//+------------------------------------------------------------------+
double EasyHelpers::calculateLotSize(double risk_percent, double stop_distance)
{
   double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double risk_amount = account_balance * (risk_percent / 100.0);
   
   double point_value = getPointValue();
   double lot_size = risk_amount / (stop_distance * point_value);
   
   // Ensure lot size is within broker limits
   double min_lot = getMinimumLot();
   double max_lot = getMaximumLot();
   double lot_step = getLotStep();
   
   lot_size = MathMax(min_lot, MathMin(max_lot, lot_size));
   
   // Round to lot step
   lot_size = MathRound(lot_size / lot_step) * lot_step;
   
   return lot_size;
}

//+------------------------------------------------------------------+
//| Get point value for current symbol                              |
//+------------------------------------------------------------------+
double EasyHelpers::getPointValue(void)
{
   double point_size = SymbolInfoDouble(Symbol(), SYMBOL_POINT_SIZE);
   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
   double contract_size = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_CONTRACT_SIZE);
   
   return point_size * MathPow(10, digits) * contract_size;
}

//+------------------------------------------------------------------+
//| Get minimum lot size                                            |
//+------------------------------------------------------------------+
double EasyHelpers::getMinimumLot(void)
{
   return SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
}

//+------------------------------------------------------------------+
//| Get maximum lot size                                            |
//+------------------------------------------------------------------+
double EasyHelpers::getMaximumLot(void)
{
   return SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
}

//+------------------------------------------------------------------+
//| Get lot step                                                    |
//+------------------------------------------------------------------+
double EasyHelpers::getLotStep(void)
{
   return SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
}

//+------------------------------------------------------------------+
//| Calculate EMA multiplier                                        |
//+------------------------------------------------------------------+
double EasyHelpers::emaMultiplier(int period)
{
   return 2.0 / (period + 1.0);
}

//+------------------------------------------------------------------+
//| Macro shortcuts for common functions                            |
//+------------------------------------------------------------------+
#define price(type, shift) EasyHelpers::price(type, shift)
#define open(shift) EasyHelpers::open(shift)
#define high(shift) EasyHelpers::high(shift)
#define low(shift) EasyHelpers::low(shift)
#define close(shift) EasyHelpers::close(shift)
#define log(msg) EasyHelpers::log(msg)
#define logInfo(msg) EasyHelpers::logInfo(msg)
#define logWarning(msg) EasyHelpers::logWarning(msg)
#define logError(msg) EasyHelpers::logError(msg)