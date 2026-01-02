//+------------------------------------------------------------------+
//|                                           SimpleMACrossEA.mq5    |
//|                                    Copyright 2026, EasyMQL Team  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, EasyMQL Team"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <EasyMQL/EasyMQL.mqh>

// Input parameters
input double InpLots = 0.1;              // Lot size
input int InpFastMAPeriod = 10;          // Fast MA Period
input int InpSlowMAPeriod = 20;          // Slow MA Period
input int InpStopLoss = 100;             // Stop Loss in points
input int InpTakeProfit = 200;           // Take Profit in points

// Simple MA Crossover Expert Advisor Example
class SimpleMACrossEA : public EasyExpert
{
private:
   int                 m_fast_period;       // Fast MA period
   int                 m_slow_period;       // Slow MA period
   double              m_fast_ma[10000];    // Fast MA values
   double              m_slow_ma[10000];    // Slow MA values

public:
                     SimpleMACrossEA(void);
                     ~SimpleMACrossEA(void);
   
   // Override required methods
   virtual bool       onSetup(void);
   virtual void       onTick(void);
   
private:
   bool               CheckForSignals(void);
   bool               CalculateMASignals(void);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
SimpleMACrossEA::SimpleMACrossEA(void)
{
   m_fast_period = 10;
   m_slow_period = 20;
   
   ArrayInitialize(m_fast_ma, 0.0);
   ArrayInitialize(m_slow_ma, 0.0);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
SimpleMACrossEA::~SimpleMACrossEA(void)
{
}

//+------------------------------------------------------------------+
//| Setup method - called once at initialization                     |
//+------------------------------------------------------------------+
bool SimpleMACrossEA::onSetup(void)
{
   // Configure the EA with input parameters using chainable methods
   setLots(InpLots)
      .setStopLoss(InpStopLoss)
      .setTakeProfit(InpTakeProfit)
      .setMagic(123456);  // Unique magic number for this EA
   
   // Set our local parameters
   m_fast_period = InpFastMAPeriod;
   m_slow_period = InpSlowMAPeriod;
   
   EasyHelpers::logInfo("Simple MA Cross EA initialized");
   EasyHelpers::logInfo("Fast MA: " + IntegerToString(m_fast_period) + 
                       ", Slow MA: " + IntegerToString(m_slow_period));
   
   return true;
}

//+------------------------------------------------------------------+
//| Tick method - called on each new tick                            |
//+------------------------------------------------------------------+
void SimpleMACrossEA::onTick(void)
{
   // Only process if we have enough bars
   if(Bars(Symbol(), PERIOD_CURRENT) < m_slow_period + 5)
      return;
   
   // Check for trading signals
   CheckForSignals();
}

//+------------------------------------------------------------------+
//| Check for buy/sell signals                                       |
//+------------------------------------------------------------------+
bool SimpleMACrossEA::CheckForSignals(void)
{
   // Calculate MA values
   if(!CalculateMASignals())
      return false;
   
   // Get current and previous MA values
   double current_fast = m_fast_ma[0];
   double current_slow = m_slow_ma[0];
   double prev_fast = m_fast_ma[1];
   double prev_slow = m_slow_ma[1];
   
   // Check for crossover conditions
   bool bull_cross = (prev_fast <= prev_slow) && (current_fast > current_slow);  // Fast crosses above slow
   bool bear_cross = (prev_fast >= prev_slow) && (current_fast < current_slow);  // Fast crosses below slow
   
   // Trading logic
   if(bull_cross && !hasPosition())
   {
      // Buy signal - fast MA crosses above slow MA
      EasyHelpers::log("Bullish crossover detected - Opening BUY position");
      
      if(openBuy(InpLots))
      {
         EasyHelpers::logInfo("BUY position opened successfully");
      }
      else
      {
         EasyHelpers::logError("Failed to open BUY position: " + IntegerToString(GetLastError()));
      }
   }
   else if(bear_cross && !hasPosition())
   {
      // Sell signal - fast MA crosses below slow MA
      EasyHelpers::log("Bearish crossover detected - Opening SELL position");
      
      if(openSell(InpLots))
      {
         EasyHelpers::logInfo("SELL position opened successfully");
      }
      else
      {
         EasyHelpers::logError("Failed to open SELL position: " + IntegerToString(GetLastError()));
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculate MA signals                                             |
//+------------------------------------------------------------------+
bool SimpleMACrossEA::CalculateMASignals(void)
{
   // Get the required number of close prices
   int rates = Bars(Symbol(), PERIOD_CURRENT);
   if(rates < m_slow_period)
      return false;
   
   // Calculate Fast MA
   double close_array[10000];
   ArrayInitialize(close_array, 0.0);
   
   for(int i = 0; i < rates; i++)
   {
      close_array[i] = EasyHelpers::close(i);
   }
   
   // Calculate Fast MA
   double fast_ma_temp[10000];
   ArrayInitialize(fast_ma_temp, 0.0);
   if(!EasyHelpers::sma(close_array, m_fast_period, fast_ma_temp))
      return false;
   
   // Copy to our internal array
   for(int i = 0; i < rates; i++)
   {
      m_fast_ma[i] = fast_ma_temp[i];
   }
   
   // Calculate Slow MA
   double slow_ma_temp[10000];
   ArrayInitialize(slow_ma_temp, 0.0);
   if(!EasyHelpers::sma(close_array, m_slow_period, slow_ma_temp))
      return false;
   
   // Copy to our internal array
   for(int i = 0; i < rates; i++)
   {
      m_slow_ma[i] = slow_ma_temp[i];
   }
   
   return true;
}

// Global instance of our EA
SimpleMACrossEA g_ea;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set the global expert instance
   setExpertInstance(&g_ea);
   
   // Let the framework handle initialization
   return AutoEventHandler::HandleOnInit() ? INIT_SUCCEEDED : INIT_FAILED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Close all positions on deinitialization
   if(g_ea.hasPosition())
   {
      g_ea.closeAll();
      EasyHelpers::logInfo("All positions closed on deinitialization");
   }
   
   // Let the framework handle deinitialization
   AutoEventHandler::HandleOnDeinit(reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Let the framework handle the tick
   AutoEventHandler::HandleOnTick();
}

//+------------------------------------------------------------------+
//| Timer function (if needed)                                       |
//+------------------------------------------------------------------+
void OnTimer()
{
   // Let the framework handle the timer if needed
   AutoEventHandler::HandleOnTimer();
}