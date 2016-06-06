#####################################################################
## k-fold CV|loocv without variable selection
## time 2011-04-18, by tao zhang
## parameter ##
	# kfold10 �����ֲ�����һ��
## values ##
	#	prob
	#	auc	CV��AUCֵ
# ��Xֻ��һ�е�ʱ�����ױ���,as.matrix()
#####################################################################
kfoldCV <- function(X=modelX,
		Y=modelY,
		kfold=5,	# ������֤������nrow(X)��ʾLOOCV��һ��
		model="rf",	# ��ģ������RF��SVM����
		seed=20110101,	# RF��ģ��������
		verbose=1 #�Ƿ���ʾ
	) {
## package
	library(pROC)
	X <- as.data.frame(X)
	set.seed(seed)
	kfold10 <- sample(rep(1:kfold,ceiling(nrow(X)/kfold))[1:nrow(X)])
	prob <- matrix(NA,nrow(X),1)
	for ( i in 1:kfold) {
		if (verbose==1){
			if (kfold==nrow(X)) cat(paste("loocv",i,".\n")) ##
			else cat(paste("fold",i,".\n")) ##
		}
		## �ܽ�ģ
		if (model=="rf"){
			library(randomForest)
			set.seed(seed+1000)
			rfvim <- randomForest(as.matrix(X[kfold10 !=i,]),
				Y[kfold10 !=i],importance=T,ntree=2000)
			prob[kfold10 ==i,1] <- predict(rfvim,as.matrix(X[kfold10 ==i,]),
				type="vote")[,2]
		}
		if (model=="svm") {
			library(e1071)
			svmmodel <- svm( as.matrix(X[kfold10 !=i,]),
				Y[kfold10 !=i],probability = TRUE)
			svmpred <- predict(svmmodel,as.matrix(X[kfold10 ==i,]),probability = TRUE)
			prob[kfold10 ==i,1] <- attr(svmpred , "probabilities")[,1]
		}
	}
	auc <- auc(Y,prob)
	result <- list(prob=prob,auc=auc,seed=seed)
	return(result)
}
# kfoldCV(X=modelX,Y=modelY,kfold=5,model="rf")
