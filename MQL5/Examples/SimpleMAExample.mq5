//+------------------------------------------------------------------+
//|                                           SimpleMAExample.mq5    |
//|                                    Copyright 2026, EasyMQL Team  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, EasyMQL Team"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots 1

// Set drawing properties
#property indicator_type  TYPE_LINE
#property indicator_color1 clrBlue
#property indicator_width1 2

#include <EasyMQL/EasyMQL.mqh>

// Input parameters
input int InpMAPeriod = 14;              // MA Period
input Color InpMAColor = clrBlue;        // MA Color

// Simple Moving Average Example Indicator
class SimpleMAExample : public EasyIndicator
{
private:
   int                 m_period;          // MA period
   double              m_ma_buffer[];     // MA values

public:
                     SimpleMAExample(void);
                     ~SimpleMAExample(void);
   
   // Override required methods
   virtual bool       onSetup(void);
   virtual bool       onUpdate(int total, int prev);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
SimpleMAExample::SimpleMAExample(void)
{
   m_period = 14;
   ArrayResize(m_ma_buffer, 10000);
   ArrayInitialize(m_ma_buffer, 0.0);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
SimpleMAExample::~SimpleMAExample(void)
{
}

//+------------------------------------------------------------------+
//| Setup method - called once at initialization                     |
//+------------------------------------------------------------------+
bool SimpleMAExample::onSetup(void)
{
   // Set the indicator title and configuration using chainable methods
   setTitle("Simple MA Example")
      .addBuffer(Line, InpMAColor, 2, "MA");
   
   // Set our parameters
   m_period = InpMAPeriod;
   
   // Set the indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME, "SMA(" + IntegerToString(m_period) + ")");
   
   // Set drawing style
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpMAColor);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   
   EasyHelpers::logInfo("Simple MA Example initialized with period: " + IntegerToString(m_period));
   return true;
}

//+------------------------------------------------------------------+
//| Update method - called on each bar calculation                   |
//+------------------------------------------------------------------+
bool SimpleMAExample::onUpdate(int total, int prev)
{
   // Calculate from the previous calculated index or start from period
   int start = (prev > 0) ? prev - 1 : m_period;
   
   // Calculate the moving average for each bar
   for(int i = start; i < total; i++)
   {
      // Calculate simple moving average using EasyHelpers
      double sum = 0.0;
      for(int j = 0; j < m_period; j++)
      {
         sum += EasyHelpers::close(i + j); // Use EasyHelpers for price access
      }
      
      m_ma_buffer[i] = sum / m_period;
      
      // Set the indicator buffer value using framework method
      setBufferValue(0, i, m_ma_buffer[i]);
   }
   
   return true;
}

// Global instance of our indicator
SimpleMAExample g_indicator;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set the global indicator instance
   setIndicatorInstance(&g_indicator);
   
   // Let the framework handle initialization
   return AutoEventHandler::HandleOnInit() ? INIT_SUCCEEDED : INIT_FAILED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Let the framework handle deinitialization
   AutoEventHandler::HandleOnDeinit(reason);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
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
   // Let the framework handle the calculation
   return AutoEventHandler::HandleOnCalculate(rates_total, prev_calculated, 
                                             time, open, high, low, close, 
                                             tick_volume, volume, spread);
}