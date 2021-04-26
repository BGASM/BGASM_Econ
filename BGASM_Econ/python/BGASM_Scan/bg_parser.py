import pandas as pd
from pivottablejs import pivot_ui
import os
import webbrowser


def make_tables(data):
    t_data = parse(data)
    df = pd.DataFrame(t_data)
    rows = ["cluster", "sector", "station"]
    cols = ["ware"]
    include = {"ware":["Hull Parts", "Field Coils", "Engine Parts"]}
    pivot_ui(df, outfile_path="bgasm-econ.html", rows=rows, cols=cols, aggregatorName="Sum",
             vals=["price"])
    if not os.environ.get("BGECON"):
        webbrowser.open_new('bgasm-econ.html')
        os.environ['BGECON'] = "1"


def parse(data):
    trades = []
    for station in data['stations']:
        cluster, owner, name, sector, id = station["cluster"], station["ownername"], station["name"], station["sector"], station["id"]
        ntrade = {}
        for trade in station['trade']:
            price, dem, buy, sell, ware = \
                round(trade["price"], 2), int(trade["amount"]), trade["buy"], trade["sell"], trade["ware"]
            ntrade["cluster"] = cluster
            ntrade["owner"] = owner
            ntrade["station"] = name
            ntrade["sector"] = sector
            ntrade["ware"] = ware
            if buy:
                ntrade["price"] = price
                ntrade["supply/demand"] = dem
                ntrade["profit/cost"] = price*dem
                ntrade["buy/sell"] = "BUY"
            elif sell:
                ntrade["price"] = price*-1
                ntrade["supply/demand"] = dem*-1
                ntrade["profit/cost"] = price*dem*-1
                ntrade["buy/sell"] = "SELL"

            trades.append(ntrade)
    return trades
