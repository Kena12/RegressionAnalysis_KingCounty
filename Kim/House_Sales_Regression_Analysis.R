# data_analysis2
# analysis on correlation of all variable regarding house price
# reference to https://www.kaggle.com/amitdhakre13/eda-linear-regression-k-fold-cv-adj-r2-0-87/notebook



# Quick display of two cabapilities of GGally, to assess the distribution and correlation of variables 
install.packages("GGally")
install.packages("corrplot")
install.packages("caret")
install.packages("car")
install.packages("lm.beta")
install.packages("nortest")
install.packages("gvlma")

library(gvlma)
library(nortest)
library(lm.beta)
library(car)
library(caret)
library(dplyr)
library(car)
library(corrploy)
library(GGally)
library(pacman)
pacman:: p_load(Metrics, car, corrplot, caTools, ggplot2, DAAG)

rm(list = ls())
# data removed or not using
# date, sqft_lot, condition, long, sqft_lot15

## correlation of all variables
setwd("/Users/DK/Documents/programming/Github/Regression Analysis/rawdata/")
data <- read.csv("kc_house_data.csv")


data.index <- caret::createDataPartition(data$price, p = 0.8)
data.train <- data[unlist(data.index) , ]
data.test  <- data[-unlist(data.index) ,]

# price ���� �α�ȭ (���ϸ� ����� ������â)
data.train$price <- log(data.train$price)
data.test$price <- log(data.test$price)

data.train$date = substr(data.train$date, 1, 6)
data.test$date = substr(data.test$date, 1, 6)
# �ϴ� data�� ���ڷιٲ�� ����� Ȯ�ΰ���
data.train$date = as.numeric(as.character(data.train$date))
data.test$date = as.numeric(as.character(data.test$date))

# id ����(������ �ʿ����)
data.train$id <- NULL
data.test$id <- NULL

corr = cor(data.train[, 1:20])
corrplot::corrplot(corr, method = "color", cl.pos = 'n', rect.col = "black",  tl.col = "black", addCoef.col = "black", number.digits = 2, number.cex = 0.50, tl.cex = 0.9, cl.cex = 1, col = colorRampPalette(c("green4","white","red"))(100))
# Corrleations higher than 0.5
# bathrooms, sqft_living, grde, sqft_abve, sqft_living 15
# bathrooms : 0.55
# sqft_living : 0.7
# grade : 0.7
# sqft_above : 0.6
# sqft_living15 : 0.62

# remove all the variables below 0.1
data.train$sqft_lot = NULL
data.train$condition = NULL
data.train$long = NULL
data.train$sqft_lot15 = NULL

data.test$sqft_lot = NULL
data.test$condition = NULL
data.test$long = NULL
data.test$sqft_lot15 = NULL
# ������ ������ȣ�� factor �� corplot����غ���

# lm model for all variables
housesales.lm <- lm(price ~ bathrooms + sqft_living + grade + sqft_above + sqft_living15, data = data.train)
summary(housesales.lm)


# "date"          "price"         "bedrooms"      "bathrooms"    
# [5] "sqft_living"   "sqft_lot"      "floors"        "waterfront"   
# [9] "view"          "condition"     "grade"         "sqft_above"   
# [13] "sqft_basement" "yr_built"      "yr_renovated"  "zipcode"      
# [17] "lat"           "long"          "sqft_living15" "sqft_lot15"   
# > 

# �� ���� �� R^2 �˻�
housesales.lm.all <- lm(price ~ ., data= data.train)
summary(housesales.lm.all)

# bedrooms -  0.118 
# bathrooms - 0.3034
# sqft_living - 0.4835
# sqft_lot - 0.009879
# floors - 0.0964
# waterfront - 0.030
# view  - 0.12
# condition - 0.0015
# grade - 0.4951
# sqft_above - 0.3621
# sqft_basement - 0.1004
# yr_built = 0.0065
# yr_renovated = 0.013
# zipcode= 0.0014
# lat = 0.2017
# long = 0.00244
# sqft_living15 = 0.3855
# sqft_lot 0.008343
housesales.lm.all <- lm(price ~ ., data=data.train)

# R^2 0.3�̻�
housesales.lm.all <- lm(price ~ bathrooms + sqft_living + grade + sqft_living15, data=data.train)
summary(housesales.lm.all)


# VIFs between two variables
# bathrooms sqft_living 
# 2.322987    2.322987 
# bathrooms     grade 
# 1.792763  1.792763 
# bathrooms sqft_above 
# 1.885705   1.885705 
# bathrooms sqft_living15 
# 1.477858      1.477858 
# sqft_living       grade 
# 2.390732    2.390732
# sqft_living  sqft_above 
# 4.318192    4.318192 
# sqft_living sqft_living15 
# 2.337386      2.337386 
# grade sqft_above 
# 2.333284   2.333284 
# grade sqft_living15 
# 2.035239      2.035239 
# sqft_above sqft_living15 
# 2.153474      2.153474 

# sqft_above ����(���� R^2���� sqft_living�� vif�� ���̱� ����, �׸��� ������� ���� ���� ����)
vif(housesales.lm.all)

# analysis of other variables using factorization
colnames(data.train)

# 1. bedrooms(keep it as factor)
par(mfrow=c(1,1))
boxplot(data.train[ ,"price"] ~ data.train[,"bedrooms"], main = "Price vs. Bedrooms")
# bedrooms 11, 13 ����
print(subset(data.train, data.train$bedrooms > 10))
# bedrooms���� �̻�ġ ����
data.train <- data.train[data.train$bedrooms <= 10,]
data.train$bedrooms <- as.factor(data.train$bedrooms)

