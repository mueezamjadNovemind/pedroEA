//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window
#property indicator_buffers 20
#property indicator_color1  clrBlack
#property indicator_type1   DRAW_ARROW
#property indicator_width1  5
#property indicator_color2  clrNONE
#property indicator_color3  clrBlack
#property indicator_width3  5
#property indicator_type3   DRAW_ARROW
#property indicator_color4  clrBlack
#property indicator_width4  5
#property indicator_type4   DRAW_ARROW
#property indicator_color5  clrBlack
#property indicator_width5  1
#property indicator_type5   DRAW_ARROW
#property indicator_color6  clrBlack
#property indicator_width6  1
#property indicator_type6   DRAW_ARROW
///
#property indicator_color7  clrLimeGreen
#property indicator_color8  clrOrange
#property indicator_color9  clrLimeGreen
#property indicator_color10  clrOrange
#property indicator_color11  clrOrange
#property indicator_color12  clrSilver
#property indicator_color13  clrSilver
#property indicator_color14  clrLimeGreen
#property indicator_color15  clrOrange
#property indicator_style12  STYLE_DOT
#property indicator_style13  STYLE_DOT

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

input string title0="==========";//Arrow setting
input color upArrColor=clrBlue;//Up arrow color
input color dnArrColor=clrRed;//Down arrow color
input int upArrCode=217;//Up arrow code
input int dnArrCode=218;//Down arrow code
input int arrowSize=5;//Arrow size
input string title1="==========";//== Chaos ArrZZx2 setting ==
input bool swChao=true;//Show Chao ArrZZx2
input int  SRZZ = 60;
input string title2="==========";//== Step one more average setting ==
input bool swInd2=true;//Show 'Step one more average'
input int            _OmaLength          = 25;       // Oma Length
input double         _OmaSpeed           = 2.5;      // Oma Speed
input bool           OmaAdaptive        = true;     // Use Oma Adaptive true or false
input double         Sensitivity        = 0.6;      // Sensivity Factor
input int            StepSize           = 50;       // Step Size period
input bool           HighLow            = false;    // High/Low Mode Switch (more sensitive)
input double         Filter             = 0;        // Filter to use for filtering (<=0 - no filtering)
input int            FilterPeriod       = 0;        // Filter period to use ( when <= 0, same as oma period)
input enDisplay      DisplayType        = en_lid;   // Display type
input int            LinesWidth         = 3;        // Lines width (when lines are included in display)
input int            BarsWidth          = 1;        // Bars width (when bars are included in display)
input double         UpPips             = 0;        // Upper band in pips (<= 0 - no band)
input double         DnPips             = 0;        // Lower band in pips (<= 0 - no band)
input int            ArrowCodeUp        = 159;      // Up Arrow code
input int            ArrowCodeDn        = 159;      // Down Arrow code
input double         ArrowGapUp         = 0.5;      // Gap for arrow up
input double         ArrowGapDn         = 0.5;      // Gap for arrow down
input int            ArrowSizeUp        = 2;        // Up Arrow Size
input int            ArrowSizeDn        = 2;        // Down Arrow Size
input bool           ArrowOnFirst       = true;     // Arrow on first bars
input int            stShift              = 0;        // Average shift
input string title3="==========";//Alert setting
input bool AlertSwitch=true;//Turn alerts on?
input bool PopupAlert=true;//Alerts should display messages?
input bool SoundAlert=true;//Alerts should play sound?
input bool MailAlert=true;//Alerts should send email?
input bool MobileAlert=true;//Alerts should send notification?
input string AlertSoundFile="alert.wav";
input string AlertMsgTitle="ArrZZx2+Step";//Alert message prefix
input int nBarMax=3000;//Maximum bars to calculate

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
///Chao
bool useLmt=true;
double pUp[],pDn[],Up[],Dn[],Lmt[],LZZ[];
int MainRZZ=75,FP=21,SMF=3,SR=3;
ENUM_APPLIED_PRICE PriceConst=PRICE_CLOSE;
///Ind2
double histou[];
double histod[];
double LineBuffer[];
double DnBuffera[];
double DnBufferb[];
double bandUp[];
double bandDn[];
double arrowu[];
double arrowd[];
double smin[];
double smax[];
double trend[];
int OmaLength=25;
double OmaSpeed=2.5;
#define filterInstances 2
double workFil[][filterInstances*3];
#define _fchange 0
#define _fachang 1
#define _fprice  2
double stored[][14];
#define E1  0
#define E2  1
#define E3  2
#define E4  3
#define E5  4
#define E6  5
#define res 6
double workStep[][3];
#define _smin   0
#define _smax   1
#define _trend  2
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorIni();
   return(INIT_SUCCEEDED);
  }

