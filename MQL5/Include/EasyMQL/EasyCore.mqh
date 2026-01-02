//+------------------------------------------------------------------+
//|                                                 EasyMQL Core     |
//|                                    Copyright 2026, EasyMQL Team  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, EasyMQL Team"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Arrays/ArrayObj.mqh>
#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/OrderInfo.mqh>

// Enums for readability
enum DrawType
{
   Line = 0,
   Histogram,
   Arrow,
   Dots,
   Background,
   Section,
   None
};

enum Color
{
   Red = clrRed,
   Green = clrGreen,
   Blue = clrBlue,
   Yellow = clrYellow,
   Cyan = clrCyan,
   Magenta = clrMagenta,
   Orange = clrOrange,
   Gray = clrGray,
   White = clrWhite,
   Black = clrBlack,
   None = clrNONE
};

enum PriceType
{
   Open = MODE_OPEN,
   High = MODE_HIGH,
   Low = MODE_LOW,
   Close = MODE_CLOSE,
   Median = MODE_MEDIAN,
   Typical = MODE_TYPICAL,
   Weighted = MODE_WEIGHTED
};

enum OrderType
{
   Buy = ORDER_TYPE_BUY,
   Sell = ORDER_TYPE_SELL,
   BuyLimit = ORDER_TYPE_BUY_LIMIT,
   SellLimit = ORDER_TYPE_SELL_LIMIT,
   BuyStop = ORDER_TYPE_BUY_STOP,
   SellStop = ORDER_TYPE_SELL_STOP,
   BuyStopLimit = ORDER_TYPE_BUY_STOP_LIMIT,
   SellStopLimit = ORDER_TYPE_SELL_STOP_LIMIT
};

// Forward declarations
class EasyIndicator;
class EasyExpert;
class EasyHelpers;

