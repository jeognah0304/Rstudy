
#__________________________________________________________________________________
  #0. road the data
  setwd("C:\\Users\\parkjeongah\\Desktop\\working\\�濵����\\Business analytics")
  data <- read.delim("simuldat.dat", header=F, sep=" ")
  
  colnames(data) = c("id1","id2","comprat1","bjkfact","comrt1lg","lgbjkfac","tenur","valholag","curinlag","lassets","liquid","tax","lever","difown","empscal","freecash","conrat","regul")  
  
  
  #0-2. Checking the data plots for finding ID's info.
  View(data)
  hist(data$id2,main="id2")
  id = table(as.numeric(data$id1))
  dim(id)
  
  table(data$id2)
  table(data$id1)
  
  #0-2. Checking the other variables
  str(data)
  
  par(mfrow=c(5,3))
  plot(data$comprat1, main="comprat1") # sparse, lots of 0
  plot(data$bjkfact, main="bjkfact") 
  plot(data$comrt1lg, main="comrt1lg") # comprat1�� ������ ������ �׸�
  plot(data$lgbjkfac, main="lgbjkfac") # bjkfact�� ������ ������ �׸�
  plot(data$tenur,main="tenur")
  plot(data$valholag, main="valholag") #0�� ����, outlier�� ���� ���̴� �׸���.
  plot(data$curinlag, main="curinlag") # valholag�ʹ� �ٸ����� ������ ����.
  plot(data$lassets, main="lassets") #����
  plot(data$liquid, main="liquid")
  plot(data$tax, main="tax")
  plot(data$lever, main="lever")
  plot(data$difown, main="difown")
  plot(data$empscal, main="empscal")
  plot(data$freecash, main="freecash")
  plot(data$conrat, main="conrat")
  plot(data$regul) #binary
  

  
  # ��ټ��� ������ �׸��� sparse�� ������ ����.
  # �ΰ��� ����: A����: �¿�� ����� ������ְ�, B����: �������� ���� ġ��ģ �׸�.
  
  str(data)
  
  index = c("comprat1", "bjkfact","comrt1lg","lgbjkfac","tenur","valholag","curinlag","lassets","liquid","tax","lever","difown","empscal","freecash","conrat")
  ndata = data[,index]
  table = cor(ndata)
  
  table # ������ ���� ������� �ִ� ������ ������.
  
  
  
  
  summary(table) # binary��, id1,2�� �����ϰ� correlation matrix����� ��ġ�� ����� ������ �����跮 ���.-�ǹ̴¾�����.
  
  
  dim(data)
  str(data)
  View(data)
  
  
  par(mfrow=c(1,1))
  hist(data$tenur) # 1/x (x>0) �׸��� ���ó�� ����.
  

  #__________________________________________________________________________________
  #1. First estimate them as separate models using OLS (Ordinary Least Squares).  You need not worry about testing and adjusting for heteroscedasticity. 
  
  
  library(nnet)
  library(mgcv)  
  library(quantreg)  
  library(systemfit)  
  library(foreign)  
  library(car)  
  library(Rcpp)  
  
  r1 = comprat1 ~ bjkfact+comrt1lg + tenur + valholag + curinlag + lassets + liquid + tax + lever + difown + freecash + conrat + regul
  r2 =   bjkfact ~ comprat1 + lgbjkfac + tenur + valholag + curinlag + lassets + liquid + tax + lever + difown + empscal + freecash + conrat + regul
  
  
  
  ols_first = lm(r1, data=data)
  ols_second = lm(r2, data=data)
  
  
  
  
  #__________________________________________________________________________________
  #2. Then estimate them using SUR (seemingly unrelated regressions) (If it does not work in STATA, you can eliminate a variable from an equation). 
  
  
  SUR = systemfit(list(r1,r2), data=data, method="SUR")
  summary(SUR)  
  
  
  library(Rcpp)
  library(spikeSlabGAM)
  # variable selection
  m = spikeSlabGAM(formula=r1, data=data)
  n = spikeSlabGAM(formula=r2, data=data)
  
  summary(m)
  summary(n)
  
  
  #__________________________________________________________________________________
  #3. Then estimate them using two-stage least squares and three stage least squares. 
  
  
  
  # case1, when we know about IV => but we didn't know
  # �� �κ��� �������� �� ���� ��.
  
  SLS2 = systemfit(list(r1,r2),inst=~ freecash + comrt1lg + lgbjkfac , data=data, method="2SLS")
  SLS3 = systemfit(list(r1,r2),inst=~ freecash + comrt1lg + lgbjkfac, data=data, method="3SLS")
  
  summary(SLS3)
  summary(SLS2)
  
  
  # case2, when we don't know IV
  library(AER)
  iv1 = ivreg(r1 | tdiff , data = data) #2SLS(IV regression)
  
  # �������� �� ���� ���� : Testing linear restriction*
  # The linearHypothesis method for system???t objects can be used to test linear restrictions on the estimated coe???cients by Theil��s F test or by usual Wald tests
  
  fitsur = systemfit(list(readreg=r1, mathreg=r2),data=data)
  summary(fitsur)
  
  restriction = "readreg_regul - mathreg_regul"
  linearHypothesis(fitsur, restriction, test= "Chisq")
  
  
  
  
  library(plm)
  phtest(fitsur, restriction) # this is not available
  ?hausman.systemfit
  
  #results2sls	: result of a 2SLS (limited information) estimation returned by systemfit.
  #results3sls	: result of a 3SLS (full information) estimation returned by systemfit.
  
  
  ## Implementation
  library("AER")
  
  ols_first$coefficients
  ols_second$coefficients
  

  fit_iv = ivreg(r1, data=data)
  summary(fit_iv)

  fit_iv2 = ivreg(r2, data=data)
  summary(fit_iv2)
  
  cor(fit_iv$residuals, fit_iv2$residuals)
  
  #If you want heteroskedasticity-consistent standard errors,
  
  set.seed(1004)
  data_sample <- data[sample(1:nrow(data), 200), ]
  fit_iv_sample <- update(fit_iv,data = data_sample)
  summary(fit_iv_sample)
  
  
  SLS3 = systemfit(list(r1,r2),inst=~ freecash +lassets + comprat1 + lgbjkfac + curinlag,data=data, method="3SLS")
  summary(SLS3)
  
  #__________________________________________________________________________________
  #4. Write a report interpreting your findings focusing on what are the differences between OLS, SUR, 2SLS and 3SLS estimates. 