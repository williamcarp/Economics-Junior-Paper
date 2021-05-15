*******************************************************************************
* Implications of Negative Interest Rates: 
* The Impact of Non-interest Income on Performance and Risk for Banks in Denmark

* Author: William Carpenter
* Date Created: 9.01.19
* Last Edited:  5.11.20

*******************************************************************************
	* Import data 
	clear all 
	cls 
	set more off
	cd "/Users/LisaCarpenter/Desktop/JIW"
	import delimited "denmark.csv"

	* Initial data cleaning 
	drop if year == 1988
	drop if indicator == 1023 // swedish bank
	xtset indicator year
	drop if indicator == 1038 & year < 2004 // drop data gap from 1998-2004
	replace trading_gl = . if trading_gl == 0
	replace comm_fees = . if comm_fees == 0
	replace total_other_income = . if total_other_income == 0
	
***********************************************************
	* Generate relevant financial variables
	gen lev = total_debt / (total_debt + total_equity)
	replace lev = . if lev==0 // Leverage adjustment for 0 values 
	gen ltd = net_loans / total_deposits
	gen assets = ln(total_assets)
	gen eassets = total_equity / total_assets
	gen mtb = market_value / total_equity
	gen mtb2 = mv_datastream / total_equity
	gen liquid = cash_equiv / total_assets
	gen lev2 = total_assets / total_equity
	gen solvency = total_liabilities / total_equity
	gen roe1 = net_income / total_equity
	gen roa1 = net_income / total_assets
	by indicator: gen agrowth = total_assets/total_assets[_n-1] - 1
	by indicator: gen lgrowth = total_loans/total_loans[_n-1] - 1 
	gen lassets = net_loans / total_assets
	gen dequity = total_debt / total_equity
	gen dassets = total_deposits / total_assets
	gen debtasset = total_debt / total_assets
	gen capassets = (total_assets - total_liabilities) / total_assets


	* Return on Equity (ROAA)
	* Return on Assets (ROAE)
	by indicator: gen avg_assets = (total_assets + total_assets[_n-1])/2
	gen roaa = net_income / avg_assets
	by indicator: gen avg_equity = (total_equity + total_equity[_n-1])/2
	gen roae = net_income / avg_equity
	
	gen nonintta = total_nonint_income / total_assets
	gen intta = net_interest_income / total_assets
	gen nonint_rev = total_nonint_income / total_revenue
	gen int_rev = net_interest_income / total_revenue
	gen tradeassets = trading_gl / total_assets
	gen feesassets = comm_fees / total_assets
	gen otherassets = total_other_income / total_assets
	gen traderev = trading_gl / total_revenue
	gen otherrev = total_other_income / total_revenue
	gen feesrev = comm_fees / total_revenue
	gen nonint_rev2 = total_nonint_income / net_revenue
	gen int_rev2 = net_interest_income / net_revenue
	
	* Standarization of variables 
	egen rnonintta = std(nonintta)
	egen rintta = std(intta)
	egen rnonint_rev = std(nonint_rev)
	egen rtradeassets = std(tradeassets)
	egen rotherassets = std(otherassets)
	egen rfeesassets = std(feesassets)
	egen rtraderev = std(traderev)
	egen rfeesrev = std(feesrev)
	egen rotherrev = std(otherrev)
	
***************************************************

	* Adjustments 
	replace roa1 = roa1 * 100
	replace roe1 = roe1 * 100 
	replace roaa = roaa * 100
	replace roae = roae * 100
	replace h_var_5 = h_var_5 * 100
	replace mes5 = mes5 * 100
	
	* Performance variable labels
	label var roe1 "Return on Equity"
	label var roa1 "Return on Assets"
	label var roaa "Return on Average Assets"
	label var roae "Return on Average Equity"

	* Risk variable labels
	label var mes5 "MES 5%"
	label var h_var_5 "HVaR 5%"

	* Focus variables labels
	label var nonintta "Non-Interest Income to Assets"
	label var intta "Interest Income to Assets"  
	label var nonint_rev "Non-Interest Income to Revenue"
	label var int_rev "Interest Income to Revenue"
	label var tradeassets "Trading to Assets"
	label var feesassets "Fees \& Commissions to Assets"
	label var otherassets "Other Non-Interest to Assets"
	label var traderev "Trading to Revenue"
	label var otherrev "Other Non-Interest to Revenue"
	label var feesrev "Fees \& Commissions to Revenue"

	* Control variables labels
	label var assets "Size"
	label var agrowth "Growth"
	label var lev "Leverage"
	label var ltd "Loans to Deposits"
	label var eassets "Capitilization"
	label var mtb "Market to Book"
	label var mtb2 "Market to Book 2"
	label var liquid "Liquid Assets"
	label var lev2 "Leverage"
	label var solvency "Solvency"
	label var lassets "Loans"
	label var dassets "Deposits"
	label var debtasset "Debt"
	label var lgrowth "Loan Growth"

