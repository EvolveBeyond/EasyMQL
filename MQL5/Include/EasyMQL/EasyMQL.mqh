//+------------------------------------------------------------------+
//|                                                 EasyMQL Main     |
//|                                    Copyright 2026, EasyMQL Team  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, EasyMQL Team"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <EasyCore.mqh>
#include <EasyHelpers.mqh>
#include <EasyConfig.mqh>

// Include all framework components
#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/OrderInfo.mqh>
#include <Arrays/ArrayObj.mqh>

// Global framework instance pointers
EasyIndicator* g_indicator_instance = NULL;
EasyExpert* g_expert_instance = NULL;

// Global arrays for data access
double g_open[];
double g_high[];
double g_low[];
double g_close[];
double g_volume[];
datetime g_time[];

//+------------------------------------------------------------------+
//| Auto Event Handler Class                                         |
//+------------------------------------------------------------------+
class AutoEventHandler
{
public:
   static bool        HandleOnInit(void);
   static void        HandleOnDeinit(int reason);
   static int         HandleOnCalculate(const int rates_total,
                                       const int prev_calculated,
                                       const datetime &time[],
                                       const double &open[],
                                       const double &high[],
                                       const double &low[],
                                       const double &close[],
                                       const long &tick_volume[],
                                       const long &volume[],
                                       const int &spread[]);
   static void        HandleOnTick(void);
   static void        HandleOnTimer(void);
   
private:
   static bool        InitializeDataArrays(const datetime &time[],
                                          const double &open[],
                                          const double &high[],
                                          const double &low[],
                                          const double &close[],
                                          const long &tick_volume[],
                                          const long &volume[],
                                          const int &spread[],
                                          int rates_total);
};

//+------------------------------------------------------------------+
//| Handle OnInit event                                              |
//+------------------------------------------------------------------+
bool AutoEventHandler::HandleOnInit(void)
{
   // Initialize global data arrays
   int total_bars = Bars(Symbol(), PERIOD_CURRENT);
   
   if(ArrayResize(g_open, total_bars) <= 0) return false;
   if(ArrayResize(g_high, total_bars) <= 0) return false;
   if(ArrayResize(g_low, total_bars) <= 0) return false;
   if(ArrayResize(g_close, total_bars) <= 0) return false;
   if(ArrayResize(g_volume, total_bars) <= 0) return false;
   if(ArrayResize(g_time, total_bars) <= 0) return false;
   
   // If we have an indicator instance, initialize it
   if(g_indicator_instance != NULL)
   {
      if(!g_indicator_instance->Initialize())
      {
         EasyHelpers::logError("Failed to initialize indicator");
         return false;
      }
      
      // Call the user's onSetup method
      if(!g_indicator_instance->onSetup())
      {
         EasyHelpers::logError("Indicator onSetup failed");
         return false;
      }
      
      // Register buffers if needed
      g_indicator_instance->RegisterBuffers();
   }
   // If we have an expert advisor instance, initialize it
   else if(g_expert_instance != NULL)
   {
      if(!g_expert_instance->Initialize())
      {
         EasyHelpers::logError("Failed to initialize expert advisor");
         return false;
      }
      
      // Call the user's onSetup method
      if(!g_expert_instance->onSetup())
      {
         EasyHelpers::logError("Expert advisor onSetup failed");
         return false;
      }
   }
   
   EasyHelpers::logInfo("EasyMQL Framework initialized successfully");
   return true;
}

//+------------------------------------------------------------------+
//| Handle OnDeinit event                                            |
//+------------------------------------------------------------------+
void AutoEventHandler::HandleOnDeinit(int reason)
{
   // Call user cleanup if needed
   if(g_indicator_instance != NULL)
   {
      g_indicator_instance->onCleanup();
      g_indicator_instance->Deinitialize();
      delete g_indicator_instance;
      g_indicator_instance = NULL;
   }
   else if(g_expert_instance != NULL)
   {
      g_expert_instance->Deinitialize();
      delete g_expert_instance;
      g_expert_instance = NULL;
   }
   
   // Clean up global arrays
   ArrayFree(g_open);
   ArrayFree(g_high);
   ArrayFree(g_low);
   ArrayFree(g_close);
   ArrayFree(g_volume);
   ArrayFree(g_time);
   
   string reason_str = "";
   switch(reason)
   {
      case REASON_PROGRAM:
         reason_str = "Program termination";
         break;
      case REASON_REMOVE:
         reason_str = "Expert Advisor/Indicator removed";
         break;
      case REASON_RECOMPILE:
         reason_str = "Expert Advisor/Indicator recompiled";
         break;
      case REASON_CHARTCHANGE:
         reason_str = "Chart changed";
         break;
      case REASON_CHARTCLOSE:
         reason_str = "Chart closed";
         break;
      case REASON_TIMEHOUR:
         reason_str = "Hour changed";
         break;
      case REASON_TIMESERVER:
         reason_str = "Time server";
         break;
      case REASON_TIME trade:
         reason_str = "Trade context";
         break;
      default:
         reason_str = "Unknown reason: " + IntegerToString(reason);
         break;
   }
   
   EasyHelpers::logInfo("EasyMQL Framework deinitialized: " + reason_str);
}

