% 
% tbl =array2table(cell_array{1}(1:503,2:11),'VariableNames',{'open','low','high','close','volume','pctchange','adj_close','action','long','short'});
% tbl(1:503,8)=array2table(cell_array{1}(1:503,9));
% 
model={'logit', 'probit', 'comploglog', 'loglog'};

stocks_val=zeros(4,44);
stock_vals=[];
for (b=1:4)
    for (c=[1:44])
     try
        cutoff_l=sum(cell_array{c}(cell_array{1}==1))/755;
        cutoff_s=sum(cell_array{c}(cell_array{1}==-1))/755;
        
        clear mdl_l mdl_s
        % trainingset=cell(size(cell_array));
        % validationset=cell(size(cell_array));
        % for i=1:44
        %     trainingset{1,i}=cell_array{1,i}(1:503,:);
        %     validationset{1,i}=cell_array{1,i}(504:755,:);
        % end



        pred=trainingset{1,c}(:,2:8);
        resp_train_l=trainingset{1,c}(:,10);
        resp_train_s=trainingset{1,c}(:,11);


        %regression
        mdl_l = fitglm(pred,resp_train_l,'Distribution','binomial','Link',model{b});
        mdl_s = fitglm(pred,resp_train_s,'Distribution','binomial','Link',model{b});

        [scores_l_val,ynewci_l] = predict(mdl_l,validationset{1,c}(:,2:8));
        [scores_s_val,ynewci_s] = predict(mdl_s,validationset{1,c}(:,2:8));

        scores_l_train = mdl_l.Fitted.Probability;
        scores_s_train = mdl_s.Fitted.Probability;

        rng('default');
        [X_train_l,Y_train_l] = perfcurve(trainingset{1,1}(:,10),scores_l_train,1);
        [X_train_s,Y_train_s] = perfcurve(trainingset{1,1}(:,11),scores_s_train,1);
        [X_val_l,Y_val_l] = perfcurve(validationset{1,1}(:,10),scores_l_val,1);
        [X_val_s,Y_val_s] = perfcurve(validationset{1,1}(:,11),scores_s_val,1);
        
        figure(1);
        subplot(2,2,b)
        title (model{b});
%         plot(X_train_l,Y_train_l);
%         hold on;
%         plot(X_train_s,Y_train_s);
%         hold on;
        plot(X_val_l,Y_val_l);
        hold on;
% %         plot(X_val_s,Y_val_s);
%         hold on;
        plot(X_val_s,X_val_s);
        legend('validation long','base curve');
        xlabel('False positive rate'); ylabel('True positive rate');
        
        
        
        figure(2);
        subplot(2,2,b)
        title (model{b});
        plot(X_val_s,Y_val_s);
        hold on;
        plot(X_val_s,X_val_s);
        legend('validation short','base curve');
        xlabel('False positive rate'); ylabel('True positive rate');
     catch ME
     end
        multiple=0:0.1:15;
        error=[];
        correct_l=[];
        correct_s=[];
        for a=1:length(multiple)
        %confusion matrices 
        [C_train_l,trash] = confusionmat(trainingset{1,1}(:,10),double(scores_l_train>cutoff_l*multiple(a)));
        [C_train_s,trash] = confusionmat(trainingset{1,1}(:,11),double(scores_s_train>cutoff_s*multiple(a)));
        [C_val_l,trash] = confusionmat(validationset{1,1}(:,10),double(scores_l_val>cutoff_l*multiple(a)));
        [C_val_s,trash] = confusionmat(validationset{1,1}(:,11),double(scores_s_val>cutoff_s*multiple(a)));

        error=[error (C_val_l(1,2)+C_val_l(2,1)+C_val_s(1,2)+C_val_s(2,1))/2/sum(sum(C_val_s))];
        correct_l=[correct_l C_val_l(2,1)/sum(validationset{1,c}(:,10))];
        correct_s=[correct_s C_val_s(2,1)/sum(validationset{1,c}(:,11))];
        end
        [min_error_rate,min_idx] = min(error(:));
        [max_correct_l, max_idx_l]=max(correct_l(:));
        [max_correct_s, max_idx_s]=max(correct_s(:));
        stocks_val(1,c)=min_error_rate;
        stocks_val(2,c)=max_correct_l;
        stocks_val(3,c)=max_correct_s;
        stocks_val(4,c)=multiple (min_idx);
    end
    stock_vals=[stock_vals stocks_val];
    
    figure (3)
    subplot(3,1,1)
    hist(stocks_val(1,:))
    title('min error rate distribution')
    xlabel('error rate')
    ylabel('frequency')
    subplot(3,1,2)
    hist(stocks_val(2,:)/5)
    title('success rate distribution for long calls')
    xlabel('success rate')
    ylabel('frequency')
    subplot(3,1,3)
    hist(stocks_val(3,:))
    title('success rate distribution for short sell')
    xlabel('success rate')
    ylabel('frequency')
    
    
end
% for j=1:length(predicted)
%     if predicted(j,1)>cutoff_long
%         predicted(j,1)=1;
%     elseif predicted(j,1)<cutoff_short
%             predicted(j,1)=-1;
%     else predicted(j,1)=0;
%     end
% end
% training=[cell_array{1}(1:503,9) predicted(1:503,1)];
% validation=[cell_array{1}(504:755,9) predicted(504:755,1)];
% [training_confusion,order1]=confusionmat(training(:,1),training(:,2));
% [validation_confusion, order2]=confusionmat(validation(:,1),training(:,2));

% A=[];
% for k=1:44
%     tickers(2,k)=num2cell(nanmean(cell_array{1,k}(:,6))); 
% end
% [trash idx] = sort([tickers{2,:}], 'descend');
% tickers(:,idx)
% % random_assign=nan(755,1);

% 
% for k=1:44
%    cell_array{1,k}(:,10)=zeros(755,1);
%    cell_array{1,k}(:,11)=zeros(755,1);
%    A=find(cell_array{1,k}(:,9)==1);
%    for j=1:length(A)
%        cell_array{1,k}(A(j),10)=1;
%    end
%    B=find(cell_array{1,k}(:,9)<0);
%    for l=1:length(B)
%        cell_array{1,k}(B(l),11)=1;
%    end
% end