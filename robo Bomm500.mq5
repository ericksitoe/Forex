//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;

input double LotSize = 1.00;        // Tamanho do lote
input double StopLoss = 100.0;     // Stop-loss em pontos
input double TakeProfit = 200.0;   // Take-profit em pontos
input int RSIPeriod = 14;          // Período do RSI
input double RSIOverbought = 70.0; // Nível de sobrecompra do RSI
input double RSIOverSold = 30.0;   // Nível de sobrevenda do RSI
input int MovingAveragePeriod = 50; // Período da Média Móvel Simples

int OnInit()
{
   Print("Robô Boom 500 Index iniciado com estratégia corrigida.");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("Robô Boom 500 Index encerrado.");
}

//+------------------------------------------------------------------+
//| Função para verificar tendência usando Média Móvel              |
//+------------------------------------------------------------------+
bool IsUptrend()
{
   double maCurrent = iMA(_Symbol, PERIOD_CURRENT, MovingAveragePeriod, 0, MODE_SMA, PRICE_CLOSE);
   double maPrevious = iMA(_Symbol, PERIOD_CURRENT, MovingAveragePeriod, 0, MODE_SMA, PRICE_CLOSE);
   return (maCurrent > maPrevious); // Tendência de alta
}

bool IsDowntrend()
{
   double maCurrent = iMA(_Symbol, PERIOD_CURRENT, MovingAveragePeriod, 0, MODE_SMA, PRICE_CLOSE);
   double maPrevious = iMA(_Symbol, PERIOD_CURRENT, MovingAveragePeriod, 0, MODE_SMA, PRICE_CLOSE);
   return (maCurrent < maPrevious); // Tendência de baixa
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   // Verifica se há ordens abertas
   if (OrdersTotal() > 0)
      return;

   // Calcula o RSI
   double rsi = iRSI(_Symbol, PERIOD_CURRENT, RSIPeriod, PRICE_CLOSE);

   // Obtem os preços atuais
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   MqlTradeRequest request;
   MqlTradeResult result;

   // Condição de compra (sobrevenda e tendência de alta)
   if (rsi < RSIOverSold && IsUptrend())
   {
      request.action = TRADE_ACTION_DEAL;
      request.symbol = _Symbol;
      request.volume = LotSize;
      request.price = ask;
      request.sl = NormalizeDouble(bid - StopLoss * _Point, _Digits);
      request.tp = NormalizeDouble(bid + TakeProfit * _Point, _Digits);
      request.type = ORDER_TYPE_BUY;
      request.type_filling = ORDER_FILLING_IOC;

      if (!OrderSend(request, result))
         Print("Erro ao abrir ordem de compra: ", GetLastError());
   }

   // Condição de venda (sobrecompra e tendência de baixa)
   if (rsi > RSIOverbought && IsDowntrend())
   {
      request.action = TRADE_ACTION_DEAL;
      request.symbol = _Symbol;
      request.volume = LotSize;
      request.price = bid;
      request.sl = NormalizeDouble(ask + StopLoss * _Point, _Digits);
      request.tp = NormalizeDouble(ask - TakeProfit * _Point, _Digits);
      request.type = ORDER_TYPE_SELL;
      request.type_filling = ORDER_FILLING_IOC;

      if (!OrderSend(request, result))
         Print("Erro ao abrir ordem de venda: ", GetLastError());
   }
}
