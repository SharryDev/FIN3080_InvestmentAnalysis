* Clear all existing data
clear all

* Close any existing log file
capture log close

* Set the working directory
cd "/Users/sharry/Desktop/FIN3080"

* Import data from the Excel file "TRD_Co.xlsx", skipping the first two rows which may contain headers
import excel "TRD_Co.xlsx", firstrow

* Drop the first two rows, assuming they contain headers
drop if _n == 1 | _n == 2

* Convert the establishment date to Stata's internal date format
gen estb_date = date(Estbdt, "YMD")

* Format the establishment date for display
format estb_date %td

* Calculate the number of years since establishment based on the current date (assuming it's 2024-03-10)
gen estb_years = year(date("2024-03-10", "YMD")) - year(estb_date)

* Display statistics of years since establishment
tabstat estb_years, stat(n mean median p25 p75 sd)

* Convert Markettype to numeric if necessary
destring Markettype, replace

* Save the processed data
save "processed_data_year.dta", replace

* Clear all existing data
clear all

* Analyze data for companies listed on the main board

* Use the processed data
use processed_data_year if inlist(Markettype, 1, 4, 64)

* Display statistics of years since establishment for main board companies
tabstat estb_years, stat(n mean median p25 p75 sd)

* Clear all existing data
clear all

* Analyze data for companies listed on the GEM board

* Use the processed data
use processed_data_year if inlist(Markettype, 16, 32)

* Display statistics of years since establishment for GEM board companies
tabstat estb_years, stat(n mean median p25 p75 sd)