*******************************************************************************
	* Generating summary Statistics
	tabstat mes5, s(n mean median sd min max) format(%12.4fc) 

	
*******************************************************************************	
* Data Visualization	
	
	* Generate average variables overtime 
	egen aa = mean(nonintta), by(year)
	egen bb = mean(intta), by(year)
	egen cc = mean(roaa), by(year)
	egen dd = mean(roae), by(year)
	egen ee = mean(graph_mes5), by(year)
	egen ff = mean(graph_hvar), by(year)

	graph twoway (line aa year, sort) (line bb year,sort)
	graph twoway (line cc year, sort) (line dd year,sort)
	graph twoway (line cc year, sort) (line ee year,sort)
	graph twoway (line aa year, sort) (line cc year,sort)
	graph twoway (line aa year, sort) (line cc year,sort)
	graph twoway (line gg year, sort) (line hh year,sort)

	* ONE AXIS  non-interest assets
	graph twoway (line aa year, sort) (line bb year,sort lpattern(shortdash)), ///
	graphregion(fcolor("255 255 255")) xsize(6.0) xlabel(#8) ///
	xtitle("Year") /// 
	ytitle("Non-interest / Interest Income to Assets") /// 
	legend(label(1 "Non-Interest Income to Assets") label(2 "Interest Income to Assets"))
	graph export 1axis_nointta_intta.png, replace

	* Non-interest to Assets, interest to assets 
	graph twoway (line aa year, yaxis(2) sort) (line bb year, yaxis(1) sort lpattern(shortdash)), ///
	graphregion(fcolor("255 255 255")) xsize(6.0) xlabel(#8) ///
	xtitle("Year") /// 
	ytitle("Interest Income to Assets") /// 
	ytitle("Non-interest Income to Assets", axis(2)) ///
	legend(label(1 "Non-interest Income to Assets") label(2 "Interest Income to Assets"))
	graph export 2axis_nonintta_intaa.png, replace

	* Non-interest and ROAA 
	graph twoway (line aa year, yaxis(1) sort) (line cc year, yaxis(2) sort lpattern(shortdash)), ///
	graphregion(fcolor("255 255 255")) xsize(6.0) xlabel(#8) ///
	xtitle("Year ") /// 
	ytitle("Non-interest Income to Assets") /// 
	ytitle("ROAA", axis(2)) ///
	legend(label(1 "Non-interest Income to Assets") label(2 "ROAA"))
	graph export nonintta_roaa.png, replace

	* Non-interest and ROAE 
	graph twoway (line aa year, yaxis(1) sort) (line dd year, yaxis(2) sort lpattern(shortdash)), ///
	graphregion(fcolor("255 255 255")) xsize(6.0) xlabel(#8) ///
	xtitle("Year ") /// 
	ytitle("Non-interest Income to Assets") /// 
	ytitle("ROAE", axis(2)) ///
	legend(label(1 "Non-interest Income to Assets") label(2 "ROAE"))
	graph export nonintta_roae.png, replace


	* Non-interest and MES 
	graph twoway (line aa year, yaxis(1) sort) (line ee year, yaxis(2) sort lpattern(shortdash)), ///
	graphregion(fcolor("255 255 255")) xsize(6.0) xlabel(#8) ///
	xtitle("Year ") /// 
	ytitle("Non-interest Income to Assets") /// 
	ytitle("MES", axis(2)) ///
	legend(label(1 "Non-interest Income to Assets") label(2 "MES"))
	graph export nonintta_mes.png, replace

	* Non-interest and HVaR
	graph twoway (line aa year, yaxis(1) sort) (line ff year, yaxis(2) sort lpattern(shortdash)), ///
	graphregion(fcolor("255 255 255")) xsize(6.0) xlabel(#8) ///
	xtitle("Year ") /// 
	ytitle("Non-interest Income to Assets") /// 
	ytitle("HVaR", axis(2)) ///
	legend(label(1 "Non-interest Income to Assets") label(2 "HVaR"))
	graph export nonintta_hvar.png, replace

	egen aaa = mean(nonintta), by(year)
	graph twoway line a year, sort

	egen bbb = mean(roaa), by(year)
	graph twoway line bbb year, sort

	egen ccc = mean(roae), by(year)
	graph twoway line ccc year, sort

	egen fff = mean(assets), by(year)
	graph twoway line f year, sort

	egen ddd = mean(liquid), by(year)
	graph twoway line w year, sort

	egen eee = mean(return_on_assets), by(year)
	graph twoway line x year, sort

	egen fff = mean(int_rev), by(year)
	graph twoway line y year, sort

	egen ggg = mean(nonint_rev), by(year)
	graph twoway line z year, sort

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

* Data Analysis (Fixed-Effects Regressions)

	xtset indicator year
	xtreg roaa l.nonintta l.intta l.assets l.agrowth l.eassets  /// 
	i.year, fe vce(cluster indicator)
	qui sum roaa if e(sample)
	outreg2 using roaa_nonintta.tex, replace ctitle(ROAA) label ///
	keep(l.nonintta l.intta l.assets l.agrowth l.eassets) ///
	addstat(Root Mean Squared Error, e(rmse), Mean ROAA/ROAE, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3) ///
	addnote("Robust standard errors are clustered at the bank-level.")

	xtset indicator year
	xtreg roaa l.nonintta l.intta l.assets l.agrowth l.eassets l.lassets /// 
	i.year, fe vce(cluster indicator)
	qui sum roaa if e(sample)
	outreg2 using roaa_nonintta.tex, append ctitle(ROAA) label ///
	keep(l.nonintta l.intta l.assets l.agrowth l.eassets l.lassets) ///
	addstat(Root Mean Squared Error, e(rmse), Mean ROAA/ROAE, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)

	xtset indicator year
	xtreg roaa l.nonintta l.intta l.assets l.agrowth l.eassets l.lassets /// 
	l.liquid i.year, fe vce(cluster indicator)
	qui sum roaa if e(sample)
	outreg2 using roaa_nonintta.tex, append ctitle(ROAA) label ///
	keep(l.nonintta l.intta l.assets l.agrowth l.eassets l.lassets l.liquid) ///
	addstat(Root Mean Squared Error, e(rmse), Mean ROAA/ROAE, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)

	xtset indicator year
	xtreg roae l.nonintta l.intta l.assets l.agrowth l.eassets /// 
	i.year, fe vce(cluster indicator)
	qui sum roae if e(sample)
	outreg2 using roaa_nonintta.tex, append ctitle(ROAE) label ///
	keep(l.nonintta l.intta l.assets l.agrowth l.eassets) ///
	addstat(Root Mean Squared Error, e(rmse), Mean ROAA/ROAE, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3) ///
	addnote("Robust standard errors are clustered at the bank-level.")

	xtset indicator year
	xtreg roae l.nonintta l.intta l.assets l.agrowth l.eassets  l.lassets /// 
	i.year, fe vce(cluster indicator)
	qui sum roae if e(sample)
	outreg2 using roaa_nonintta.tex, append ctitle(ROAE) label ///
	keep(l.nonintta l.intta l.assets l.agrowth l.eassets  l.lassets) ///
	addstat(Root Mean Squared Error, e(rmse), Mean ROAA/ROAE, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)

	xtset indicator year
	xtreg roae l.nonintta l.intta l.assets l.agrowth l.eassets  l.lassets /// 
	l.liquid i.year, fe vce(cluster indicator)
	qui sum roae if e(sample)
	outreg2 using roaa_nonintta.tex, append ctitle(ROAE) label ///
	keep(l.nonintta l.intta l.assets l.agrowth l.eassets  l.lassets l.liquid) ///
	addstat(Root Mean Squared Error, e(rmse), Mean ROAA/ROAE, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


	xtset indicator year
	xtreg roaa l.tradeassets l.otherassets l.feesassets l.intta l.assets l.agrowth l.eassets  /// 
	i.year, fe vce(cluster indicator)
	qui sum roaa if e(sample)
	outreg2 using roaa_nonintta_decomp.tex, replace ctitle(ROAA) label ///
	keep(l.tradeassets l.feesassets l.otherassets l.intta  l.assets l.agrowth l.eassets ) ///
	addstat(Root Mean Squared Error, e(rmse), Mean ROAA/ROAE, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3) ///
	addnote("Robust standard errors are clustered at the bank-level.")

	xtset indicator year
	xtreg roaa l.tradeassets l.otherassets l.feesassets l.intta  l.assets l.agrowth l.eassets  l.lassets /// 
	i.year, fe vce(cluster indicator)
	qui sum roaa if e(sample)
	outreg2 using roaa_nonintta_decomp.tex, append ctitle(ROAA) label ///
	keep(l.tradeassets l.feesassets l.otherassets l.intta  l.assets l.agrowth l.eassets  l.lassets) ///
	addstat(Root Mean Squared Error, e(rmse), Mean ROAA/ROAE, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)


	xtset indicator year
	xtreg roaa l.tradeassets l.otherassets l.feesassets l.intta  l.assets l.agrowth l.eassets  l.lassets /// 
	l.liquid i.year, fe vce(cluster indicator)
	qui sum roaa if e(sample)
	outreg2 using roaa_nonintta_decomp.tex, append ctitle(ROAA) label ///
	keep(l.tradeassets l.feesassets l.otherassets l.intta  l.assets l.agrowth l.eassets  l.lassets l.liquid) ///
	addstat(Root Mean Squared Error, e(rmse), Mean ROAA/ROAE, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)

	xtset indicator year
	xtreg roae l.tradeassets l.otherassets l.feesassets l.intta  l.assets l.agrowth l.eassets  /// 
	i.year, fe vce(cluster indicator)
	qui sum roae if e(sample)
	outreg2 using roaa_nonintta_decomp.tex, append ctitle(ROAE) label ///
	keep(l.tradeassets l.feesassets l.otherassets l.intta  l.assets l.agrowth l.eassets ) ///
	addstat(Root Mean Squared Error, e(rmse), Mean ROAA/ROAE, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)

	xtset indicator year
	xtreg roae l.tradeassets l.otherassets l.feesassets l.intta  l.assets l.agrowth l.eassets  l.lassets /// 
	i.year, fe vce(cluster indicator)
	qui sum roae if e(sample)
	outreg2 using roaa_nonintta_decomp.tex, append ctitle(ROAE) label ///
	keep(l.tradeassets l.feesassets l.otherassets l.intta  l.assets l.agrowth l.eassets  l.lassets) ///
	addstat(Root Mean Squared Error, e(rmse), Mean ROAA/ROAE, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)


	xtset indicator year
	xtreg roae l.tradeassets l.otherassets l.feesassets l.intta l.assets l.agrowth l.eassets  l.lassets l.liquid /// 
	i.year, fe vce(cluster indicator)
	qui sum roae if e(sample)
	outreg2 using roaa_nonintta_decomp.tex, append ctitle(ROAE) label ///
	keep(l.tradeassets l.feesassets l.otherassets l.intta l.assets l.agrowth l.eassets  l.lassets l.liquid) ///
	addstat(Root Mean Squared Error, e(rmse), Mean ROAA/ROAE, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

	xtset indicator year
	xtreg mes5 nonintta intta assets agrowth eassets mtb /// 
	i.year, fe vce(cluster indicator)
	qui sum mes5 if e(sample)
	outreg2 using risk_nonintta.tex, replace ctitle(MES 5%) label ///
	keep(nonintta intta assets agrowth eassets mtb) ///
	addstat(Root Mean Squared Error, e(rmse), Mean MES/HVaR, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3) ///
	addnote("Robust standard errors are clustered at the bank-level.")

	// tabstat liquid if e(sample), s(n mean median sd min max) format(%12.4fc) 

	xtset indicator year
	xtreg mes5 nonintta intta assets agrowth eassets mtb lassets /// 
	i.year, fe vce(cluster indicator)
	qui sum mes5 if e(sample)
	outreg2 using risk_nonintta.tex, append ctitle(MES 5%) label ///
	keep(nonintta intta assets agrowth eassets mtb lassets) ///
	addstat(Root Mean Squared Error, e(rmse), Mean MES/HVaR, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3) 

	xtset indicator year
	xtreg mes5 nonintta intta assets agrowth eassets mtb lassets /// 
	liquid i.year, fe vce(cluster indicator)
	qui sum mes5 if e(sample)
	outreg2 using risk_nonintta.tex, append ctitle(MES 5%) label ///
	keep(nonintta intta assets agrowth eassets mtb lassets liquid) ///
	addstat(Root Mean Squared Error, e(rmse), Mean MES/HVaR, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)

	xtset indicator year
	xtreg h_var_5 nonintta intta assets agrowth eassets mtb /// 
	i.year, fe vce(cluster indicator)
	qui sum h_var_5 if e(sample)
	outreg2 using risk_nonintta.tex, append ctitle(HVaR 5%) label ///
	keep(nonintta intta assets agrowth eassets mtb) ///
	addstat(Root Mean Squared Error, e(rmse), Mean MES/HVaR, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)

	xtset indicator year
	xtreg h_var_5 nonintta intta assets agrowth eassets mtb lassets /// 
	i.year, fe vce(cluster indicator)
	qui sum h_var_5 if e(sample)
	outreg2 using risk_nonintta.tex, append ctitle(HVaR 5%) label ///
	keep(nonintta intta assets agrowth eassets mtb lassets) ///
	addstat(Root Mean Squared Error, e(rmse), Mean MES/HVaR, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3) 

	xtset indicator year
	xtreg h_var_5 nonintta intta assets agrowth eassets mtb  lassets /// 
	liquid i.year, fe vce(cluster indicator)
	qui sum h_var_5 if e(sample)
	outreg2 using risk_nonintta.tex, append ctitle(HVaR 5%) label ///
	keep(nonintta intta assets agrowth eassets mtb lassets liquid) ///
	addstat(Root Mean Squared Error, e(rmse), Mean MES/HVaR, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

	xtset indicator year
	xtreg mes5 tradeassets feesassets otherassets intta assets agrowth eassets mtb /// 
	i.year, fe vce(cluster indicator)
	qui sum mes5 if e(sample)
	outreg2 using risk_nonintta_decomp.tex, replace ctitle(MES 5%) label ///
	keep(tradeassets feesassets otherassets intta assets agrowth eassets mtb) ///
	addstat(Root Mean Squared Error, e(rmse), Mean MES/HVaR, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3) ///
	addnote("Robust standard errors are clustered at the bank-level.")

	xtset indicator year
	xtreg mes5 tradeassets feesassets otherassets intta assets agrowth eassets mtb lassets /// 
	i.year, fe vce(cluster indicator)
	qui sum mes5 if e(sample)
	outreg2 using risk_nonintta_decomp.tex, append ctitle(MES 5%) label ///
	keep(tradeassets feesassets otherassets intta assets agrowth eassets mtb lassets) ///
	addstat(Root Mean Squared Error, e(rmse), Mean MES/HVaR, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3) 

	xtset indicator year
	xtreg mes5 tradeassets feesassets otherassets intta assets agrowth eassets  mtb lassets /// 
	liquid i.year, fe vce(cluster indicator)
	qui sum mes5 if e(sample)
	outreg2 using risk_nonintta_decomp.tex, append ctitle(MES 5%) label ///
	keep(tradeassets feesassets otherassets intta assets agrowth eassets  mtb lassets liquid) ///
	addstat(Root Mean Squared Error, e(rmse), Mean MES/HVaR, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)

	xtset indicator year
	xtreg h_var_5 tradeassets feesassets otherassets intta assets agrowth eassets mtb /// 
	i.year, fe vce(cluster indicator)
	qui sum h_var_5 if e(sample)
	outreg2 using risk_nonintta_decomp.tex, append ctitle(HVaR 5%) label ///
	keep(tradeassets feesassets otherassets intta assets agrowth eassets mtb) ///
	addstat(Root Mean Squared Error, e(rmse), Mean MES/HVaR, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)

	xtset indicator year
	xtreg h_var_5 tradeassets feesassets otherassets intta assets agrowth eassets mtb lassets /// 
	i.year, fe vce(cluster indicator)
	qui sum h_var_5 if e(sample)
	outreg2 using risk_nonintta_decomp.tex, append ctitle(HVaR 5%) label ///
	keep(tradeassets feesassets otherassets intta assets agrowth eassets mtb lassets) ///
	addstat(Root Mean Squared Error, e(rmse), Mean MES/HVaR, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3) 

	xtset indicator year
	xtreg h_var_5 tradeassets feesassets otherassets intta assets agrowth eassets mtb lassets /// 
	liquid i.year, fe vce(cluster indicator)
	qui sum h_var_5 if e(sample)
	outreg2 using risk_nonintta_decomp.tex, append ctitle(HVaR 5%) label ///
	keep(tradeassets feesassets otherassets intta assets agrowth eassets mtb lassets liquid) ///
	addstat(Root Mean Squared Error, e(rmse), Mean MES/HVaR, `r(mean)') ///
	addtex(Bank Fixed Effects, Yes, Year Fixed Effects, Yes) dec(3)


///////////////////////////////////////////////////////////////////
	by indicator: egen zroaa = sd(roaa) if e(sample)
	gen shroaa = roaa / zroaa
	gen zscoreroaa = (roaa + eassets) / zroaa

	by indicator: egen zroae = sd(roae) if e(sample)
	gen shroae = roae / zroae
	gen zscoreroae = (roae + eassets) / zroae
//////////////////////////////////////////////////////////////////


* End of file
*******************************************************************************

