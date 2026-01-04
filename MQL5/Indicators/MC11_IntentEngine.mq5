//+------------------------------------------------------------------+
//|                                    MC11 Institutional Intent Engine |
//|                                    Copyright 2026, EvolveBeyond  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, EvolveBeyond"
#property link      "https://www.mql5.com"
#property version   "2.00"
#property indicator_separate_window
#property indicator_buffers 6  // Increased for better visualization
#property indicator_plots   5   // 2 histograms + 3 levels + 1 zero line

//--- Visual Enhancement: Colored Histogram for Bullish/Bearish Intent
#property indicator_label1  "Bullish Intent"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

#property indicator_label2  "Bearish Intent"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3

//--- Visual Enhancement: Horizontal Levels
#property indicator_label3  "Zero Line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrWhite
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

#property indicator_label4  "±25 Level"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_style4  STYLE_DOT
#property indicator_width4  1

#property indicator_label5  "±50 Level"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrSilver
#property indicator_style5  STYLE_DASH
#property indicator_width5  1

//--- Input parameters for customization
input int InpPeriod = 14;
input double InpDeviation = 2.0;
input bool ShowMainChartSignals = true;  // Toggle for chart arrows/signals

#include <EasyMQL/EasyMQL.mqh>

// Main indicator class with enhanced visualization
class MC11Intent : public EasyIndicator {
private:
   // Visual buffers for enhanced display
   double BullishBuffer[];     // Positive values (green histogram)
   double BearishBuffer[];     // Negative values (red histogram)
   double ZeroLevel[];         // Zero reference line
   double Level25Pos[];        // +25 level
   double Level25Neg[];        // -25 level
   double Level50Pos[];        // +50 level
   double Level50Neg[];        // -50 level
   
   // Score components (keeping original logic)
   double microScore;
   double selfScore;
   double aggregatedChildScore;
   double realVolumeIntent;
   double finalScore;
   
   // Object counter for chart signals
   int objectCounter;
   string objectPrefix;
   
   // Synthetic candle data for 1-second processing
   struct SyntheticCandle {
      double open;
      double high;
      double low;
      double close;
      double volume;
      datetime time;
      bool initialized;
   };
   
   SyntheticCandle currentSecondCandle;
   int syntheticCount;
   datetime lastSecondProcessed;
   
   // Tick data buffer for synthetic candles
   MqlTick ticksBuffer[];
   
   // Arrays for price data
   double open_array[];
   double high_array[];
   double low_array[];
   double close_array[];
   double volume_array[];

public:
   // Constructor
   MC11Intent() {
      syntheticCount = 0;
      lastSecondProcessed = 0;
      objectCounter = 0;
      objectPrefix = "MC11_Intent_";
      
      // Initialize scores
      microScore = 0.0;
      selfScore = 0.0;
      aggregatedChildScore = 0.0;
      realVolumeIntent = 0.0;
      finalScore = 0.0;
      
      // Initialize synthetic candle
      currentSecondCandle.initialized = false;
      currentSecondCandle.open = 0.0;
      currentSecondCandle.high = 0.0;
      currentSecondCandle.low = 0.0;
      currentSecondCandle.close = 0.0;
      currentSecondCandle.volume = 0.0;
      currentSecondCandle.time = 0;
   }

   // Setup method with enhanced visual configuration
   bool onSetup() {
      // Set up indicator properties using fluent API
      setTitle("MC11 Intent Engine")  // Short, trader-friendly name
         .addBuffer(Histogram, Green, 3, "Bullish Intent")    // Green histogram for positive values
         .addBuffer(Histogram, Red, 3, "Bearish Intent")      // Red histogram for negative values
         .addBuffer(Line, White, 2, "Zero Line")              // Zero reference line
         .addBuffer(Line, Gray, 1, "+25 Level")               // Positive 25 level
         .addBuffer(Line, Gray, 1, "-25 Level");              // Negative 25 level
      
      // Register all indicator buffers with proper properties
      if(!RegisterBuffers()) return false;
      
      // Set additional visual properties
      IndicatorSetInteger(INDICATOR_DIGITS, 1);  // One decimal place for cleaner display
      IndicatorSetInteger(INDICATOR_HEIGHT, 100); // Set reasonable height
      IndicatorSetInteger(INDICATOR_MINIMUM, -100);
      IndicatorSetInteger(INDICATOR_MAXIMUM, 100);
      
      // Initialize buffers
      ArrayInitialize(BullishBuffer, 0.0);
      ArrayInitialize(BearishBuffer, 0.0);
      ArrayInitialize(ZeroLevel, 0.0);
      ArrayInitialize(Level25Pos, 25.0);
      ArrayInitialize(Level25Neg, -25.0);
      ArrayInitialize(Level50Pos, 50.0);
      ArrayInitialize(Level50Neg, -50.0);
      
      // Initialize tick buffer
      ArrayResize(ticksBuffer, 1000);
      
      return true;
   }

