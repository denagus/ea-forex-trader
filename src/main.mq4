#property copyright "Copyright 2018, Mathías Donoso"
#property link "https://github.com/mathiasd88/ea-forex-trader"
#property version "1.00"
#property strict

int shortPeriod = 4;
int mediumPeriod = 18;
int longPeriod = 40;

double shortMA = iMA(Symbol(), NULL, shortPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
double mediumMA = iMA(Symbol(), NULL, mediumPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
double longMA = iMA(Symbol(), NULL, longPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);

int firstSignal = 0;
int dangerZone = 0;

double lots = 0.1;

bool ValidateSettings()
{
  return true;
}

bool CanTrade()
{
  return true;
}

int init(){}

void OnTick()
{
  if (!ValidateSettings()) {
    return;
  }
  if (!CanTrade()) {
    return;
  }

  // Delphic Phenomenon
  if (mediumMA == longMA) firstSignal = 0;
  if (mediumMA > longMA) firstSignal = 1;
  if (mediumMA < longMA) firstSignal = -1;

  dangerZone = firstSignal;

  if (dangerZone == 1) {
    if (Ask < mediumMA) {
      // place buy roder 18MA and SL at 40MA
      if (OrdersTotal() == 0) {
        bool order = OrderSend(Symbol(), OP_BUY, lots, mediumMA, 3,longMA, mediumMA + (MathAbs(mediumMA - longMA) * 3), "", 0, 0, Green);
        if (order) {}
      } else {
        for (int i = 1; i <= OrdersTotal(); i++) {
          if (OrderSelect(i-1, SELECT_BY_POS) == true) {
            bool action = OrderDelete(OrderTicket());
            if (action) {}
          }
        }
      }
    }
  }

  if (dangerZone == -1) {
    if (Bid > mediumMA) {
      // place sell order 18MA and SL at 40MA
      if (OrdersTotal() == 0) {
        bool order = OrderSend(Symbol(), OP_SELL, lots, mediumMA, 3,longMA, mediumMA - (MathAbs(mediumMA - longMA) * 3), "", 0, 0, Red);
        if (order) {}
      } else {
        for (int i = 1; i <= OrdersTotal(); i++) {
          if (OrderSelect(i-1, SELECT_BY_POS) == true) {
            bool action = OrderDelete(OrderTicket());
            if (action) {}
          }
        }
      }
    }
  }

  // Once the market begins moving in our direction, we need to trail our SL halfway between the 18MA and the 40MA.
  if (OrdersTotal() > 0) {
    int orderType;
    for (int i = 1; i <= OrdersTotal(); i++) {
      orderType = OrderType();

      if (orderType == OP_BUY) {
        bool action = OrderModify(OrderTicket(), ORderOpenPrice(), longMA + (MathAbs(mediumMA - longMA)/2), OrderTakeProfit(), 0, Green);
        if (action) {}
      }

      if (orderType == OP_SELL) {
        bool action = OrderModify(OrderTicket(), ORderOpenPrice(), longMA - (MathAbs(mediumMA - longMA)/2), OrderTakeProfit(), 0, Red);
        if (action) {}
      }
    } 
  }
}
