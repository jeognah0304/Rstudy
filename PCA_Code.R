
#_________________________________________________________________________
#  0. road the data & packages

setwd("C:\\Users\\parkjeongah\\Desktop\\working\\�濵����\\Business analytics")
data = read.csv(file="data.csv")

library(aod)
library(ggplot2)

#_________________________________________________________________________
#  before regression, PCA
# reason : The amount of calls at the peak time -> fractional.

library(MVA)
library(psych)

# made peack time data
X_peak = cbind(data$x.variable_names)

y = data$y.variable_name

dim(X_peak)

#plot
#pairs.panels(X_peak) �׸��� ������.
cor = cor(X_peak) # correlation�� ���ƺ���.

library(corrplot)
corrplot::corrplot(cor, method= "color", order = "hclust", tl.pos = 'n')


#making normalization

#define function
normalization <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

X_peak <- normalization(X_peak)
y <- normalization(y)

pca_c = prcomp(X_peak) #���л�����̿�
summary(pca_c) # �����⿩���� 89.7%�ΰű��� ����->PC7��������
pca_c


pca_r = prcomp(X_peak, scale=T) #�������̿�
summary(pca_r) # �����⿩���� 85.8%�ΰű��� ����->PC6��������


pca_c$sdev # ������.
pca_r$sdev # ������.


pca_c$rotation[,1] # ��������=�� �ּ����� rotation ��.
pc1 = pca_c$x[,1]
pc2 = pca_c$x[,2]

cor(pc1,pc2) # pc1, pc2�� ���л��� ���� 0������

X_peak_s = scale(X_peak)
summary(X_peak_s)

rot1 = pca_c$rotation[,1]
rot1

plot(X_peak_s%*%rot1, pca_c$x[, 1]) # �������üũ-> ������踦 ����.



screeplot(pca_c, type = "l") # ������ �ּ����� �������� üũ =3����ɵ�.
#2-3 ������ üũ?

install_github("vqv/ggbiplot")
library(devtools)
library(ggbiplot)
biplot(pca_c)
biplot(pca_r)

par(mfrow=c(1,2))
barplot(pca_c$rotation[,1], col = rainbow(8), ylim = c(-0.1,0.8), las = 2, main = "PC1")
abline(h = -0.3, col="blue")
barplot(pca_c$rotation[,2], col = rainbow(8), ylim = c(-0.6,0.8), las = 2, main = "PC2")
abline(h = 0.3, col="blue")
