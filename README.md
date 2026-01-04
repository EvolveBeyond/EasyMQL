# EasyMQL Framework

A lightweight library for simplifying indicator and EA development in MetaTrader 5, inspired by the simplicity of Python/FastAPI, the lightness of Lua, and the modularity of TypeScript/NestJS.

## Features

### 1. Auto-Registration with Macros
- `EASY_INDICATOR(ClassName)` - Automatic indicator registration
- `EASY_EXPERT(ClassName)` - Automatic EA registration
- No need for manual OnInit/OnDeinit/OnCalculate boilerplate

### 2. Chainable (Fluent) API
- Method chaining for clean, readable code
- All setters return `*this` for chaining

### 3. Python-like Price Macros
- `O(n)` - Open price at shift n
- `H(n)` - High price at shift n  
- `L(n)` - Low price at shift n
- `C(n)` - Close price at shift n
- `MA(n, m)` - Moving average with period n at shift m

### 4. Typed Configuration with Validation
- Parameter validation with range checks
- Required field validation
- Error logging for validation failures

### 5. Lightweight Service Access
- `EasyServices::Config()` - Global config access
- `EasyServices::Events()` - Event manager access

### 6. Multi-Strategy Support
- Strategy-based architecture
- Register multiple strategies with `.Use()` method
- Automatic execution in onTick/onTimer

## Usage Examples

### Simple Indicator
```mql5
class SimpleMA : public EasyIndicator
{
public:
   bool onSetup()
   {
      setTitle("Simple MA")
         .addBuffer(Line, Blue, 1, "SMA");
      return true;
   }
   
   bool onUpdate(int total, int prev)
   {
      // Use Python-like macros: O(0), H(0), L(0), C(0)
      double ma_value = MA(14, 0);  // MA period 14, current bar
      return true;
   }
};

EASY_INDICATOR(SimpleMA)  // Auto-registration
```

### Simple EA with Strategy
```mql5
class MATradingStrategy : public EasyStrategy
{
public:
   void onTick()
   {
      if(C(0) > MA(14, 0) && C(1) <= MA(14, 1))  // Cross above MA
      {
         if(!hasPositionBySymbol(_Symbol))
            openBuy();
      }
   }
};

class SimpleMAEA : public EasyExpert
{
public:
   bool onSetup()
   {
      setSymbol(_Symbol)
         .Use(new MATradingStrategy());  // Multi-strategy support
         
      // Config validation
      EasyServices::Config()
         .addParamInt("MAPeriod", 14, "MA Period", true, 1, 100)
         .validate();
         
      return true;
   }
};

EASY_EXPERT(SimpleMAEA)  // Auto-registration
```

## Files

- `EasyConfig.mqh` - Configuration management with validation
- `EasyCore.mqh` - Core classes (EasyIndicator, EasyExpert, EasyStrategy)
- `EasyHelpers.mqh` - Helper functions and Python-like macros
- `EasyMQL.mqh` - Auto-registration macros and event handlers

## Installation

Copy the `EasyMQL` folder to your MQL5 Include directory.

## License

Copyright 2026, EvolveBeyond