//+------------------------------------------------------------------+
//|                                      Simple Moving Average EA    |
//|                                    Copyright 2026, EvolveBeyond  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, EvolveBeyond"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <EasyMQL/EasyMQL.mqh>

// Input parameters
input double InpLots = 0.1;
input int InpMAPeriod = 14;
input int InpMagicNumber = 123456;

// Simple MA Trading Strategy
class MATradingStrategy : public EasyStrategy
{
public:
   MATradingStrategy() : EasyStrategy("MA Strategy") {}
   
   void onTick()
   {
      // Get current prices using the Python-like macros
      double current_close = C(0);
      double current_high = H(0);
      double current_low = L(0);
      
      // Calculate simple moving average
      double ma_value = MA(InpMAPeriod, 0);  // MA with period InpMAPeriod, current bar (0)
      
      // Trading logic
      if(current_close > ma_value && current_close > C(1) && C(1) <= MA(InpMAPeriod, 1))
      {
         // Price crossed above MA - potential buy signal
         if(!hasPositionBySymbol(_Symbol))
         {
            openBuy(InpLots);
            EasyHelpers::logInfo("Buy signal: Price " + DoubleToString(current_close) + " above MA " + DoubleToString(ma_value));
         }
      }
      else if(current_close < ma_value && current_close < C(1) && C(1) >= MA(InpMAPeriod, 1))
      {
         // Price crossed below MA - potential sell signal
         if(!hasPositionBySymbol(_Symbol))
         {
            openSell(InpLots);
            EasyHelpers::logInfo("Sell signal: Price " + DoubleToString(current_close) + " below MA " + DoubleToString(ma_value));
         }
      }
      
      // Close opposite positions
      if(hasPositionBySymbol(_Symbol))
      {
         if(getPositionType() == POSITION_TYPE_BUY && current_close < MA(InpMAPeriod, 0))
         {
            closeAll();
            EasyHelpers::logInfo("Closed buy position: Price below MA");
         }
         else if(getPositionType() == POSITION_TYPE_SELL && current_close > MA(InpMAPeriod, 0))
         {
            closeAll();
            EasyHelpers::logInfo("Closed sell position: Price above MA");
         }
      }
   }
};

// Main Expert Advisor class
class SimpleMAEA : public EasyExpert
{
private:
   MATradingStrategy* ma_strategy;

public:
   SimpleMAEA()
   {
      ma_strategy = new MATradingStrategy();
   }

   bool onSetup()
   {
      // Use the chainable API
      setSymbol(_Symbol)
         .setLots(InpLots)
         .setMagic(InpMagicNumber)
         .setStopLoss(100)  // 100 points stop loss
         .setTakeProfit(200) // 200 points take profit
         .Use(ma_strategy); // Register the strategy (multi-strategy support)
      
      EasyHelpers::logInfo("Simple MA EA initialized with period: " + IntegerToString(InpMAPeriod));
      
      // Validate configuration
      EasyConfig& config = EasyServices::Config();
      config.addParamInt("MAPeriod", InpMAPeriod, "Moving Average Period", true, 1, 1000)
            .addParam("Lots", InpLots, "Lot Size", true, 0.01, 100.0);
      
      if(!config.validate())
      {
         EasyHelpers::logWarning("Configuration validation failed");
      }
      
      return true;
   }

   void onTick()
   {
      // onTick is automatically handled by registered strategies
      // But we can add additional logic here if needed
   }

   void onTimer()
   {
      // Timer event handling
   }

   ~SimpleMAEA()
   {
      if(ma_strategy != NULL)
      {
         delete ma_strategy;
         ma_strategy = NULL;
      }
   }
};

// Use the auto-registration macro - no need for manual OnInit/OnDeinit/OnTick
EASY_EXPERT(SimpleMAEA)