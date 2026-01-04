//+------------------------------------------------------------------+
//|                                       Simple Moving Average Demo |
//|                                    Copyright 2026, EvolveBeyond  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, EvolveBeyond"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

//--- plot SimpleMA
#property indicator_label1  "SMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#include <EasyMQL/EasyMQL.mqh>

// Input parameters
input int InpMAPeriod = 14;

// Simple Moving Average indicator class
class SimpleMA : public EasyIndicator
{
private:
   double ma_buffer[];

public:
   SimpleMA() {}

   bool onSetup()
   {
      // Chainable API usage
      setTitle("Simple Moving Average")
         .addBuffer(Line, Blue, 1, "SMA");
      
      // Set indicator properties
      IndicatorSetInteger(INDICATOR_DIGITS, (int)_Digits);
      IndicatorSetString(INDICATOR_SHORTNAME, "SMA(" + IntegerToString(InpMAPeriod) + ")");
      
      // Register the indicator buffer
      SetIndexBuffer(0, ma_buffer, INDICATOR_DATA);
      
      return true;
   }

   bool onUpdate(int total, int prev)
   {
      if(total <= InpMAPeriod) return false;
      
      // Calculate SMA using EasyHelpers
      double source[];
      ArrayCopyRates(source);
      
      EasyHelpers::sma(source, InpMAPeriod, ma_buffer);
      
      // Also demonstrate the Python-like macros
      double current_price = C(0);  // Current close price
      double prev_price = C(1);     // Previous close price
      
      return true;
   }

   void onCleanup()
   {
      // Cleanup if needed
   }
};

// Use the auto-registration macro - no need for manual OnInit/OnDeinit/OnCalculate
EASY_INDICATOR(SimpleMA)