   // Update method with enhanced visualization
   bool onUpdate(int total, int prev) {
      // Only calculate for valid bars
      if(total <= 0) return false;
      
      // Set arrays as series for proper indexing
      ArraySetAsSeries(BullishBuffer, true);
      ArraySetAsSeries(BearishBuffer, true);
      ArraySetAsSeries(ZeroLevel, true);
      ArraySetAsSeries(Level25Pos, true);
      ArraySetAsSeries(Level25Neg, true);
      ArraySetAsSeries(Level50Pos, true);
      ArraySetAsSeries(Level50Neg, true);
      
      // Calculate scores for each bar
      for(int i = 0; i < total; i++) {
         // Calculate all score components (preserving original logic)
         double microScore = CalculateMicroScore();
         double selfScore = CalculateSelfScore();
         double aggregatedChildScore = CalculateAggregatedChildScore();
         double realVolumeIntent = CalculateRealVolumeIntent();
         
         // Calculate final score using weighted average
         double finalScore = (0.4 * selfScore) + (0.4 * aggregatedChildScore) + (0.2 * realVolumeIntent);
         finalScore = MathMax(-100.0, MathMin(100.0, finalScore));
         
         // Enhanced visualization: Separate positive and negative values
         if(finalScore > 0) {
            BullishBuffer[i] = finalScore;  // Show positive values in green histogram
            BearishBuffer[i] = 0.0;         // Hide negative values
         } else {
            BullishBuffer[i] = 0.0;         // Hide positive values
            BearishBuffer[i] = finalScore;  // Show negative values in red histogram
         }
         
         // Set level values (these remain constant)
         ZeroLevel[i] = 0.0;
         Level25Pos[i] = 25.0;
         Level25Neg[i] = -25.0;
         Level50Pos[i] = 50.0;
         Level50Neg[i] = -50.0;
         
         // Optional: Add signals on main chart for extreme values
         if(ShowMainChartSignals && i == 0) {  // Only for current bar
            HandleExtremeSignals(finalScore, i);
         }
      }
      
      return true;
   }

   // Cleanup method
   void onCleanup() {
      // Clean up chart objects
      for(int i = 0; i < 1000; i++) {
         string objName = objectPrefix + IntegerToString(i);
         if(ObjectFind(0, objName) >= 0) {
            ObjectDelete(0, objName);
         }
      }
   }

private:
   // Enhanced signal handling for extreme values
   void HandleExtremeSignals(double score, int barIndex) {
      datetime barTime = iTime(_Symbol, PERIOD_CURRENT, barIndex);
      double price = (H(barIndex) + L(barIndex)) / 2.0;  // Mid-price for signal placement
      
      // Clear previous signals
      string bullSignal = objectPrefix + "BullSig_" + IntegerToString(barIndex);
      string bearSignal = objectPrefix + "BearSig_" + IntegerToString(barIndex);
      
      if(ObjectFind(0, bullSignal) >= 0) ObjectDelete(0, bullSignal);
      if(ObjectFind(0, bearSignal) >= 0) ObjectDelete(0, bearSignal);
      
      // Add signals for extreme bullish intent
      if(score > 75.0) {
         ObjectCreate(0, bullSignal, OBJ_ARROW_BUY, 0, barTime, price - 10 * _Point);
         ObjectSetInteger(0, bullSignal, OBJPROP_COLOR, clrLime);
         ObjectSetInteger(0, bullSignal, OBJPROP_WIDTH, 3);
         
         // Add text label
         string labelText = objectPrefix + "BullText_" + IntegerToString(barIndex);
         ObjectCreate(0, labelText, OBJ_TEXT, 0, barTime, price + 20 * _Point);
         ObjectSetString(0, labelText, OBJPROP_TEXT, "STRONG BULLISH INTENT");
         ObjectSetInteger(0, labelText, OBJPROP_COLOR, clrLime);
         ObjectSetInteger(0, labelText, OBJPROP_FONTSIZE, 10);
      }
      // Add signals for extreme bearish intent
      else if(score < -75.0) {
         ObjectCreate(0, bearSignal, OBJ_ARROW_SELL, 0, barTime, price + 10 * _Point);
         ObjectSetInteger(0, bearSignal, OBJPROP_COLOR, clrRed);
         ObjectSetInteger(0, bearSignal, OBJPROP_WIDTH, 3);
         
         // Add text label
         string labelText = objectPrefix + "BearText_" + IntegerToString(barIndex);
         ObjectCreate(0, labelText, OBJ_TEXT, 0, barTime, price - 30 * _Point);
         ObjectSetString(0, labelText, OBJPROP_TEXT, "STRONG BEARISH INTENT");
         ObjectSetInteger(0, labelText, OBJPROP_COLOR, clrRed);
         ObjectSetInteger(0, labelText, OBJPROP_FONTSIZE, 10);
      }
   }

