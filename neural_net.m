
% c=13;
error_l=[];
error_s=[];
success_l=[];
success_s=[];
stocks_val=[];
  for c=1:44
    pred=trainingset{1,c}(:,2:8);
    resp_train_l=trainingset{1,c}(:,10);
    resp_train_s=trainingset{1,c}(:,11);

    x=pred.';%predictors
    t=resp_train_l.';%target
    setdemorandstream(391418381);

        clear net testX testT;
        net = patternnet(1);
%         view(net);
        [net,tr] = train(net,x,t);
%         nntraintool
%         plotperform(tr);


        testX = validationset{1,c}(:,2:8).';
        testT_l = validationset{1,c}(:,10).';
        testT_s = validationset{1,c}(:,11).';
        
        
        testY_l = net(testX);
        testY_s = net(testX);
        testIndices_l = vec2ind(testY_l);
        testIndices_s = vec2ind(testY_s);   
%         plotconfusion(testT,testY)

        [l,cm_l] = confusion(testT_l,testY_l);
        [s,cm_s] = confusion(testT_s,testY_s)
        
        error_l=[error_l l];
        success_l=[success_l cm_l(2,2)/sum(validationset{1,c}(:,10))];
        error_s=[error_s s];
        success_s=[success_s cm_s(2,2)/sum(validationset{1,c}(:,11))];
%         fprintf('Percentage Correct Classification   : %f%%\n', 100*(1-c));
%         fprintf('Percentage Incorrect Classification : %f%%\n', 100*c);
        
         figure (1)
         plotroc(testT_l,testY_l)
%         plotroc(testT_s,testY_s)
         hold on

     [min_error_rate_l,min_idx_l] = min(error_l(:));
     [min_error_rate_s,min_idx_s] = min(error_s(:));
     [max_correct_l, max_idx_l]=max(success_l);
     [max_correct_s, max_idx_s]=max(success_s);
%      stocks_val(1,c)=min_error_rate_l;
%      stocks_val(2,c)=min_error_rate_s;
%      stocks_val(3,c)=max_correct_l;
%      stocks_val(4,c)=max_correct_s;

  end 

     
     figure (4)
    subplot(2,2,1)
    hist(error_l)
    title('min error rate distribution for long calls')
    xlabel('error rate')
    ylabel('frequency')
    subplot(2,2,2)
    hist(error_s)
    title('min error rate distribution for short calls')
    xlabel('error rate')
    ylabel('frequency')
    subplot(2,2,3)
    hist(success_l)
    title('success rate distribution for long calls')
    xlabel('success rate')
    ylabel('frequency')
    subplot(2,2,4)
    hist(success_s)
    title('success rate distribution for short sell')
    xlabel('success rate')
    ylabel('frequency')