data.test <- data.test[data.test$bedrooms <= 10,]
data.test$bedrooms <- as.factor(data.test$bedrooms)

# 2. floors(keep it as factor)
boxplot(data.train[,"price"] ~ data.train[,"floors"], main = "Price vs floors")
data.train$floors <- as.factor(data.train$floors)

data.test$floors <- as.factor(data.test$floors)


# 3. waterfront
boxplot(data.train[,"price"] ~ data.train[,"waterfront"], main = "Price vs waterfront")
print(subset(data.train, data.train$waterfront==0)) #2������
print(subset(data.train, data.train$waterfront==1)) #101��

data.train[data.train$waterfront==0, ]
data.train %>% 
    filter(waterfront==0) %>% 
    select(price) %>% unlist() %>% mean()
data.train %>% 
    filter(waterfront==1) %>% 
    select(price) %>% unlist() %>% mean()
# ��հ��� ���̰� ũ�� factor�� ����
data.train$waterfront <- as.factor(data.train$waterfront)

data.test$waterfront <- as.factor(data.test$waterfront)

# 4. view
boxplot(data.train[,"price"] ~ data.train[,"view"], main = "Price vs floor")
for(i in 0:4){
    data.train %>% 
        filter(view == i) %>% 
        select(price) %>% unlist() %>% mean() %>% print()
}
# 0 : 12.99029
# 1 : 13.46064
# 2 : 13.43744
# 3 : 13.63316
# 4 : 14.01928
# factor�� ����
data.train$view <- as.factor(data.train$view)

data.test$view <- as.factor(data.test$view)

# 5. sqft_above
boxplot(data.train[,"price"] ~ data.train[,"sqft_above"],main = "Price vs sqft_above")
# factor�ϱ⿡ ������ ���� �а� ������ ���߰��꼺 ������ �־����Ƿ� ����
data.train$sqft_above = NULL

data.test$sqft_above = NULL

# 6. sqft_basement
boxplot(data.train[,"price"] ~ data.train[,"sqft_basement"], main = "Price vs sqft_basement")
# price�� ������ �����Ƿ� ����
data.train$sqft_basement = NULL

data.test$sqft_basement = NULL


# 7. yr_built
boxplot(data.train[,"price"] ~ data.train[,"yr_built"], main = "Price vs yr.built")
# price�� ������ �����Ƿ� ����
data.train$yr_built = NULL

data.test$yr_built = NULL


# 8. yr_renovated
boxplot(data.train[,"price"] ~ data.train[,"yr_renovated"], main = "Price vs yr.renovated")
# price�� ������ �����Ƿ� ����
data.train$yr_renovated = NULL

data.test$yr_renovated = NULL

# 9. zipcode
boxplot(data.train[, "price"] ~ data.train[,"zipcode"], main = "Price vs zipcode")
# zipcode���� ���̰� �־� factor�� ����
data.train$zipcode <- as.factor(data.train$zipcode)
# 70 ����
table(data.train$zip) # �����Ͱ����� �ʹ� ���ų� ���� �����Ǿ����� �ʾ� �״�� ����

data.test$zipcode <- as.factor(data.test$zipcode)

  
# 10. lat
boxplot(data.train[, "price"] ~ data.train[, "lat"], main = "Price vs lat")
# �����ؼ� �׳� ��(zipcode�� ���)
data.train$lat = NULL

data.test$lat = NULL

# 11. date ����
data.train$date = NULL

data.test$date = NULL

colnames(data.train)
housesales.lm.final <- lm(price ~ ., data= data.train)

summary(housesales.lm.final)
# 1. ȸ�ͺм��� Ÿ���Ѱ�(Ÿ����)
# F-statistic:  1558 on 93 and 21517 DF,  p-value: < 2.2e-16

# 2. Does each independent variable influence price?(��ŵ)

# 3. prediction(������ ���߿� �ؿ���)

# variable selection : (��� �̰� ��...���⼭�� �Ⱦ��̴µ�)
# 1) FSB
housesales.fsb <- step(housesales.lm.final, direction = "forward")

# 2) BEM
housesales.bem <- step(housesales.lm.final, direction = "backward")


# 3) SSM
housesales.ssm <- step(housesales.lm.final, direction = "both")

summary(housesales.ssm)

car::vif(housesales.lm.final)

# ������������ ����� Ȯ��
lm.beta(housesales.lm.final)

par(mfrow = c(2,2))
plot(housesales.lm.final)
# QQplot���� ������ ������ ������ ������

# 1. ������ ���Լ� ����
ad.test(housesales.lm.final$residuals)
# A = 116.89, p-value < 2.2e-16

# 2. ������ ���� (�̰� ������ r �����ϱ� ������������)
car::durbinWatsonTest(housesales.lm.final)
 # lag Autocorrelation D-W Statistic p-value
# 1      0.01152357      1.976888   0.076


# 3. ��л꼺 ����
car::ncvTest(housesales.lm.final)
# Chisquare = 1.420945    Df = 1     p = 0.2332479 

# 4. ������ ���� �������� ������ ����.
summary(gvlma::gvlma(housesales.lm.final))
#                         Value   p-value                   Decision
#     Global Stat        7570.05 0.0000000 Assumptions NOT satisfied!
#     Skewness            218.54 0.0000000 Assumptions NOT satisfied!
#     Kurtosis           7059.29 0.0000000 Assumptions NOT satisfied!
#     Link Function       280.34 0.0000000 Assumptions NOT satisfied!
#     Heteroscedasticity   11.89 0.0005655 Assumptions NOT satisfied!


# ����
data.predict <- predict(housesales.lm.final, newdata = data.test)

summary(data.predict)
summary(data.test$price)