   // Process ticks to build synthetic 1-second candles
   void ProcessTicks() {
      // Get recent ticks
      ArrayResize(ticksBuffer, 1000);
      int ticksCount = CopyTicks(_Symbol, ticksBuffer, COPY_TICKS_ALL, 1000);
      
      if(ticksCount > 0) {
         for(int i = 0; i < ticksCount; i++) {
            MqlTick tick = ticksBuffer[i];
            datetime tickSecond = (datetime)(tick.time_msc / 1000);
            
            // Check if we need to finalize previous second
            if(currentSecondCandle.initialized && tickSecond > currentSecondCandle.time) {
               FinalizeSecondCandle();
            }
            
            // Start new second if needed
            if(!currentSecondCandle.initialized || tickSecond > currentSecondCandle.time) {
               InitializeSyntheticCandle(tickSecond, tick.bid, tick.volume);
            } else {
               UpdateSyntheticCandle(tick);
            }
         }
      }
   }
   
   void InitializeSyntheticCandle(datetime time, double price, long volume) {
      currentSecondCandle.time = time;
      currentSecondCandle.open = price;
      currentSecondCandle.high = price;
      currentSecondCandle.low = price;
      currentSecondCandle.close = price;
      currentSecondCandle.volume = (double)volume;
      currentSecondCandle.initialized = true;
      syntheticCount++;
   }
   
   void UpdateSyntheticCandle(MqlTick &tick) {
      if(currentSecondCandle.initialized) {
         currentSecondCandle.high = MathMax(currentSecondCandle.high, tick.bid);
         currentSecondCandle.low = MathMin(currentSecondCandle.low, tick.bid);
         currentSecondCandle.close = tick.bid;
         currentSecondCandle.volume += (double)tick.volume;
      }
   }
   
   void FinalizeSecondCandle() {
      if(currentSecondCandle.initialized) {
         lastSecondProcessed = currentSecondCandle.time;
         currentSecondCandle.initialized = false;
      }
   }

   // Calculate MicroScore using T1 template (Volume-Price relationship)
   double CalculateMicroScore() {
      double currentPrice = C(0);
      double prevPrice = C(1);
      double currentVolume = (double)Volume[0];
      double prevVolume = (double)Volume[1];
      
      bool priceUp = currentPrice > prevPrice;
      bool volumeUp = currentVolume > prevVolume;
      
      if(priceUp && volumeUp) return 25.0;
      if(!priceUp && !volumeUp) return -25.0;
      if(priceUp && !volumeUp) return 10.0;
      if(!priceUp && volumeUp) return -10.0;
      
      return 0.0;
   }

   // Calculate SelfScore using T2-T4 templates (Price action patterns)
   double CalculateSelfScore() {
      double open = O(0);
      double high = H(0);
      double low = L(0);
      double close = C(0);
      
      // Calculate 4-zone delta
      double zoneRange = (high - low) / 4.0;
      double zone1High = low + zoneRange;
      double zone2High = low + 2*zoneRange;
      double zone3High = low + 3*zoneRange;
      double zone4High = high;
      
      double bodyHigh = MathMax(open, close);
      double bodyLow = MathMin(open, close);
      
      double zone4Dominance = MathMin(bodyHigh, high) - MathMax(bodyLow, zone3High);
      double zone3Dominance = MathMin(bodyHigh, zone3High) - MathMax(bodyLow, zone2High);
      double zone2Dominance = MathMin(bodyHigh, zone2High) - MathMax(bodyLow, zone1High);
      double zone1Dominance = MathMin(bodyHigh, zone1High) - MathMax(bodyLow, low);
      
      double score = 0.0;
      if(zone4Dominance > 0) score += 20.0;
      if(zone1Dominance > 0) score -= 20.0;
      if(zone3Dominance > zone2Dominance) score += 10.0;
      if(zone2Dominance > zone3Dominance) score -= 10.0;
      
      return MathMax(-50.0, MathMin(50.0, score));
   }

   // Calculate AggregatedChildScore using T5-T6 templates
   double CalculateAggregatedChildScore() {
      double currentPrice = C(0);
      double maValue = MA(InpPeriod, 0);
      double maSlope = MA(InpPeriod, 0) - MA(InpPeriod, 1);
      
      double score = 0.0;
      
      if(currentPrice > maValue) score += 15.0;
      else score -= 15.0;
      
      if(maSlope > 0) score += 10.0;
      else score -= 10.0;
      
      return MathMax(-25.0, MathMin(25.0, score));
   }

   // Calculate RealVolumeIntent using T7 template
   double CalculateRealVolumeIntent() {
      double currentVolume = (double)Volume[0];
      double avgVolume = 0.0;
      
      for(int i = 1; i <= 10; i++) {
         avgVolume += (double)Volume[i];
      }
      avgVolume /= 10.0;
      
      if(avgVolume == 0) return 0.0;
      
      double volumeRatio = currentVolume / avgVolume;
      
      if(volumeRatio > 1.5) {
         if(C(0) > C(1)) return 25.0;
         else return -25.0;
      } else if(volumeRatio < 0.7) {
         return 0.0;
      }
      
      return 0.0;
   }
};

// Use the auto-registration macro for clean, modern MQL5 code
EASY_INDICATOR(MC11Intent)