*Main board
clear all
cd "/Users/sharry/Desktop/FIN3080"

use processed_stock_data if inlist(Markettype, 1, 4, 64)

generate nummonth = monthly(Trdmnt, "YM")

format nummonth %tm

collapse (median) PEratios, by (nummonth)

twoway (line PEratios nummonth), xtitle("Trading Month") ytitle("Median PEratios") title("Median Main Board Monthly P/E Ratio Over Time")

*GEM board


clear all
use processed_stock_data if inlist(Markettype, 16, 32)

generate nummonth = monthly(Trdmnt, "YM")

format nummonth %tm

collapse (median) PEratios, by (nummonth)

twoway (line PEratios nummonth), xtitle("Trading Month") ytitle("Median PBratios") title("Median Main Board Monthly P/B Ratio Over Time")