//+------------------------------------------------------------------+
//| EasyMQL Core Base Class                                          |
//+------------------------------------------------------------------+
class EasyMQL
{
protected:
   string              m_name;              // Name of the instance
   bool                m_initialized;       // Initialization flag
   int                 m_total_buffers;     // Total number of buffers
   int                 m_total_labels;      // Total number of labels/drawings

public:
                     EasyMQL(void);
                     ~EasyMQL(void);
   virtual bool       Initialize(void);
   virtual void       Deinitialize(void);
   string             Name(void) const { return m_name; }
   bool               IsInitialized(void) const { return m_initialized; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
EasyMQL::EasyMQL(void)
{
   m_name = "EasyMQL";
   m_initialized = false;
   m_total_buffers = 0;
   m_total_labels = 0;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
EasyMQL::~EasyMQL(void)
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool EasyMQL::Initialize(void)
{
   m_initialized = true;
   return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void EasyMQL::Deinitialize(void)
{
   m_initialized = false;
}

//+------------------------------------------------------------------+
//| Easy Indicator Base Class                                        |
//+------------------------------------------------------------------+
class EasyIndicator : public EasyMQL
{
private:
   string              m_title;             // Indicator title
   int                 m_buffers[32];       // Buffer handles
   DrawType            m_buffer_types[32];  // Buffer types
   Color               m_buffer_colors[32]; // Buffer colors
   int                 m_buffer_widths[32]; // Buffer widths
   string              m_buffer_names[32];  // Buffer names
   int                 m_drawings[32];      // Drawing handles
   string              m_property_names[32]; // Property names
   double              m_property_values[32]; // Property values

protected:
   double              m_buffer_data[32][10000]; // Buffer data arrays
   int                 m_buffer_size;       // Size of each buffer
   int                 m_total_calculated;  // Total calculated bars

public:
                     EasyIndicator(void);
                     ~EasyIndicator(void);
   virtual bool       Initialize(void);
   virtual void       Deinitialize(void);
   
   // Setup methods
   EasyIndicator&     setTitle(string title);
   EasyIndicator&     addBuffer(DrawType type, Color color = None, int width = 1, string name = "");
   EasyIndicator&     setBuffer(int index, double &data[]);
   EasyIndicator&     setBufferValue(int index, int bar_index, double value);
   
   // Calculation methods
   virtual bool       onSetup(void);        // Override in derived class
   virtual bool       onUpdate(int total, int prev); // Override in derived class
   virtual void       onCleanup(void);      // Override in derived class
   
   // Framework methods
   bool               RegisterBuffers(void);
   bool               SetIndexBuffer(int index, double &buffer, int type = TYPE_MAIN);
   bool               PlotIndex(int index, int shift, double value);
   double             GetBufferValue(int buffer_index, int bar_index);
   
   // Accessors
   string             Title(void) const { return m_title; }
   int                TotalBuffers(void) const { return m_total_buffers; }
   int                TotalCalculated(void) const { return m_total_calculated; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
EasyIndicator::EasyIndicator(void)
{
   m_title = "Easy Indicator";
   m_buffer_size = 10000;
   m_total_calculated = 0;
   
   for(int i = 0; i < 32; i++)
   {
      m_buffers[i] = -1;
      m_buffer_types[i] = None;
      m_buffer_colors[i] = None;
      m_buffer_widths[i] = 1;
      m_buffer_names[i] = "";
      m_drawings[i] = -1;
      m_property_names[i] = "";
      m_property_values[i] = 0.0;
      
      // Initialize buffer data
      ArrayInitialize(m_buffer_data[i], 0.0);
   }
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
EasyIndicator::~EasyIndicator(void)
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool EasyIndicator::Initialize(void)
{
   m_initialized = EasyMQL::Initialize();
   return m_initialized;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void EasyIndicator::Deinitialize(void)
{
   for(int i = 0; i < 32; i++)
   {
      if(m_buffers[i] >= 0)
      {
         // Cleanup buffer if needed
         m_buffers[i] = -1;
      }
   }
   
   EasyMQL::Deinitialize();
}

//+------------------------------------------------------------------+
//| Set indicator title                                              |
//+------------------------------------------------------------------+
EasyIndicator& EasyIndicator::setTitle(string title)
{
   m_title = title;
   return *this;
}

//+------------------------------------------------------------------+
//| Add buffer with chainable configuration                        |
//+------------------------------------------------------------------+
EasyIndicator& EasyIndicator::addBuffer(DrawType type, Color color, int width, string name)
{
   if(m_total_buffers >= 32)
      return *this;
      
   int index = m_total_buffers++;
   m_buffer_types[index] = type;
   m_buffer_colors[index] = color;
   m_buffer_widths[index] = width;
   m_buffer_names[index] = (name == "") ? "Buffer" + IntegerToString(index) : name;
   
   // Set indicator properties based on buffer type
   switch(type)
   {
      case Line:
         IndicatorSetInteger(INDICATOR_TYPE, DRAW_LINE);
         break;
      case Histogram:
         IndicatorSetInteger(INDICATOR_TYPE, DRAW_HISTOGRAM);
         break;
      case Arrow:
         IndicatorSetInteger(INDICATOR_TYPE, DRAW_ARROW);
         break;
      case Dots:
         IndicatorSetInteger(INDICATOR_TYPE, DRAW_SECTION);
         break;
      default:
         IndicatorSetInteger(INDICATOR_TYPE, DRAW_NONE);
         break;
   }
   
   // Set color if specified
   if(color != None)
   {
      IndicatorSetInteger(INDICATOR_COLOR, color);
   }
   
   // Set width if specified
   if(width > 1)
   {
      IndicatorSetInteger(INDICATOR_WIDTH, width);
   }
   
   // Set name if specified
   if(name != "")
   {
      IndicatorSetString(INDICATOR_SHORTNAME, name);
   }
   
   return *this;
}

//+------------------------------------------------------------------+
//| Set buffer data                                                  |
//+------------------------------------------------------------------+
EasyIndicator& EasyIndicator::setBuffer(int index, double &data[])
{
   if(index < 0 || index >= m_total_buffers)
      return *this;
      
   int size = ArraySize(data);
   for(int i = 0; i < MathMin(size, m_buffer_size); i++)
   {
      m_buffer_data[index][i] = data[i];
   }
   
   return *this;
}

//+------------------------------------------------------------------+
//| Set buffer value                                                 |
//+------------------------------------------------------------------+
EasyIndicator& EasyIndicator::setBufferValue(int index, int bar_index, double value)
{
   if(index < 0 || index >= m_total_buffers || bar_index < 0 || bar_index >= m_buffer_size)
      return *this;
      
   m_buffer_data[index][bar_index] = value;
   return *this;
}

//+------------------------------------------------------------------+
//| Virtual method: Setup                                            |
//+------------------------------------------------------------------+
bool EasyIndicator::onSetup(void)
{
   // Override in derived class
   return true;
}

//+------------------------------------------------------------------+
//| Virtual method: Update                                           |
//+------------------------------------------------------------------+
bool EasyIndicator::onUpdate(int total, int prev)
{
   // Override in derived class
   m_total_calculated = total;
   return true;
}

//+------------------------------------------------------------------+
//| Virtual method: Cleanup                                          |
//+------------------------------------------------------------------+
void EasyIndicator::onCleanup(void)
{
   // Override in derived class if needed
}

//+------------------------------------------------------------------+
//| Register buffers                                                 |
//+------------------------------------------------------------------+
bool EasyIndicator::RegisterBuffers(void)
{
   for(int i = 0; i < m_total_buffers; i++)
   {
      // Set up the indicator buffer
      if(!SetIndexBuffer(i, m_buffer_data[i]))
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Set index buffer                                                 |
//+------------------------------------------------------------------+
bool EasyIndicator::SetIndexBuffer(int index, double &buffer, int type)
{
   if(SetIndexBuffer(index, buffer, type))
   {
      m_buffers[index] = index; // Store as a simple reference
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Plot index value                                                 |
//+------------------------------------------------------------------+
bool EasyIndicator::PlotIndex(int index, int shift, double value)
{
   if(index < 0 || index >= m_total_buffers || shift < 0 || shift >= m_buffer_size)
      return false;
      
   m_buffer_data[index][shift] = value;
   return true;
}

//+------------------------------------------------------------------+
//| Get buffer value                                                 |
//+------------------------------------------------------------------+
double EasyIndicator::GetBufferValue(int buffer_index, int bar_index)
{
   if(buffer_index < 0 || buffer_index >= m_total_buffers || bar_index < 0 || bar_index >= m_buffer_size)
      return 0.0;
      
   return m_buffer_data[buffer_index][bar_index];
}

//+------------------------------------------------------------------+
//| Easy Expert Advisor Base Class                                   |
//+------------------------------------------------------------------+
class EasyExpert : public EasyMQL
{
private:
   CTrade              m_trade;             // Trade object
   CPositionInfo       m_position_info;     // Position info object
   COrderInfo          m_order_info;        // Order info object
   string              m_symbol;            // Trading symbol
   ENUM_TIMEFRAMES     m_timeframe;         // Timeframe
   double              m_lots;              // Lot size
   int                 m_magic_number;      // Magic number
   double              m_slippage;          // Slippage
   int                 m_trailing_stop;     // Trailing stop in points
   int                 m_take_profit;       // Take profit in points
   int                 m_stop_loss;         // Stop loss in points

protected:
   bool                m_is_ticking;        // Tick processing flag

public:
                     EasyExpert(void);
                     ~EasyExpert(void);
   virtual bool       Initialize(void);
   virtual void       Deinitialize(void);
   
   // Setup methods
   EasyExpert&        setSymbol(string symbol);
   EasyExpert&        setTimeframe(ENUM_TIMEFRAMES timeframe);
   EasyExpert&        setLots(double lots);
   EasyExpert&        setMagic(int magic);
   EasyExpert&        setSlippage(double slippage);
   EasyExpert&        setStopLoss(int points);
   EasyExpert&        setTakeProfit(int points);
   EasyExpert&        setTrailingStop(int points);
   
   // Trading methods
   bool               openBuy(double lots = 0.0, double price = 0.0, int slippage = 0, 
                              double stop_loss = 0.0, double take_profit = 0.0, 
                              string comment = "", double commission = 0.0);
   bool               openSell(double lots = 0.0, double price = 0.0, int slippage = 0, 
                               double stop_loss = 0.0, double take_profit = 0.0, 
                               string comment = "", double commission = 0.0);
   bool               closeAll(void);
   bool               closeBySymbol(string symbol);
   bool               closeByMagic(int magic);
   bool               closePosition(ulong ticket);
   bool               modifyPosition(ulong ticket, double stop_loss, double take_profit);
   
   // Position checking
   bool               hasPosition(void);
   bool               hasPositionBySymbol(string symbol);
   bool               hasPositionByMagic(int magic);
   double             getPositionVolume(void);
   double             getPositionProfit(void);
   double             getPositionOpenPrice(void);
   ENUM_POSITION_TYPE getPositionType(void);
   
   // Virtual methods to override
   virtual bool       onSetup(void);        // Override in derived class
   virtual void       onTick(void);         // Override in derived class
   virtual void       onTimer(void);        // Override in derived class
   
   // Accessors
   string             Symbol(void) const { return m_symbol; }
   ENUM_TIMEFRAMES    Timeframe(void) const { return m_timeframe; }
   double             Lots(void) const { return m_lots; }
   int                MagicNumber(void) const { return m_magic_number; }
   bool               IsTicking(void) const { return m_is_ticking; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
EasyExpert::EasyExpert(void)
{
   m_symbol = Symbol();
   m_timeframe = PERIOD_CURRENT;
   m_lots = 0.1;
   m_magic_number = 123456;
   m_slippage = 3.0;
   m_trailing_stop = 0;
   m_take_profit = 0;
   m_stop_loss = 0;
   m_is_ticking = false;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
EasyExpert::~EasyExpert(void)
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool EasyExpert::Initialize(void)
{
   if(!EasyMQL::Initialize())
      return false;
      
   m_trade.SetExpertMagicNumber(m_magic_number);
   m_trade.SetDeviationInPoints((int)m_slippage);
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void EasyExpert::Deinitialize(void)
{
   EasyMQL::Deinitialize();
}

//+------------------------------------------------------------------+
//| Set trading symbol                                               |
//+------------------------------------------------------------------+
EasyExpert& EasyExpert::setSymbol(string symbol)
{
   m_symbol = symbol;
   return *this;
}

//+------------------------------------------------------------------+
//| Set timeframe                                                    |
//+------------------------------------------------------------------+
EasyExpert& EasyExpert::setTimeframe(ENUM_TIMEFRAMES timeframe)
{
   m_timeframe = timeframe;
   return *this;
}

//+------------------------------------------------------------------+
//| Set lot size                                                     |
//+------------------------------------------------------------------+
EasyExpert& EasyExpert::setLots(double lots)
{
   m_lots = MathMax(0.01, lots);
   return *this;
}

//+------------------------------------------------------------------+
//| Set magic number                                                 |
//+------------------------------------------------------------------+
EasyExpert& EasyExpert::setMagic(int magic)
{
   m_magic_number = magic;
   m_trade.SetExpertMagicNumber(magic);
   return *this;
}

//+------------------------------------------------------------------+
//| Set slippage                                                     |
//+------------------------------------------------------------------+
EasyExpert& EasyExpert::setSlippage(double slippage)
{
   m_slippage = slippage;
   m_trade.SetDeviationInPoints((int)slippage);
   return *this;
}

//+------------------------------------------------------------------+
//| Set stop loss                                                    |
//+------------------------------------------------------------------+
EasyExpert& EasyExpert::setStopLoss(int points)
{
   m_stop_loss = points;
   return *this;
}

//+------------------------------------------------------------------+
//| Set take profit                                                  |
//+------------------------------------------------------------------+
EasyExpert& EasyExpert::setTakeProfit(int points)
{
   m_take_profit = points;
   return *this;
}

//+------------------------------------------------------------------+
//| Set trailing stop                                                |
//+------------------------------------------------------------------+
EasyExpert& EasyExpert::setTrailingStop(int points)
{
   m_trailing_stop = points;
   return *this;
}

//+------------------------------------------------------------------+
//| Open buy position                                                |
//+------------------------------------------------------------------+
bool EasyExpert::openBuy(double lots, double price, int slippage, 
                        double stop_loss, double take_profit, 
                        string comment, double commission)
{
   double use_lots = (lots > 0) ? lots : m_lots;
   double use_sl = (stop_loss > 0) ? stop_loss : 0;
   double use_tp = (take_profit > 0) ? take_profit : 0;
   int use_slippage = (slippage > 0) ? slippage : (int)m_slippage;
   
   if(use_sl == 0 && m_stop_loss > 0)
      use_sl = SymbolInfoDouble(m_symbol, SYMBOL_BID) - m_stop_loss * Point();
   if(use_tp == 0 && m_take_profit > 0)
      use_tp = SymbolInfoDouble(m_symbol, SYMBOL_BID) + m_take_profit * Point();
   
   return m_trade.Buy(use_lots, m_symbol, price, use_slippage, use_sl, use_tp, comment);
}

//+------------------------------------------------------------------+
//| Open sell position                                               |
//+------------------------------------------------------------------+
bool EasyExpert::openSell(double lots, double price, int slippage, 
                         double stop_loss, double take_profit, 
                         string comment, double commission)
{
   double use_lots = (lots > 0) ? lots : m_lots;
   double use_sl = (stop_loss > 0) ? stop_loss : 0;
   double use_tp = (take_profit > 0) ? take_profit : 0;
   int use_slippage = (slippage > 0) ? slippage : (int)m_slippage;
   
   if(use_sl == 0 && m_stop_loss > 0)
      use_sl = SymbolInfoDouble(m_symbol, SYMBOL_ASK) + m_stop_loss * Point();
   if(use_tp == 0 && m_take_profit > 0)
      use_tp = SymbolInfoDouble(m_symbol, SYMBOL_ASK) - m_take_profit * Point();
   
   return m_trade.Sell(use_lots, m_symbol, price, use_slippage, use_sl, use_tp, comment);
}

//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
bool EasyExpert::closeAll(void)
{
   if(!m_position_info.SelectByTicket(0)) // Start from first position
   {
      // If no positions found, try to select by symbol
      if(m_position_info.Select(m_symbol))
      {
         do
         {
            if(m_position_info.Magic() == m_magic_number)
            {
               if(!m_trade.PositionClose(m_symbol))
                  return false;
            }
         }
         while(m_position_info.Next());
      }
   }
   else
   {
      // Iterate through all positions for the symbol
      for(int i = 0; i < PositionsTotal(); i++)
      {
         if(m_position_info.SelectByIndex(i))
         {
            if(m_position_info.Symbol() == m_symbol && m_position_info.Magic() == m_magic_number)
            {
               if(!m_trade.PositionClose(m_position_info.Symbol()))
                  return false;
            }
         }
      }
   }
   return true;
}

//+------------------------------------------------------------------+
//| Close positions by symbol                                        |
//+------------------------------------------------------------------+
bool EasyExpert::closeBySymbol(string symbol)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(m_position_info.SelectByIndex(i))
      {
         if(m_position_info.Symbol() == symbol && m_position_info.Magic() == m_magic_number)
         {
            if(!m_trade.PositionClose(m_position_info.Symbol()))
               return false;
         }
      }
   }
   return true;
}

//+------------------------------------------------------------------+
//| Close positions by magic number                                  |
//+------------------------------------------------------------------+
bool EasyExpert::closeByMagic(int magic)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(m_position_info.SelectByIndex(i))
      {
         if(m_position_info.Magic() == magic)
         {
            if(!m_trade.PositionClose(m_position_info.Symbol()))
               return false;
         }
      }
   }
   return true;
}

//+------------------------------------------------------------------+
//| Close specific position                                          |
//+------------------------------------------------------------------+
bool EasyExpert::closePosition(ulong ticket)
{
   if(m_position_info.SelectByTicket(ticket))
   {
      return m_trade.PositionClose(m_position_info.Symbol());
   }
   return false;
}

//+------------------------------------------------------------------+
//| Modify position                                                  |
//+------------------------------------------------------------------+
bool EasyExpert::modifyPosition(ulong ticket, double stop_loss, double take_profit)
{
   if(m_position_info.SelectByTicket(ticket))
   {
      return m_trade.PositionModify(m_position_info.Symbol(), stop_loss, take_profit);
   }
   return false;
}

//+------------------------------------------------------------------+
//| Check if has any position                                        |
//+------------------------------------------------------------------+
bool EasyExpert::hasPosition(void)
{
   return (PositionsTotal() > 0);
}

//+------------------------------------------------------------------+
//| Check if has position by symbol                                  |
//+------------------------------------------------------------------+
bool EasyExpert::hasPositionBySymbol(string symbol)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(m_position_info.SelectByIndex(i))
      {
         if(m_position_info.Symbol() == symbol && m_position_info.Magic() == m_magic_number)
            return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Check if has position by magic number                            |
//+------------------------------------------------------------------+
bool EasyExpert::hasPositionByMagic(int magic)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(m_position_info.SelectByIndex(i))
      {
         if(m_position_info.Magic() == magic)
            return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Get position volume                                              |
//+------------------------------------------------------------------+
double EasyExpert::getPositionVolume(void)
{
   if(m_position_info.Select(m_symbol))
   {
      return m_position_info.Volume();
   }
   return 0.0;
}

//+------------------------------------------------------------------+
//| Get position profit                                              |
//+------------------------------------------------------------------+
double EasyExpert::getPositionProfit(void)
{
   if(m_position_info.Select(m_symbol))
   {
      return m_position_info.Profit();
   }
   return 0.0;
}

//+------------------------------------------------------------------+
//| Get position open price                                          |
//+------------------------------------------------------------------+
double EasyExpert::getPositionOpenPrice(void)
{
   if(m_position_info.Select(m_symbol))
   {
      return m_position_info.PriceOpen();
   }
   return 0.0;
}

//+------------------------------------------------------------------+
//| Get position type                                                |
//+------------------------------------------------------------------+
ENUM_POSITION_TYPE EasyExpert::getPositionType(void)
{
   if(m_position_info.Select(m_symbol))
   {
      return m_position_info.PositionType();
   }
   return POSITION_TYPE_BUY; // Default
}

//+------------------------------------------------------------------+
//| Virtual method: Setup                                            |
//+------------------------------------------------------------------+
bool EasyExpert::onSetup(void)
{
   // Override in derived class
   return true;
}

//+------------------------------------------------------------------+
//| Virtual method: Tick                                             |
//+------------------------------------------------------------------+
void EasyExpert::onTick(void)
{
   // Override in derived class
}

//+------------------------------------------------------------------+
//| Virtual method: Timer                                            |
//+------------------------------------------------------------------+
void EasyExpert::onTimer(void)
{
   // Override in derived class
}

// Global instance pointers for event handling
EasyIndicator* g_indicator_instance = NULL;
EasyExpert* g_expert_instance = NULL;