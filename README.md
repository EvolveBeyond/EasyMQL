# EasyMQL Framework

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MQL5](https://img.shields.io/badge/MQL5-Framework-blue)](https://www.mql5.com)

EasyMQL is a modern, simplified framework for MQL5 that makes creating custom indicators and Expert Advisors much easier while preserving full access to all native MQL5 capabilities.

## 🚀 Features

- **Simple API**: Clean, readable syntax that's easy to understand
- **Modern OOP**: Uses inheritance, virtual methods, and chainable configuration
- **Built-in Helpers**: Common indicators, price access, and utility functions
- **Automatic Event Wiring**: No need to write boilerplate OnInit/OnCalculate code
- **Type Safety**: Enums for readability (Color, DrawType, PriceType, etc.)

## 📁 Structure

```
MQL5/
├── Include/
│   └── EasyMQL/
│       ├── EasyMQL.mqh          # Main include file (only this one is used in projects)
│       ├── EasyCore.mqh         # Base classes: EasyIndicator, EasyExpert
│       ├── EasyHelpers.mqh      # Helper functions: price(), sma(), log(), drawText(), etc.
│       └── EasyConfig.mqh       # Enums: DrawType, Color, PriceType, OrderType
├── Examples/
│   ├── SimpleMAExample.mq5      # Simple moving average indicator example
│   └── SimpleMACrossEA.mq5      # Moving average crossover Expert Advisor example
└── README.md                    # Framework documentation
```

## 🛠️ Installation

1. Download this repository
2. Copy the entire MQL5 folder to your MetaTrader 5 Data Folder:
   - Windows: `C:\Users\[YourUsername]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\`
   - Or find your MT5 Data Folder via: File → Open Data Folder
3. Restart MetaTrader 5
4. The EasyMQL framework will be available for use in your indicators and Expert Advisors

## 📚 Usage Examples

### Creating a Custom Indicator

```mql5
#include <EasyMQL/EasyMQL.mqh>

class SimpleMAExample : public EasyIndicator
{
private:
   int m_period;

public:
   SimpleMAExample(void) { m_period = 14; }
   
   virtual bool onSetup(void)
   {
      setTitle("Simple MA Example")
         .addBuffer(Line, clrBlue, 2, "MA");
      return true;
   }
   
   virtual bool onUpdate(int total, int prev)
   {
      for(int i = m_period; i < total; i++)
      {
         double sum = 0.0;
         for(int j = 0; j < m_period; j++)
         {
            sum += EasyHelpers::close(i + j);
         }
         setBufferValue(0, i, sum / m_period);
      }
      return true;
   }
};
```

### Creating an Expert Advisor

```mql5
#include <EasyMQL/EasyMQL.mqh>

class SimpleMACrossEA : public EasyExpert
{
public:
   virtual bool onSetup(void)
   {
      setLots(0.1).setStopLoss(100).setTakeProfit(200);
      return true;
   }
   
   virtual void onTick(void)
   {
      // Trading logic here
      if(/* buy condition */)
      {
         openBuy(0.1);
      }
   }
};
```

## 🧩 Key Components

### EasyIndicator
- Base class for custom indicators
- Chainable configuration methods
- Automatic buffer management
- Clean event handling

### EasyExpert
- Base class for Expert Advisors
- Simplified order management
- Position tracking utilities
- Error handling built-in

### EasyHelpers
- Common technical indicators (SMA, EMA, RSI, MACD, etc.)
- Price access utilities
- Drawing helpers
- Logging functions
- Math utilities

## 📖 Available Helper Functions

### Price Access
- `EasyHelpers::close(shift)` - Get close price
- `EasyHelpers::high(shift)` - Get high price
- `EasyHelpers::low(shift)` - Get low price
- `EasyHelpers::open(shift)` - Get open price

### Common Indicators
- `EasyHelpers::sma(source, period, result)` - Simple Moving Average
- `EasyHelpers::ema(source, period, result)` - Exponential Moving Average
- `EasyHelpers::rsi(source, period, result)` - Relative Strength Index
- `EasyHelpers::macd(source, fast, slow, signal, macd_line, signal_line, histogram)` - MACD

### Trading Functions
- `openBuy(lots)` - Open buy position
- `openSell(lots)` - Open sell position
- `closeAll()` - Close all positions
- `hasPosition()` - Check if there are open positions

### Enums
- `DrawType`: Line, Histogram, Arrow, Dots, etc.
- `Color`: Red, Green, Blue, Yellow, etc.
- `PriceType`: Open, High, Low, Close, etc.
- `OrderType`: Buy, Sell, BuyLimit, etc.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📞 Contact

EasyMQL Team - info@easymql.com

Project Link: [https://github.com/EvolveBeyond/EasyMQL](https://github.com/EvolveBeyond/EasyMQL)

## 🙏 Acknowledgments

- MQL5 Community for inspiration and feedback
- MetaQuotes for the MQL5 platform
- All contributors who help make this framework better