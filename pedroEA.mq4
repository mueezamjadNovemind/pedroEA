//+------------------------------------------------------------------+
//|                                                      pedroEA.mq4 |
//|                                    Copyright 2023, Novemind inc. |
//|                                         https://www.novemind.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Novemind inc."
#property link      "https://www.novemind.com"
#property version   "1.00"
#property strict
#resource "\\Indicators\\#ChaosArrZZx2v2_Step (2) (1).ex4"
enum enDisplay
  {
   en_lin,  // Display lines
   en_his,  // Display colored bars
   en_all,  // Display colored lines and bars
   en_lid,  // Display lines with dots
   en_hid,  // Display colored bars with dots
   en_ald,  // Display colored lines and bars with dots
   en_dot   // Display dots
  };

sinput string        str1               = "<<<>>> General Settings <<<>>>";             // _
input double         lot_size           = 0.1;                                          // Lot Size
input int            stoploss           = 00;                                           // Stoploss(Pips) 0 means no SL
input int            takeProfit         = 00;                                           // TakeProfit(Pips) 0 means no TP
input int            magic_no           = 1212;                                         // Magic Number


sinput string        str2               = " <><><><> Indicator Settings <><><><>"; //__
input string         title0             = "==========";  // Arrow setting
input color          upArrColor         = clrBlue;       // Up arrow color
input color          dnArrColor         = clrRed;        // Down arrow color
input int            upArrCode          = 217;           // Up arrow code
input int            dnArrCode          = 218;           // Down arrow code
input int            arrowSize          = 5;             // Arrow size
input string         title1             = "==========";  // == Chaos ArrZZx2 setting ==
input bool           swChao             = true;          // Show Chao ArrZZx2
input int            SRZZ               = 60;
input string         title2             = "==========";  //== Step one more average setting ==
input bool           swInd2             = true;          //Show 'Step one more average'
input int            _OmaLength         = 25;            // Oma Length
input double         _OmaSpeed          = 2.5;           // Oma Speed
input bool           OmaAdaptive        = true;          // Use Oma Adaptive true or false
input double         Sensitivity        = 0.6;           // Sensivity Factor
input int            StepSize           = 50;            // Step Size period
input bool           HighLow            = false;         // High/Low Mode Switch (more sensitive)
input double         Filter             = 0;             // Filter to use for filtering (<=0 - no filtering)
input int            FilterPeriod       = 0;             // Filter period to use ( when <= 0, same as oma period)
input enDisplay      DisplayType        = en_lid;        // Display type
input int            LinesWidth         = 3;             // Lines width (when lines are included in display)
input int            BarsWidth          = 1;             // Bars width (when bars are included in display)
input double         UpPips             = 0;             // Upper band in pips (<= 0 - no band)
input double         DnPips             = 0;             // Lower band in pips (<= 0 - no band)
input int            ArrowCodeUp        = 159;           // Up Arrow code
input int            ArrowCodeDn        = 159;           // Down Arrow code
input double         ArrowGapUp         = 0.5;           // Gap for arrow up
input double         ArrowGapDn         = 0.5;           // Gap for arrow down
input int            ArrowSizeUp        = 2;             // Up Arrow Size
input int            ArrowSizeDn        = 2;             // Down Arrow Size
input bool           ArrowOnFirst       = true;          // Arrow on first bars
input int            stShift            = 0;             // Average shift
input string         title3             = "==========";  // Alert setting
input bool           AlertSwitch        = true;          // Turn alerts on?
input bool           PopupAlert         = true;          // Alerts should display messages?
input bool           SoundAlert         = true;          // Alerts should play sound?
input bool           MailAlert          = true;          // Alerts should send email?
input bool           MobileAlert        = true;          // Alerts should send notification?
input string         AlertSoundFile     = "alert.wav";
input string         AlertMsgTitle      = "ArrZZx2+Step";// Alert message prefix
input int            nBarMax            = 3000;          // Maximum bars to calculate

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(newBar())
     {
      double buyArrow = iCustom(Symbol(),PERIOD_CURRENT,"::Indicators\\#ChaosArrZZx2v2_Step (2) (1).ex4",title0,upArrColor,
                                dnArrColor,upArrCode,dnArrCode,arrowSize,title1,swChao,SRZZ,title2,swInd2,_OmaLength,_OmaSpeed,
                                OmaAdaptive,Sensitivity,StepSize,HighLow,Filter,FilterPeriod,DisplayType,LinesWidth,BarsWidth,
                                UpPips,DnPips,ArrowCodeUp,ArrowCodeDn,ArrowGapUp,ArrowGapDn,ArrowSizeUp,ArrowSizeDn,ArrowOnFirst,
                                stShift,title3,AlertSwitch,PopupAlert,SoundAlert,MailAlert,MobileAlert,AlertSoundFile,
                                AlertMsgTitle,nBarMax,18,1);

      double sellArrow = iCustom(Symbol(),PERIOD_CURRENT,"::Indicators\\#ChaosArrZZx2v2_Step (2) (1).ex4",title0,upArrColor,
                                 dnArrColor,upArrCode,dnArrCode,arrowSize,title1,swChao,SRZZ,title2,swInd2,_OmaLength,_OmaSpeed,
                                 OmaAdaptive,Sensitivity,StepSize,HighLow,Filter,FilterPeriod,DisplayType,LinesWidth,BarsWidth,
                                 UpPips,DnPips,ArrowCodeUp,ArrowCodeDn,ArrowGapUp,ArrowGapDn,ArrowSizeUp,ArrowSizeDn,ArrowOnFirst,
                                 stShift,title3,AlertSwitch,PopupAlert,SoundAlert,MailAlert,MobileAlert,AlertSoundFile,
                                 AlertMsgTitle,nBarMax,19,1);

      if(buyArrow!= EMPTY_VALUE && buyArrow != 0)
        {
         Print("Buy Arrow: ",buyArrow);
         placeBuyTrades();
        }
      if(sellArrow!= EMPTY_VALUE && sellArrow != 0)
        {
         Print("Sell Arrow: ",sellArrow);
         placeSellTrades();
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool newBar()
  {
   static datetime lastbar;
   datetime curbar = iTime(Symbol(),PERIOD_CURRENT,0);
   if(lastbar!=curbar)
     {
      lastbar=curbar;
      Print(".... New Bar ....",lastbar);
      return (true);
     }
   else
     {
      return (false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void placeBuyTrades()
  {
   double buy_sl = 0,buy_tp =0;
   if(stoploss != 0)
     {
      buy_sl = Ask - stoploss*10*Point();
     }
   if(takeProfit != 0)
     {
      buy_tp = Ask + takeProfit*10*Point();
     }

   int ticket = OrderSend(Symbol(),OP_BUY,lot_size,Ask,5,buy_sl,buy_tp,"Buy Trade Placed",magic_no,0,clrBlue);
   if(ticket < 0)
     {
      Print("Buy Order Failed ",GetLastError());
     }
   else
     {
      Print("Buy Order Placed Successfully");
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void placeSellTrades()
  {
   double sell_sl = 0,sell_tp=0;
   if(stoploss != 0)
     {
      sell_sl = Bid + stoploss*10*Point();
     }
   if(takeProfit != 0)
     {
      sell_tp = Bid - takeProfit*10*Point();
     }
   int ticket = OrderSend(Symbol(),OP_SELL,lot_size,Bid,5,sell_sl,sell_tp,"Sell Trade Placed",magic_no,0,clrRed);
   if(ticket < 0)
     {
      Print("Sell Order Failed ",GetLastError());
     }
   else
     {
      Print("Sell Order Placed Successfully");
     }
  }
//+------------------------------------------------------------------+
