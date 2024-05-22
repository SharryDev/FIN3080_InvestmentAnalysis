* Clear existing data and logs
clear all
capture log close

* Set working directory
cd "/Users/sharry/Desktop/FIN3080"

* Log the output to a file
log using PEratios.log, replace

* Import financial statement data
import excel "FS_Comins.xlsx", firstrow
drop if _n == 1 | _n == 2
rename B001216000 rdexp 
rename B003000000 EPS

* Extract year and month from the date variable
gen year = substr(Accper, 1, 4)
gen month = substr(Accper, 6, 7)
replace month = substr(month, 1, 2)

* Remove data for January
drop if month == "01"

* Convert year and month to numeric
destring year, replace
destring month, replace

* Create a new date variable in quarterly format
gen date_yq = ""
replace date_yq = string(year) + "-01" if month == 3
replace date_yq = string(year) + "-02" if month == 6
replace date_yq = string(year) + "-03" if month == 9
replace date_yq = string(year) + "-04" if month == 12

* Convert the new date variable to quarterly format
gen date_yq_new = quarterly(date_yq, "YQ")
format date_yq_new %tq

* Drop the old date variable
drop date_yq

* Rename the new date variable
rename date_yq_new date_yq

* Save the processed financial data
save "processed_data.dta", replace

* Clear existing data
clear all

* Import stock trading data
import excel "TRD_Mnth.xlsx", firstrow
rename Mclsprc prc 
rename Mretwd ret

* Create a new date variable in monthly format
gen date_ym = monthly(Trdmnt, "YM") 
format date_ym %tm 

* Extract year and month from the date variable
gen year = substr(Trdmnt, 1, 4)
gen month = substr(Trdmnt, 6, .)
destring year, replace
destring month, replace

* Create a new date variable in quarterly format for stock data
gen date_yq = ""
replace date_yq = string(year - 1) + "-04" if month >= 1 & month <= 3
replace date_yq = string(year) + "-01" if month >= 4 & month <= 6
replace date_yq = string(year) + "-02" if month >= 7 & month <= 9
replace date_yq = string(year) + "-03" if month >= 10 & month <= 12

* Convert the new date variable to quarterly format
gen date_yq_new = quarterly(date_yq, "YQ")
format date_yq_new %tq

* Drop the old date variable
drop date_yq

* Rename the new date variable
rename date_yq_new date_yq

* Save the processed stock data
save "processed_stock_data.dta", replace

* Use the processed stock data
use processed_stock_data, clear

* Merge financial and stock data on stock code and date
merge m:1 Stkcd date_yq using processed_data

* Convert EPS to numeric
destring EPS, replace

* Calculate PE ratios
gen PEratios = prc/EPS

* Save the updated stock data
save "processed_stock_data.dta", replace

* Clear existing data
clear all

* Import book value per share data
import excel "FI_T9.xlsx", firstrow
drop if _n == 1 | _n == 2
rename F091001A BVPS 

* Extract year and month from the date variable
gen year = substr(Accper, 1, 4)
gen month = substr(Accper, 6, 7)
replace month = substr(month, 1, 2)

* Convert year and month to numeric
destring year, replace
destring month, replace

* Drop data with report type "B"
drop if Typrep == "B"

* Create a new date variable in quarterly format
gen date_yq = ""
replace date_yq = string(year) + "-01" if month == 3
replace date_yq = string(year) + "-02" if month == 6
replace date_yq = string(year) + "-03" if month == 9
replace date_yq = string(year) + "-04" if month == 12

* Convert the new date variable to quarterly format
gen date_yq_new = quarterly(date_yq, "YQ")
format date_yq_new %tq

* Drop the old date variable
drop date_yq

* Rename the new date variable
rename date_yq_new date_yq

* Save the processed book value data
save "processed_data_BVPS.dta", replace

* Clear existing data
clear all

* Use the processed stock data
use processed_stock_data, clear

* Drop the _merge variable from previous merges
drop _merge

* Merge book value data with stock data
merge m:1 Stkcd date_yq using processed_data_BVPS

* Convert BVPS to numeric
destring BVPS, replace

* Calculate PB ratios
gen PBratios = prc/BVPS

* Save the updated stock data
save "processed_stock_data.dta", replace

* Clear existing data
clear all

* Set working directory
cd "/Users/sharry/Desktop/FIN3080"

* Import company profile data
import excel "TRD_Co.xlsx", firstrow

* Save the processed company profile data
save "processed_data_profile.dta", replace

* Clear existing data
clear all

* Use the processed stock data
use processed_stock_data, clear

* Drop the _merge variable from previous merges
drop _merge

* Merge company profile data with stock data
merge m:1 Stkcd using processed_data_profile

* Create an index variable within each stock code and date
bysort Stkcd Trdmnt: gen index = _n

* Display statistics for PB ratios
tabstat PBratios, stat(n mean median p25 p75 sd)

* Display statistics for PE ratios
tabstat PEratios, stat(n mean median p25 p75 sd)

* Drop specific observations
drop if _n == 707030 | _n == 707031

* Convert Markettype to numeric
destring Markettype, replace

* Save the final processed stock data
save "processed_stock_data.dta", replace

* Analyze Main board data
clear all
use processed_stock_data if inlist(Marketyype, 1, 4, 64)

* Display statistics for PB ratios on Main board
tabstat PBratios, stat(n mean median p25 p75 sd)

* Display statistics for PE ratios on Main board
tabstat PEratios, stat(n mean median p25 p75 sd)

* Analyze GEM board data
clear all
use processed_stock_data if inlist(Marketyype, 16, 32)

* Display statistics for PB