double upArr[],dnArr[];
int atrSp_period=50;
double atrSp_multi=1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IndicatorIni()
  {
   IndicatorBuffers(20);
   SetIndexBuffer(0,Lmt);
   SetIndexStyle(0,swChao?DRAW_ARROW:DRAW_NONE,6);
   SetIndexArrow(0,164);
   SetIndexBuffer(1,LZZ);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(2,Up);
   SetIndexStyle(2,swChao?DRAW_ARROW:DRAW_NONE);
   SetIndexArrow(2,164);
   SetIndexBuffer(3,Dn);
   SetIndexStyle(3,swChao?DRAW_ARROW:DRAW_NONE);
   SetIndexArrow(3,164);
   SetIndexBuffer(4,pUp);
   SetIndexStyle(4,swChao?DRAW_ARROW:DRAW_NONE);
   SetIndexArrow(4,216);
   SetIndexBuffer(5,pDn);
   SetIndexStyle(5,swChao?DRAW_ARROW:DRAW_NONE);
   SetIndexArrow(5,216);
///
   int lstyle = DRAW_LINE;
   if(DisplayType==en_his || DisplayType==en_hid || DisplayType==en_dot)
      lstyle = DRAW_NONE;
   int hstyle = DRAW_HISTOGRAM;
   if(DisplayType==en_lin || DisplayType==en_lid || DisplayType==en_dot)
      hstyle = DRAW_NONE;
   int astyle = DRAW_ARROW;
   if(DisplayType<en_lid)
      astyle = DRAW_NONE;
   SetIndexBuffer(6, histou);
   SetIndexStyle(6,hstyle,EMPTY,BarsWidth);
   SetIndexBuffer(7, histod);
   SetIndexStyle(7,swInd2?hstyle:DRAW_NONE,EMPTY,BarsWidth);
   SetIndexBuffer(8, LineBuffer);
   SetIndexStyle(8,swInd2?lstyle:DRAW_NONE,EMPTY,LinesWidth);
   SetIndexBuffer(9, DnBuffera);
   SetIndexStyle(9,swInd2?lstyle:DRAW_NONE,EMPTY,LinesWidth);
   SetIndexBuffer(10, DnBufferb);
   SetIndexStyle(10,swInd2?lstyle:DRAW_NONE,EMPTY,LinesWidth);
   SetIndexBuffer(11, bandUp);
   SetIndexBuffer(12, bandDn);
   SetIndexBuffer(13, arrowu);
   SetIndexStyle(13,swInd2?astyle:DRAW_NONE,0,ArrowSizeUp);
   SetIndexArrow(13,ArrowCodeUp);
   SetIndexBuffer(14, arrowd);
   SetIndexStyle(14,swInd2?astyle:DRAW_NONE,0,ArrowSizeDn);
   SetIndexArrow(14,ArrowCodeDn);

   SetIndexBuffer(15, smin);
   SetIndexBuffer(16,smax);
   SetIndexBuffer(17,trend);
   OmaLength = MathMax(_OmaLength,   1);
   OmaSpeed  = MathMax(_OmaSpeed,-1.5);
////
   int iBc=18;
   SetIndexBuffer(iBc,upArr);
   SetIndexStyle(iBc,DRAW_ARROW,STYLE_SOLID,arrowSize,upArrColor);
   SetIndexArrow(iBc,upArrCode);
   iBc++;
   SetIndexBuffer(iBc,dnArr);
   SetIndexStyle(iBc,DRAW_ARROW,STYLE_SOLID,arrowSize,dnArrColor);
   SetIndexArrow(iBc,dnArrCode);
   iBc++;
///
///
   if(SR < 2)
      SR = 2;
///
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrayIni(bool noObjPurge=false)
  {
   double iniValue=0;
   ArraySetAsSeries(Lmt,true);
   ArrayInitialize(Lmt,iniValue);
   ArraySetAsSeries(LZZ,true);
   ArrayInitialize(LZZ,iniValue);
   ArraySetAsSeries(Up,true);
   ArrayInitialize(Up,iniValue);
   ArraySetAsSeries(Dn,true);
   ArrayInitialize(Dn,iniValue);
   ArraySetAsSeries(pUp,true);
   ArrayInitialize(pUp,iniValue);
   ArraySetAsSeries(pDn,true);
   ArrayInitialize(pDn,iniValue);
   ArraySetAsSeries(upArr,true);
   ArrayInitialize(upArr,EMPTY_VALUE);
   ArraySetAsSeries(dnArr,true);
   ArrayInitialize(dnArr,EMPTY_VALUE);
//
   ArraySetAsSeries(histou,true);
   ArrayInitialize(histou,iniValue);
   ArraySetAsSeries(histod,true);
   ArrayInitialize(histod,iniValue);
   ArraySetAsSeries(LineBuffer,true);
   ArrayInitialize(LineBuffer,iniValue);
   ArraySetAsSeries(DnBuffera,true);
   ArrayInitialize(DnBuffera,iniValue);
   ArraySetAsSeries(DnBufferb,true);
   ArrayInitialize(DnBufferb,iniValue);
   ArraySetAsSeries(bandUp,true);
   ArrayInitialize(bandUp,iniValue);
   ArraySetAsSeries(bandDn,true);
   ArrayInitialize(bandDn,iniValue);
   ArraySetAsSeries(arrowu,true);
   ArrayInitialize(arrowu,iniValue);
   ArraySetAsSeries(arrowd,true);
   ArrayInitialize(arrowd,iniValue);
   ArraySetAsSeries(smin,true);
   ArrayInitialize(smin,iniValue);
   ArraySetAsSeries(smax,true);
   ArrayInitialize(smax,iniValue);
   ArraySetAsSeries(trend,true);
   ArrayInitialize(trend,iniValue);
//if(!noObjPurge)
//ObjectsDeleteAll(0,strEA+"TL_");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,strEA);
   ChartRedraw();
  }
///
int barMax,sh=50,secTor=60,indC=0,indCMax=1;
datetime dtInd=0,dtCur=0,dtAlertBuy=0,dtAlertSell=0;
string strEA=MQLInfoString(MQL_PROGRAM_NAME);
ENUM_TIMEFRAMES tfCur=PERIOD_CURRENT;
//+------------------------------------------------------------------+
//|                                                                  |
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
///
   int ii=0;
   bool bNewBar=dtInd!=iTime(Symbol(),Period(),0) || prev_calculated==0;
   bool bIndIni=bNewBar;// || TimeCurrent()-dtCur>=secTor || indC<indCMax;
   int _gSz=rates_total,_limit=MathMin(_gSz-50,nBarMax-2);
   if(bIndIni && _limit>50)
     {
      dtCur=TimeCurrent();
      ArrayIni();
      ///
      datetime _time[];
      double _close[],_open[],_high[],_low[];
      ArrayResize(_time,_limit);
      ArrayInitialize(_time,0);
      dArrayIni(_close,_limit);
      dArrayIni(_open,_limit);
      dArrayIni(_high,_limit);
      dArrayIni(_low,_limit);
      for(ii=_limit; ii>=0; ii--)
        {
         if(ii>=_limit-0 || ii>=_gSz-0)
            continue;
         _close[ii]=iClose(Symbol(),tfCur,ii);
         _high[ii]=iHigh(Symbol(),tfCur,ii);
         _low[ii]=iLow(Symbol(),tfCur,ii);
         _open[ii]=iOpen(Symbol(),tfCur,ii);
         _time[ii]=iTime(Symbol(),tfCur,ii);
        }
      //
      double maChao[];
      dArrayIni(maChao,_limit);
      f_wma(_limit,_gSz,_close,SR+1,maChao);
      ///
      double SM[],SA[],hiLmt[],loLmt[];
      dArrayIni(SM,_limit);
      dArrayIni(SA,_limit);
      dArrayIni(hiLmt,_limit);
      dArrayIni(loLmt,_limit);
      for(ii=_limit; ii>=0; ii--)
        {
         if(ii>=_limit-0 || ii>=_gSz-0)
            continue;
         MainCalculation(ii,_limit,_open,_high,_low,_close,SA,SM,maChao);
        }
      double STF[],LTF[];
      dArrayIni(STF,_limit);
      dArrayIni(LTF,_limit);
      SZZCalc(0,_limit,_open,_high,_low,_close,SA,SM,
              pUp,pDn,Up,Dn,Lmt,STF);
      LZZCalc(0,_limit,_open,_high,_low,_close,SA,SM,
              pUp,pDn,Up,Dn,Lmt,LTF,LZZ);
      ArrCalc(_limit,_open,_high,_low,_close,pUp,pDn,Up,Dn,Lmt,LZZ);
      ///
      double _lmtPrev=0;
      for(ii=_limit; ii>=0; ii--)
        {
         if(ii>=_limit-0 || ii>=_gSz-0)
            continue;
         if(Lmt[ii]!=EMPTY_VALUE && Lmt[ii]!=0)
           {
            if(_lmtPrev>0)
              {
               if(Lmt[ii]>_lmtPrev)
                  hiLmt[ii]=Lmt[ii];
               if(Lmt[ii]<_lmtPrev)
                  loLmt[ii]=Lmt[ii];
              }
            _lmtPrev=Lmt[ii];
            continue;
           }
         if(Up[ii]!=EMPTY_VALUE && Up[ii]!=0)
           {
            _lmtPrev=Up[ii];
            continue;
           }
         if(Dn[ii]!=EMPTY_VALUE && Dn[ii]!=0)
           {
            _lmtPrev=Dn[ii];
            continue;
           }
        }
      ///
      int jj=0;
      ArrayResize(workFil,_limit);
      ArrayResize(stored,_limit);
      ArrayResize(workStep,_limit);
      for(ii=_limit; ii>=0; ii--)
        {
         if(ii>=_limit-0 || ii>=_gSz-0)
            continue;
         for(jj=0; jj<filterInstances*3; jj++)
           {
            workFil[ii][jj]=0;
           }
         for(jj=0; jj<14; jj++)
           {
            stored[ii][jj]=0;
           }
         for(jj=0; jj<3; jj++)
           {
            workStep[ii][jj]=0;
           }
        }
      for(ii=_limit; ii>=0; ii--)
        {
         if(ii>=_limit-0 || ii>=_gSz-0)
            continue;
         double thigh=0;
         double tlow=0;
         int fperiod = OmaLength;
         if(FilterPeriod>0)
            fperiod=FilterPeriod;
         if(HighLow)
           {
            thigh=iAverage(_limit,_gSz,iFilter(_limit,_gSz,iHigh(Symbol(),tfCur,ii),Filter,fperiod,ii,0),
                           OmaLength,OmaSpeed,OmaAdaptive,ii,0);
            tlow =
               iAverage(_limit,_gSz,iFilter(_limit,_gSz,iLow(Symbol(),tfCur,ii),Filter,fperiod,ii,0),
                        OmaLength,OmaSpeed,OmaAdaptive,ii,7);
           }
         else
           {
            thigh=iAverage(_limit,_gSz,iFilter(_limit,_gSz,iClose(Symbol(),tfCur,ii),Filter,fperiod,ii,0),
                           OmaLength,OmaSpeed,OmaAdaptive,ii,0);
            tlow =iAverage(_limit,_gSz,iFilter(_limit,_gSz,iClose(Symbol(),tfCur,ii),Filter,fperiod,ii,1),
                           OmaLength,OmaSpeed,OmaAdaptive,ii,7);
           }
         LineBuffer[ii] = iStepMa(_limit,_gSz,Sensitivity,iATR(Symbol(),tfCur,StepSize,ii),1.0,thigh,tlow,iClose(Symbol(),tfCur,ii),ii);
         DnBuffera[ii]  = EMPTY_VALUE;
         DnBufferb[ii]  = EMPTY_VALUE;
         histou[ii]     = EMPTY_VALUE;
         histod[ii]     = EMPTY_VALUE;
         arrowu[ii]     = EMPTY_VALUE;
         arrowd[ii]     = EMPTY_VALUE;
         if(ii<_limit-1 && ii<_gSz-1)
           {
            if(trend[ii]==-1)
               PlotPoint(_limit,_gSz,ii,DnBuffera,DnBufferb,LineBuffer);
            if(trend[ii]==-1)
              {
               histou[ii] = iLow(Symbol(),tfCur,ii);
               histod[ii] = iHigh(Symbol(),tfCur,ii);
              }
            if(trend[ii]== 1)
              {
               histod[ii] = iLow(Symbol(),tfCur,ii);
               histou[ii] = iHigh(Symbol(),tfCur,ii);
              }
            if(UpPips>0)
               bandUp[ii] = LineBuffer[ii]+UpPips*_Point*MathPow(10,_Digits%2);
            if(DnPips>0)
               bandDn[ii] = LineBuffer[ii]-DnPips*_Point*MathPow(10,_Digits%2);
            if(trend[ii]!= trend[ii+1])
              {
               if(trend[ii] ==  1)
                  arrowu[ii] = MathMin(LineBuffer[ii],iLow(Symbol(),tfCur,ii))-iATR(Symbol(),tfCur,15,ii)*ArrowGapUp;
               if(trend[ii] == -1)
                  arrowd[ii] = MathMax(LineBuffer[ii],iHigh(Symbol(),tfCur,ii))+iATR(Symbol(),tfCur,15,ii)*ArrowGapDn;
              }
           }
        }
      //
      datetime dtBuy=0,dtSell=0;
      int chaoBuyK=-1,chaoSellK=-1,chaoSig=0,_lastSig=0;
      bool sigIni=false;
      for(ii=_limit; ii>=0; ii--)
        {
         if(ii>=_limit-1 || ii>=_gSz-1)
            continue;
         upArr[ii]=EMPTY_VALUE;
         dnArr[ii]=EMPTY_VALUE;
         if((Up[ii]!=0 && Up[ii]!=EMPTY_VALUE) ||
            (useLmt && loLmt[ii]>0))
           { chaoSig=1; chaoBuyK=ii; sigIni=true; }
         if((Dn[ii]!=0 && Dn[ii]!=EMPTY_VALUE) ||
            (useLmt && hiLmt[ii]>0))
           { chaoSig=-1; chaoSellK=ii; sigIni=true; }
         if(chaoSig==1 && sigIni &&
            arrowu[ii]>0 && arrowu[ii]!=EMPTY_VALUE)
           {
            _lastSig=1;
            sigIni=false;
            dtBuy=iTime(Symbol(),tfCur,ii);
            upArr[ii]=_low[ii]-iATR(Symbol(),Period(),atrSp_period,ii)*atrSp_multi;
           }
         if(chaoSig==-1 && sigIni &&
            arrowd[ii]>0 && arrowd[ii]!=EMPTY_VALUE)
           {
            _lastSig=-1;
            sigIni=false;
            dtSell=iTime(Symbol(),tfCur,ii);
            dnArr[ii]=_high[ii]+iATR(Symbol(),Period(),atrSp_period,ii)*atrSp_multi;
           }
        }
      ///
      if(chaoSig==1 && dtAlertBuy>0 && dtBuy>dtAlertBuy && indC>=indCMax)
        {
         AlertMessageSp(AlertMsgTitle+" UP signal - "+Symbol()+"_"+PeriodToString(Period()));
        }
      if(chaoSig==-1 && dtAlertSell>0 && dtSell>dtAlertSell && indC>=indCMax)
        {
         AlertMessageSp(AlertMsgTitle+" DOWN signal - "+Symbol()+"_"+PeriodToString(Period()));
        }
      dtAlertBuy=MathMax(dtAlertBuy,dtBuy);
      dtAlertSell=MathMax(dtAlertSell,dtSell);
     }
   indC++;
   dtInd=iTime(Symbol(),Period(),0);
///
   ChartRedraw();
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iFilter(int _limit,int _gSz,double tprice, double filter, int period, int i, int instanceNo=0)
  {
   if(filter<=0 || period==0)
      return(tprice);
   instanceNo*=3;
   workFil[i][instanceNo+_fprice]  = tprice;
   if(i<1)
      return(tprice);
   workFil[i][instanceNo+_fchange] = i+1>=_limit?0:MathAbs(workFil[i][instanceNo+_fprice]-workFil[i+1][instanceNo+_fprice]);
   workFil[i][instanceNo+_fachang] = workFil[i][instanceNo+_fchange];
   int k=0;
   for(k=1; k<period; k++)
      workFil[i][instanceNo+_fachang] += i+k>=_limit?0:workFil[i+k][instanceNo+_fchange];

   workFil[i][instanceNo+_fachang] /= period;
   double stddev = 0;
   for(k=0;  k<period && (i-k)>=0; k++)
      stddev += (i+k)>=_limit?0:MathPow(workFil[i+k][instanceNo+_fchange]-workFil[i+k][instanceNo+_fachang],2);
   stddev = MathSqrt(stddev/(double)period);
   double filtev = filter * stddev;
   if(i+1<_limit && MathAbs(workFil[i][instanceNo+_fprice]-workFil[i+1][instanceNo+_fprice]) < filtev)
      workFil[i][instanceNo+_fprice]=workFil[i+1][instanceNo+_fprice];
   return(workFil[i][instanceNo+_fprice]);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iAverage(int _limit,int _gSz,double price, double averagePeriod, double tconst, bool adaptive, int i, int ashift=0)
  {
   if(averagePeriod <=1)
      return(price);
   int r = i;
   double e1=r+1>=_limit?0:stored[r+1][E1+ashift];
   double e2=r+1>=_limit?0:stored[r+1][E2+ashift];
   double e3=r+1>=_limit?0:stored[r+1][E3+ashift];
   double e4=r+1>=_limit?0:stored[r+1][E4+ashift];
   double e5=r+1>=_limit?0:stored[r+1][E5+ashift];
   double e6=r+1>=_limit?0:stored[r+1][E6+ashift];
   if(adaptive && (averagePeriod > 1))
     {
      double minPeriod = averagePeriod/2.0;
      double maxPeriod = minPeriod*5.0;
      int    endPeriod = (int)MathCeil(maxPeriod);
      double tsignal   = r+endPeriod>=_limit?0:MathAbs((price-stored[r+endPeriod][res+ashift]));
      double noise     = 0.00000000001;

      for(int k=1; k<endPeriod; k++)
         noise=r+k>=_limit?0:noise+MathAbs(price-stored[r+k][res+ashift]);
      averagePeriod = noise==0?0:((tsignal/noise)*(maxPeriod-minPeriod))+minPeriod;
     }
   double _div=(1.0+tconst+averagePeriod);
   double alpha = _div==0?0:(2.0+tconst)/_div;
   e1 = e1 + alpha*(price-e1);
   e2 = e2 + alpha*(e1-e2);
   double v1 = 1.5 * e1 - 0.5 * e2;
   e3 = e3 + alpha*(v1   -e3);
   e4 = e4 + alpha*(e3-e4);
   double v2 = 1.5 * e3 - 0.5 * e4;
   e5 = e5 + alpha*(v2   -e5);
   e6 = e6 + alpha*(e5-e6);
   double v3 = 1.5 * e5 - 0.5 * e6;
   stored[r][E1+ashift]  = e1;
   stored[r][E2+ashift] = e2;
   stored[r][E3+ashift]  = e3;
   stored[r][E4+ashift] = e4;
   stored[r][E5+ashift]  = e5;
   stored[r][E6+ashift] = e6;
   stored[r][res+ashift] = price;
   return(v3);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iStepMa(int _limit,int _gSz,double sensitivity, double stepSize, double stepMulti, double phigh, double plow, double pprice, int r)
  {
   if(sensitivity == 0)
      sensitivity = 0.0001;
   if(stepSize    == 0)
      stepSize    = 0.0001;
   double result=0;
   double size = sensitivity*stepSize;
   if(r==_limit-1)
     {
      workStep[r][_smax]  = phigh+2.0*size*stepMulti;
      workStep[r][_smin]  = plow -2.0*size*stepMulti;
      workStep[r][_trend] = 0;
      return(pprice);
     }
   workStep[r][_smax]  = phigh+2.0*size*stepMulti;
   workStep[r][_smin]  = plow -2.0*size*stepMulti;
   workStep[r][_trend] = r+1>=_limit?0:workStep[r+1][_trend];
   if(r+1<_limit && pprice>workStep[r+1][_smax])
      workStep[r][_trend] =  1;
   if(pprice<workStep[r+1][_smin])
      workStep[r][_trend] = -1;
   if(workStep[r][_trend] ==  1)
     {
      if(r+1<_limit && workStep[r][_smin] < workStep[r+1][_smin])
         workStep[r][_smin]=workStep[r+1][_smin];
      result = workStep[r][_smin]+size*stepMulti;
     }
   if(workStep[r][_trend] == -1)
     {
      if(r+1<_limit && workStep[r][_smax] > workStep[r+1][_smax])
         workStep[r][_smax]=workStep[r+1][_smax];
      result = workStep[r][_smax]-size*stepMulti;
     }
   trend[r] = workStep[r][_trend];
   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PlotPoint(int _limit,int _gSz,int i,double& first[],double& second[],double& from[])
  {
   if(i<_limit-2 && i<_gSz-2 &&
      first[i+1] == EMPTY_VALUE)
     {
      if(first[i+2] == EMPTY_VALUE)
        {
         first[i]   = from[i];
         first[i+1] = from[i+1];
         second[i]  = EMPTY_VALUE;
        }
      else
        {
         second[i]   =  from[i];
         second[i+1] =  from[i+1];
         first[i]    = EMPTY_VALUE;
        }
     }
   else
     {
      first[i]  = from[i];
      second[i] = EMPTY_VALUE;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void dArrayIni(double& _src[],int _limit)
  {
   ArrayResize(_src,_limit);
   ArrayInitialize(_src,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrCalc(int _limit,
             double& _Open[],double& _High[],double& _Low[],double& _Close[],
             double& _pUp[],double& _pDn[],double& _Up[],double& _Dn[],
             double& _Lmt[],double& _LZZ[])
  {
   int i, j, k, n, z = 0;
   double p;
   i = _limit-1;
   while(_LZZ[i] == 0 && i>=0)
      i--;
   j = i;
   p = _LZZ[i];
   i--;
   while(_LZZ[i] == 0 && i>=0)
      i--;
   if(_LZZ[i] > p)
      z = 1;
   if((_LZZ[i] > 0) && (_LZZ[i] < p))
      z = -1;
   p = _LZZ[j];
   i = j - 1;
   while(i > 0)
     {
      if(_LZZ[i] > p)
        {
         z = -1;
         p = _LZZ[i];
        }
      if((_LZZ[i] > 0) && (_LZZ[i] < p))
        {
         z = 1;
         p = _LZZ[i];
        }
      if((z > 0) && (_Dn[i] > 0))
        {
         _Lmt[i] = _Open[i];
         _Dn[i] = 0;
        }
      if((z < 0) && (_Up[i] > 0))
        {
         _Lmt[i] = _Open[i];
         _Up[i] = 0;
        }
      if((z > 0) && (_Up[i] > 0))
        {
         if(i > 1)
           {
            j = i - 1;
            k = j - SRZZ + 1;
            if(k < 0)
               k = 0;
            n = j;
            while((n >= k) && (_Dn[n] == 0))
              {
               _pUp[n] = _Up[i];
               _pDn[n] = 0;
               n--;
              }
           }
         if(i == 1)
            _pUp[0] = _Up[i];
        }
      if((z < 0) && (_Dn[i] > 0))
        {
         if(i > 1)
           {
            j = i - 1;
            k = j - SRZZ + 1;
            if(k < 0)
               k = 0;
            n = j;
            while((n >= k) && (_Up[n] == 0))
              {
               _pDn[n] = _Dn[i];
               _pUp[n] = 0;
               n--;
              }
           }
         if(i == 1)
            _pDn[0] = _Dn[i];
        }
      i--;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LZZCalc(int Pos,int _limit,
             double& _Open[],double& _High[],double& _Low[],double& _Close[],
             double& _SA[],double& _SM[],
             double& _pUp[],double& _pDn[],double& _Up[],double& _Dn[],
             double& _Lmt[],double& _LTF[],double& _LZZ[])
  {
   int MaxBar=_limit;
   int i, RBar, LBar, ZZ = 0, NZZ, NZig, NZag;
   i = Pos - 1;
   NZig = 0;
   NZag = 0;
   while((i < MaxBar-1) && (ZZ == 0))
     {
      i++;
      _LZZ[i] = 0;
      RBar = i - MainRZZ;
      if(RBar < Pos)
         RBar = Pos;
      LBar = i + MainRZZ;
      if(i == ArrayMinimum(_SM, LBar - RBar + 1, RBar))
        {
         ZZ = -1;
         NZig = i;
        }
      if(i == ArrayMaximum(_SM, LBar - RBar + 1, RBar))
        {
         ZZ = 1;
         NZag = i;
        }
     }
   if(ZZ == 0)
      return;

   NZZ = 0;
   if(i > Pos)
     {
      if(_SM[i] > _SM[Pos])
        {
         if(ZZ == 1)
           {
            if((i >= Pos + MainRZZ) && (NZZ < 5))
              {
               NZZ++;
               _LTF[NZZ] = i;
              }
            NZag = i;
            _LZZ[i] = _SM[i];
           }
        }
      else
        {
         if(ZZ == -1)
           {
            if((i >= Pos + MainRZZ) && (NZZ < 5))
              {
               NZZ++;
               _LTF[NZZ] = i;
              }
            NZig = i;
            _LZZ[i] = _SM[i];
           }
        }
     }
   while((i < MaxBar - 1) || (NZZ < 5))
     {
      _LZZ[i] = 0;
      RBar = i - MainRZZ;
      if(RBar < Pos)
         RBar = Pos;
      LBar = i + MainRZZ;
      if(i == ArrayMinimum(_SM, LBar - RBar + 1, RBar))
        {
         if((ZZ == -1) && (_SM[i] < _SM[NZig]))
           {
            if((i >= Pos + MainRZZ) && (NZZ < 5))
               _LTF[NZZ] = i;
            _LZZ[NZig] = 0;
            _LZZ[i] = _SM[i];
            NZig = i;
           }
         if(ZZ == 1)
           {
            if((i >= Pos + MainRZZ) && (NZZ < 5))
              {
               NZZ++;
               _LTF[NZZ] = i;
              }
            _LZZ[i] = _SM[i];
            ZZ = -1;
            NZig = i;
           }
        }
      if(i == ArrayMaximum(_SM, LBar - RBar + 1, RBar))
        {
         if((ZZ == 1) && (_SM[i] > _SM[NZag]))
           {
            if((i >= Pos + MainRZZ) && (NZZ < 5))
               _LTF[NZZ] = i;
            _LZZ[NZag] = 0;
            _LZZ[i] = _SM[i];
            NZag = i;
           }
         if(ZZ == -1)
           {
            if((i >= Pos + MainRZZ) && (NZZ < 5))
              {
               NZZ++;
               _LTF[NZZ] = i;
              }
            _LZZ[i] = _SM[i];
            ZZ = 1;
            NZag = i;
           }
        }
      i++;
      if(i >=MaxBar-1)
         break;
     }
   _LZZ[Pos]=_SM[Pos];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SZZCalc(int Pos,int _limit,double& _Open[],double& _High[],double& _Low[],double& _Close[],
             double& _SA[],double& _SM[],
             double& _pUp[],double& _pDn[],double& _Up[],double& _Dn[],
             double& _Lmt[],double& _STF[])
  {
   int LBZZ=_limit;
   int i, RBar, LBar, ZZ = 0, NZZ, NZig, NZag;
   i = Pos - 1;
   NZig = 0;
   NZag = 0;
   while((i < LBZZ - 1) && (ZZ == 0))
     {
      i++;
      _pDn[i] = 0;
      _pUp[i] = 0;
      _Dn[i] = 0;
      _Up[i] = 0;
      _Lmt[i] = 0;
      RBar = i - SRZZ;
      if(RBar < Pos)
         RBar = Pos;
      LBar = i + SRZZ;
      if(i == ArrayMinimum(_SM, LBar - RBar + 1, RBar))
        {
         ZZ = -1;
         NZig = i;
        }
      if(i == ArrayMaximum(_SM, LBar - RBar + 1, RBar))
        {
         ZZ = 1;
         NZag = i;
        }
     }
   if(ZZ == 0)
      return;

   NZZ = 0;
   if(i > Pos)
     {
      if(_SM[i] > _SM[Pos])
        {
         if(ZZ == 1)
           {
            if((i >= Pos + SRZZ) && (NZZ < 4))
              {
               NZZ++;
               _STF[NZZ] = i;
              }
            NZag = i;
            _Dn[i - 1] = _Open[i - 1];
           }
        }
      else
        {
         if(ZZ == -1)
           {
            if((i >= Pos + SRZZ) && (NZZ < 4))
              {
               NZZ++;
               _STF[NZZ] = i;
              }
            NZig = i;
            _Up[i - 1] = _Open[i - 1];
           }
        }
     }
   while((i < LBZZ - 1) || (NZZ < 4))
     {
      _pDn[i] = 0;
      _pUp[i] = 0;
      _Dn[i] = 0;
      _Up[i] = 0;
      _Lmt[i] = 0;
      RBar = i - SRZZ;
      if(RBar < Pos)
         RBar = Pos;
      LBar = i + SRZZ;
      if(i == ArrayMinimum(_SM, LBar - RBar + 1, RBar))
        {
         if((ZZ == -1) && (_SM[i] < _SM[NZig]) &&
            NZig-1>=0 && i-1>=0 &&
            NZig-1<ArraySize(_Up) && i-1<ArraySize(_Up))
           {
            if((i >= Pos + SRZZ) && (NZZ < 4))
               _STF[NZZ] = i;
            _Up[NZig - 1] = 0;
            _Up[i - 1] = _Open[i - 1];
            NZig = i;
           }
         if(ZZ == 1)
           {
            if((i >= Pos + SRZZ) && (NZZ < 4))
              {
               NZZ++;
               _STF[NZZ] = i;
              }
            _Up[i - 1] = _Open[i - 1];
            ZZ = -1;
            NZig = i;
           }
        }
      if(i == ArrayMaximum(_SM, LBar - RBar + 1, RBar))
        {
         if((ZZ == 1) && (_SM[i] > _SM[NZag]) &&
            NZag-1>=0 && i-1>=0 &&
            NZag-1<ArraySize(_Dn) && i-1<ArraySize(_Dn))
           {
            if((i >= Pos + SRZZ) && (NZZ < 4))
               _STF[NZZ] = i;
            _Dn[NZag - 1] = 0;
            _Dn[i - 1] = _Open[i - 1];
            NZag = i;
           }
         if(ZZ == -1)
           {
            if((i >= Pos + SRZZ) && (NZZ < 4))
              {
               NZZ++;
               _STF[NZZ] = i;
              }
            _Dn[i - 1] = _Open[i - 1];
            ZZ = 1;
            NZag = i;
           }
        }
      i++;
      if(i >= LBZZ-1)
        {
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MainCalculation(int Pos,int _limit,double& _Open[],double& _High[],double& _Low[],double& _Close[],
                     double& _SA[],double& _SM[],double& _maChao[])
  {
   if((_limit - Pos) > (SR + 1))
      SACalc(Pos,_Open,_High,_Low,_Close,_SA,_SM,_maChao,_limit);
   else
      _SA[Pos] = 0;
   if((_limit - Pos) > (FP + SR + 2))
      SMCalc(Pos,_SA,_SM,_limit);
   else
      _SM[Pos] = 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SACalc(int Pos,double& _Open[],double& _High[],double& _Low[],double& _Close[],
            double& _SA[],double& _SM[],double& _maChao[],int _limit)
  {
   int sw, i, w, ww, Shift;
   double sum;
   _SA[Pos]=_maChao[Pos];
   for(Shift = Pos + SR + 2; Shift > Pos; Shift--)
     {
      if(Shift>=_limit-0)
         continue;
      sum = 0.0;
      sw = 0;
      i = 0;
      w = Shift + SR;
      ww = Shift - SR;
      if(ww < Pos)
         ww = Pos;
      while(w >= Shift)
        {
         i++;
         if(w<_limit && w>=0)
            sum = sum + i * _Close[w];
         sw = sw + i;
         w--;
        }
      while(w >= ww)
        {
         i--;
         if(w<_limit && w>=0)
            sum = sum + i * _Close[w];
         sw = sw + i;
         w--;
        }
      _SA[Shift] = (sw==0)?0:sum / sw;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SMCalc(int i,double& _SA[],double& _SM[],int _limit)
  {
   double t, b;
   for(int Shift = i + SR + 2; Shift >= i; Shift--)
     {
      t = _SA[ArrayMaximum(_SA,FP,Shift)];
      b = _SA[ArrayMinimum(_SA,FP,Shift)];
      _SM[Shift] = (2 * (2 + SMF) * _SA[Shift] - (t + b)) / 2 / (1 + SMF);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f_fetchSrc_mt(int _limit,int _gSz,
                   double& _close[],double& _open[],double& _high[],double& _low[],
                   ENUM_APPLIED_PRICE _src,double& _ret[])
  {
   for(int ii=_limit; ii>=0; ii--)
     {
      if(ii>=_limit-0 || ii>=_gSz-0)
         continue;
      if(_src==PRICE_OPEN)
         _ret[ii]=_open[ii];
      if(_src==PRICE_HIGH)
         _ret[ii]=_high[ii];
      if(_src==PRICE_LOW)
         _ret[ii]=_low[ii];
      if(_src==PRICE_CLOSE)
         _ret[ii]=_close[ii];
      if(_src==PRICE_MEDIAN)
         _ret[ii]=(_high[ii]+_low[ii])*0.5;
      if(_src==PRICE_TYPICAL)
         _ret[ii]=(_high[ii]+_low[ii]+_close[ii])/3;
      if(_src==PRICE_WEIGHTED)
         _ret[ii]=(_high[ii]+_low[ii]+_close[ii]*2)*0.25;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f_ma(int _limit,int _gSz,
          double& _src[],int _len,
          ENUM_MA_METHOD _maMode,
          double& _ret[])
  {
   if(_len==0)
      return;
   double _sum=0;
   if(_maMode==MODE_EMA)
     {
      f_ema(_limit,_gSz,_src,_len,_ret);
     }
   if(_maMode==MODE_SMA)
     {
      f_sma(_limit,_gSz,_src,_len,_ret);
     }
   if(_maMode==MODE_SMMA)
     {
      f_rma(_limit,_gSz,_src,_len,_ret);
     }
   if(_maMode==MODE_LWMA)
     {
      f_wma(_limit,_gSz,_src,_len,_ret);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f_sma(int _limit,int _gSz,
           double& _src[],int _len,
           double& _ret[])
  {
   if(_len==0)
      return;
   int ii,jj=0;
   double _sum=0;
   for(ii=_limit; ii>=0; ii--)
     {
      if(ii>=_limit-0 || ii>=_gSz-0)
         continue;
      _sum=0;
      for(jj=0; jj<_len; jj++)
        {
         if(ii+jj>=_limit-0 || ii+jj>=_gSz-0)
            continue;
         _sum+=_src[ii+jj];
        }
      _ret[ii]=_sum/(double)_len;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f_ema(int _limit,int _gSz,
           double& _src[],int _len,
           double& _ret[])
  {
   if(_len<=0)
      return;
   _ret[_limit-1]=_src[_limit-1];
   for(int ii=_limit; ii>=0; ii--)
     {
      if(ii>=_limit-1 || ii>=_gSz-1)
         continue;
      _ret[ii]=(2.0*_src[ii]+(double(_len)-1.0)*_ret[ii+1])/((double)_len+1.0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f_wma(int _limit,int _gSz,
           double& _src[],int _len,
           double& _ret[])
  {
   int ii,jj=0;
   double _sum=0,weight=0;
   for(ii=1; ii<=_len; ii++)
     {
      weight+=(double)ii;
     }
   if(weight==0)
      return;
   for(ii=_limit; ii>=0; ii--)
     {
      if(ii>=_limit-0 || ii>=_gSz-0)
         continue;
      _sum=0.0;
      for(jj=ii; jj<ii+_len; jj++)
        {
         if(jj>=_limit-0 || jj>=_gSz-0)
            continue;
         _sum+=_src[jj]*(double)(_len-(jj-ii));
        }
      _ret[ii]=_sum/weight;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f_rma(int _limit,int _gSz,
           double& _src[],int _len,
           double& _ret[])
  {
   if(_len<=0)
      return;
   _ret[_limit-1]=_src[_limit-1];
   for(int ii=_limit; ii>=0; ii--)
     {
      if(ii>=_limit-1 || ii>=_gSz-1)
         continue;
      _ret[ii]=(_ret[ii+1]*(_len-1)+_src[ii])/(double)_len;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AlertMessageSp(string strInput)
  {
   if(PopupAlert)
      Alert(strInput);
   if(SoundAlert)
      PlaySound(AlertSoundFile);
   if(MailAlert)
      SendMail(strInput,"GMT time: "+TimeToString(TimeGMT(),TIME_DATE|TIME_MINUTES|TIME_SECONDS));
   if(MobileAlert)
      SendNotification(strInput);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PeriodToString(int imin)
  {
   string strprd="";
   if(imin==0 || imin==(int)PERIOD_CURRENT)
      imin=Period();
   switch(imin)
     {
      case(PERIOD_M1):
         strprd="M1";
         break;
      case(PERIOD_M5):
         strprd="M5";
         break;
      case(PERIOD_M15):
         strprd="M15";
         break;
      case(PERIOD_M30):
         strprd="M30";
         break;
      case(PERIOD_H1):
         strprd="H1";
         break;
      case(PERIOD_H4):
         strprd="H4";
         break;
      case(PERIOD_D1):
         strprd="D1";
         break;
      case(PERIOD_W1):
         strprd="W1";
         break;
      case(PERIOD_MN1):
         strprd="MN1";
         break;
     }
   return(strprd);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetArrowSp(string nm,int ct,
                datetime tm,double pc,int wd,color cr,ENUM_ARROW_ANCHOR ach,
                int arrCode)
  {
   if(ObjectFind(ct,nm)<0)
      ObjectCreate(ct,nm,OBJ_ARROW,0,tm,pc);
   ObjectSetString(ct,nm,OBJPROP_TOOLTIP,"\n");
   ObjectSetDouble(ct,nm,OBJPROP_PRICE,pc);
   ObjectSetInteger(ct,nm,OBJPROP_WIDTH,wd);
   ObjectSetInteger(ct,nm,OBJPROP_TIME,tm);
   ObjectSetInteger(ct,nm,OBJPROP_COLOR,cr);
   ObjectSetInteger(ct,nm,OBJPROP_BACK,false);
   ObjectSetInteger(ct,nm,OBJPROP_ANCHOR,ach);
   ObjectSetInteger(ct,nm,OBJPROP_ARROWCODE,arrCode);
  }
//+------------------------------------------------------------------+