//+------------------------------------------------------------------+
//| Handle OnCalculate event                                         |
//+------------------------------------------------------------------+
int AutoEventHandler::HandleOnCalculate(const int rates_total,
                                       const int prev_calculated,
                                       const datetime &time[],
                                       const double &open[],
                                       const double &high[],
                                       const double &low[],
                                       const double &close[],
                                       const long &tick_volume[],
                                       const long &volume[],
                                       const int &spread[])
{
   // Initialize data arrays with current data
   if(!InitializeDataArrays(time, open, high, low, close, tick_volume, volume, spread, rates_total))
      return 0;
   
   // If we have an indicator instance, perform calculations
   if(g_indicator_instance != NULL)
   {
      if(!g_indicator_instance->onUpdate(rates_total, prev_calculated))
      {
         EasyHelpers::logError("Indicator onUpdate failed");
         return 0;
      }
   }
   
   return rates_total;
}

//+------------------------------------------------------------------+
//| Initialize data arrays with current market data                  |
//+------------------------------------------------------------------+
bool AutoEventHandler::InitializeDataArrays(const datetime &time[],
                                           const double &open[],
                                           const double &high[],
                                           const double &low[],
                                           const double &close[],
                                           const long &tick_volume[],
                                           const long &volume[],
                                           const int &spread[],
                                           int rates_total)
{
   // Resize arrays to match the data
   if(ArrayResize(g_open, rates_total) <= 0) return false;
   if(ArrayResize(g_high, rates_total) <= 0) return false;
   if(ArrayResize(g_low, rates_total) <= 0) return false;
   if(ArrayResize(g_close, rates_total) <= 0) return false;
   if(ArrayResize(g_volume, rates_total) <= 0) return false;
   if(ArrayResize(g_time, rates_total) <= 0) return false;
   
   // Copy data to global arrays
   for(int i = 0; i < rates_total; i++)
   {
      g_open[i] = open[i];
      g_high[i] = high[i];
      g_low[i] = low[i];
      g_close[i] = close[i];
      g_volume[i] = (double)volume[i];
      g_time[i] = time[i];
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Handle OnTick event                                              |
//+------------------------------------------------------------------+
void AutoEventHandler::HandleOnTick(void)
{
   // If we have an expert advisor instance, handle the tick
   if(g_expert_instance != NULL)
   {
      g_expert_instance->onTick();
   }
}

//+------------------------------------------------------------------+
//| Handle OnTimer event                                             |
//+------------------------------------------------------------------+
void AutoEventHandler::HandleOnTimer(void)
{
   // If we have an expert advisor instance, handle the timer
   if(g_expert_instance != NULL)
   {
      g_expert_instance->onTimer();
   }
}

//+------------------------------------------------------------------+
//| Helper functions for users                                       |
//+------------------------------------------------------------------+

// Get data arrays
double& getOpen(void) { return g_open; }
double& getHigh(void) { return g_high; }
double& getLow(void) { return g_low; }
double& getClose(void) { return g_close; }
double& getVolume(void) { return g_volume; }
datetime& getTime(void) { return g_time; }

// Set indicator instance
void setIndicatorInstance(EasyIndicator* indicator)
{
   g_indicator_instance = indicator;
}

// Set expert advisor instance
void setExpertInstance(EasyExpert* expert)
{
   g_expert_instance = expert;
}

// Get current instance types
EasyIndicator* getIndicatorInstance(void) { return g_indicator_instance; }
EasyExpert* getExpertInstance(void) { return g_expert_instance; }