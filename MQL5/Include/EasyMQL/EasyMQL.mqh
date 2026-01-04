//+------------------------------------------------------------------+
//|                                                 EasyMQL Main     |
//|                                    Copyright 2026, EvolveBeyond  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, EvolveBeyond"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <EasyCore.mqh>
#include <EasyHelpers.mqh>
#include <EasyConfig.mqh>

// Auto-registration macros
#define EASY_INDICATOR(class_name) \
   class_name g_instance; \
   int OnInit() { \
      g_indicator_instance = &g_instance; \
      if(!g_instance.Initialize()) return INIT_FAILED; \
      if(!g_instance.onSetup()) return INIT_FAILED; \
      if(!g_instance.RegisterBuffers()) return INIT_FAILED; \
      return INIT_SUCCEEDED; \
   } \
   void OnDeinit(const int reason) { \
      if(g_indicator_instance) { \
         g_instance.onCleanup(); \
         g_instance.Deinitialize(); \
         g_indicator_instance = NULL; \
      } \
   } \
   int OnCalculate(const int rates_total, \
                  const int prev_calculated, \
                  const datetime &time[], \
                  const double &open[], \
                  const double &high[], \
                  const double &low[], \
                  const double &close[], \
                  const long &tick_volume[], \
                  const long &volume[], \
                  const int &spread[]) { \
      if(g_indicator_instance) { \
         int result = g_instance.onUpdate(rates_total, prev_calculated); \
         if(!result) return prev_calculated; \
      } \
      return rates_total; \
   }

#define EASY_EXPERT(class_name) \
   class_name g_instance; \
   int OnInit() { \
      g_expert_instance = &g_instance; \
      if(!g_instance.Initialize()) return INIT_FAILED; \
      if(!g_instance.onSetup()) return INIT_FAILED; \
      return INIT_SUCCEEDED; \
   } \
   void OnDeinit(const int reason) { \
      if(g_expert_instance) { \
         g_expert_instance->Deinitialize(); \
         g_expert_instance = NULL; \
      } \
   } \
   void OnTick() { \
      if(g_expert_instance) { \
         g_instance.onTick(); \
      } \
   } \
   void OnTimer() { \
      if(g_expert_instance) { \
         g_instance.onTimer(); \
      } \
   }

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
//| Helper functions for users                                       |
//+------------------------------------------------------------------+

// Get data arrays
double* getOpen(void) { return g_open; }
double* getHigh(void) { return g_high; }
double* getLow(void) { return g_low; }
double* getClose(void) { return g_close; }
double* getVolume(void) { return g_volume; }
datetime* getTime(void) { return g_time; }

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