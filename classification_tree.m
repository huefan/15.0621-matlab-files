cutoff_l=sum(cell_array{1}(cell_array{1}==1))/755;
cutoff_s=sum(cell_array{1}(cell_array{1}==-1))/755;
errorRates=[];

stock_vals=[];

%   t_l=fitrtree(pred,resp_train_l,'PredictorNames',{'open' 'High' 'low' 'close' 'volume' 'pctchange' 'adj_close'});
% % % rs_error_tl = resubLoss(t_l); %resubstitution error, high bad low not necessarily good
%   t_s=fitrtree(pred,resp_train_s,'PredictorNames',{'open' 'High' 'low' 'close' 'volume' 'pctchange' 'adj_close'});
% % % rs_error_ts = resubLoss(t_s);
% view 

% leafs = logspace(0,1.5,10);
% rng('default')
% N = numel(leafs);
% err_l_cv = zeros(N,1);
% err_s_cv = zeros(N,1);
% err_l_rs = zeros(N,1);
% err_s_rs = zeros(N,1);
% for n=1:N
%     t_l_cv = fitctree(pred,resp_train_l,'CrossVal','On',...
%         'MinLeaf',leafs(n));
%     t_s_cv = fitctree(pred,resp_train_s,'CrossVal','On',...
%         'MinLeaf',leafs(n));
%     t_l_rs = fitrtree(pred,resp_train_l,...
%         'MinLeaf',leafs(n));
%     t_s_rs = fitrtree(pred,resp_train_s,...
%         'MinLeaf',leafs(n));
%     err_l_cv(n) = kfoldLoss(t_l_cv);
%     err_s_cv(n) = kfoldLoss(t_s_cv);
%     err_l_rs(n) = resubLoss(t_l_rs);
%     err_s_rs(n) = resubLoss(t_s_rs);
% end
% plot(leafs,err_l_cv,leafs,err_s_cv,leafs,err_l_rs,leafs,err_s_rs);
% xlabel('Min Leaf Size');
% ylabel('cross-validated error');
% legend('long cv','short cv','long rs','short rs');

for (c=3:44)
    try 
        clear OptimalTree_l OptimalTree_s
        pred=trainingset{1,1}(:,2:8);
        resp_train_l=trainingset{1,c}(:,10);
        resp_train_s=trainingset{1,c}(:,11);
        OptimalTree_l = fitctree(pred,resp_train_l,'minleaf',1,'PredictorNames',{'open' 'High' 'low' 'close' 'volume' 'pctchange' 'adj_close'});
        OptimalTree_s = fitctree(pred,resp_train_s,'minleaf',3,'PredictorNames',{'open' 'High' 'low' 'close' 'volume' 'pctchange' 'adj_close'});
        

        
        scores_l_train=predict(OptimalTree_l,trainingset{1,c}(:,2:8));
        scores_s_train=predict(OptimalTree_s,trainingset{1,c}(:,2:8));
 
        scores_l_val=predict(OptimalTree_l,validationset{1,c}(:,2:8));
        scores_s_val=predict(OptimalTree_s,validationset{1,c}(:,2:8));
        
        rng('default');
        [X_train_l,Y_train_l] = perfcurve(trainingset{1,c}(:,10),scores_l_train,1);
        [X_train_s,Y_train_s] = perfcurve(trainingset{1,c}(:,11),scores_s_train,1);
        [X_val_l,Y_val_l] = perfcurve(validationset{1,c}(:,10),scores_l_val,1);
        [X_val_s,Y_val_s] = perfcurve(validationset{1,c}(:,11),scores_s_val,1);
        
        
%         figure(1);
%         plot(X_train_l,Y_train_l);
%         hold on;
%         plot(X_train_s,Y_train_s);
%         hold on;
%         plot(X_val_l,Y_val_l);
%         hold on;
%         plot(X_val_s,Y_val_s);
%         hold on;
%         legend('training long','training short','validation long','validation short');
%         xlabel('False positive rate'); ylabel('True positive rate');
%         
%         
%         figure(2);
%         subplot(1,2,1)
%         title('ROC curve for long')
%         plot(X_val_l,X_val_l);
%         hold on;
%         plot(X_val_l,Y_val_l);
%         hold on;
%         legend('validation long');
%         xlabel('False positive rate'); ylabel('True positive rate');
%         
%         subplot(1,2,2)
%         title('ROC curve for short')
%         plot(X_val_s,X_val_s);
%         hold on;
%         plot(X_val_s,Y_val_s);
%         hold on;
%         legend('validation short');
%         xlabel('False positive rate'); ylabel('True positive rate');
%         
        
        catch ME
     end
 
%  [~,~,~,bestlevel_l] = cvLoss( OptimalTree_l,...
%     'SubTrees','All','TreeSize','min')
%  [~,~,~,bestlevel_s] = cvLoss( OptimalTree_s,...
%     'SubTrees','All','TreeSize','min')
%  view(OptimalTree_l,'mode','graph')
%  view(OptimalTree_s,'mode','graph')





    multiple=0:0.1:15;
    error=nan(1,44);
    correct_l=nan(1,44);
    correct_s=nan(1,44);
       
            for a=1:length(multiple)
            %confusion matrices 
            C_train_l = confusionmat(trainingset{1,c}(:,10),double(scores_l_train>cutoff_l*multiple(a)));
            C_train_s = confusionmat(trainingset{1,c}(:,11),double(scores_s_train>cutoff_s*multiple(a)));
            C_val_l = confusionmat(validationset{1,c}(:,10),double(scores_l_val>cutoff_l*multiple(a)));
            C_val_s = confusionmat(validationset{1,c}(:,11),double(scores_s_val>cutoff_s*multiple(a)));
                if sum(size(C_val_l))==4 &sum(size(C_val_s))==4
                error=[error (C_val_l(1,2)+C_val_l(2,1)+C_val_s(1,2)+C_val_s(2,1))/2/sum(sum(C_val_s))];
                correct_l=[correct_l C_val_l(2,1)/sum(sum(C_val_s))];
                correct_s=[correct_s C_val_s(2,1)/sum(sum(C_val_s))]; 
                end
            end
            
            [min_error_rate,min_idx] = min(error(:));
            [max_correct_l, max_idx_l]=max(correct_l(:));
            [max_correct_s, max_idx_s]=max(correct_s(:));
            stocks_val(1,c)=min_error_rate;
            stocks_val(2,c)=max_correct_l;
            stocks_val(3,c)=max_correct_s;
            stocks_val(4,c)=multiple (min_idx);
%     
 end
% 
    figure (4)
    subplot(3,1,1)
    hist(stocks_val(1,:))
    title('min error rate distribution')
    xlabel('error rate')
    ylabel('frequency')
    subplot(3,1,2)
    hist(stocks_val(2,:))
    title('success rate distribution for long calls')
    xlabel('success rate')
    ylabel('frequency')
    subplot(3,1,3)
    hist(stocks_val(3,:))
    title('success rate distribution for short sell')
    xlabel('success rate')
    ylabel('frequency')
% resubOpt = resubLoss(OptimalTree_l);
% lossOpt = kfoldLoss(crossval(OptimalTree_l));
% resubDefault = resubLoss(t_l);
% lossDefault = kfoldLoss(crossval(t_l));
% resubOpt,resubDefault,lossOpt,lossDefault
%  
% 
% view(t_l,'mode','graph')
% Ynew = predict(tree,Xnew);