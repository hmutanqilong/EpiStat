## kfoldCV with the variable selection
## parameter ##
	# kfold10 �����ֲ�����һ��
## values ##
	#	auc	CV��AUCֵ
	#	varsel ÿ��ɸѡ���ı�������10foldCV��8�����һ�������Բ����б���ɸѡЧ����ֻ��ΪROC����
	#	topn	����top����������һ��RF��ģ+�ⲿԤ��
	# ��Ҫ��ɸѡ��topn=all���
## ��ѵ�������ڲ�ɸѡ������
#####################################################################
kfoldCVsel <- function(X=modelX,Y=modelY,kfold=5,
		topn=c(5,10,20,50,100),ntree=500,seed=20110101) {
	library(randomForest)
	set.seed(seed)
	kfold10 <- sample(rep(1:kfold,ceiling(nrow(X)/kfold))[1:nrow(X)])
	auc.kfold <- matrix(NA,kfold,length(topn))
	varsel <- matrix(NA,max(topn)*2,kfold)
	prob <- matrix(NA,nrow(X),length(topn))
	for ( i in 1:kfold) {
		cat(paste("Fold",i,"...\n")) ##
	## �ܽ�ģ
		set.seed(seed+1000)
		rfvim <- randomForest( X[kfold10 !=i,],Y[kfold10 !=i],importance=T,ntree=ntree)
		## ɸѡ����
		vims <- importance(rfvim,type=1,scale=TRUE)
		uAUC <- uAUCofROC(X=X[kfold10 !=i,], Y=Y[kfold10 !=i]) #ȡ����
		# flag <- sort(vims,decreasing=T,index=T)$ix[1:100]
		# ��ʼѭ��
		for (j in 1:length(topn)) {
			cat(paste("  *","topn=",topn[j],"\n")) ##
			flag <- union(sort(uAUC,decreasing=T,index=T)$ix[1:topn[j]],
				sort(vims,decreasing=T,index=T)$ix[1:topn[j]])
			if (length(flag)>0) {
				cat(paste("   +","nvar.union=",length(flag),"\n"))
				set.seed(seed+2000)
				rfmodel <- randomForest( as.matrix(X[kfold10 !=i,flag]),Y[kfold10 !=i],ntree=ntree)
				rfpred <- predict(rfmodel,as.matrix(X[kfold10 ==i,flag]),type="vote")[,2]
				prob[kfold10 ==i,j] <- rfpred
			} else {
				cat("the intersect length=0.\n")
				auc.kfold[i,j]=NA
			}
			auc.kfold[i,j] <- AUCofROC(rfpred,Y[kfold10 ==i])
			cat(paste("    +","AUC=",round(auc.kfold[i,j],4),"\n")) ##
		}
		varsel[1:length(flag),i] <- flag ## ������Ĳ���
	}
	rownames(auc.kfold) <- paste("fold",1:nrow(auc.kfold),sep="")
	colnames(auc.kfold) <- paste("top",topn,sep="")
  colnames(prob) <- paste("top",topn,sep="")
	result <- list(auc=auc.kfold,varsel=varsel,prob=prob,seed=seed)
	return(result)
}
# rfmodel <- svm( as.matrix(X[kfold10 !=i,flag]),Y[kfold10 !=i],probability = TRUE)
# rfpred <- predict(rfmodel,as.matrix(X[kfold10 ==i,flag]),probability = TRUE)
# prob[kfold10 ==i,1] <- attr(rfpred , "probabilities")[,1]

## fold5.auc <- kfoldCVsel(X=modelX,Y=modelY,kfold=5,
#		topn=c(5,10,20,50,100),ntree=500,seed=20110101)