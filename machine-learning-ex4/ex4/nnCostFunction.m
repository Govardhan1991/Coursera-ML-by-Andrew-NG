function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = 0;
Theta2 = 0;
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
a2 = size(Theta1, 1);
a3 = size(Theta2, 1);

X = [ones(m, 1) X];


% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


for i=1:m
    for j=1:size(Theta1, 1)
        a2(j) = sigmoid(sum(X(i,:).*Theta1(j,:)));
    end
    
    a2New = [1 a2];
    
    for j=1:size(Theta2, 1)
        a3(j) = sigmoid(sum(a2New.*Theta2(j,:)));
    end
    
    y_vec = zeros(size(Theta2, 1),1);
    y_vec(y(i))=1;
    J = J+sum(((-y_vec'.*log(a3))-((1-y_vec').*log(1-a3))));
end

J = 1/m*J;
regTerm=0;
for j=1:size(Theta1,1)
    for k=2:size(Theta1,2)
        regTerm=regTerm+Theta1(j,k)*Theta1(j,k);
    end
end

for j=1:size(Theta2,1)
    for k=2:size(Theta2,2)
        regTerm=regTerm+Theta2(j,k)*Theta2(j,k);
    end
end
regTerm = lambda/(2*m) * regTerm;
J=J+regTerm;
% -------------------------------------------------------------

Delta_2 = zeros(size(Theta2, 1), size(Theta2, 2));
Delta_1 = zeros(size(Theta1, 1), size(Theta1, 2));

noBiasTheta2 = Theta2(:, 2:end);

for i=1:m
    a1 = X(i,2:end)';
    a1New = [1;a1];
    a2 = sigmoid(Theta1 * a1New);
    a2New = [1;a2];    
    
    a3 = sigmoid(Theta2*a2New);
    
    y_vec = zeros(size(Theta2, 1),1);
    y_vec(y(i))=1;
    
    smallDelta3 = a3-y_vec;
    
    v2 = sigmoidGradient(Theta1*a1New);
    v3 = noBiasTheta2' * smallDelta3;
    smallDelta2 = v3 .* v2;
    
    Delta_2 = Delta_2 + smallDelta3 * a2New';
    Delta_1 = Delta_1 + smallDelta2 * a1New';
    
    %END of Back propogation
   
end

Delta_2 = 1/m * Delta_2;
Delta_1 = 1/m * Delta_1;

Theta2_grad = Delta_2;
Theta1_grad = Delta_1;

% ========================== Regularization ==============================%

for i = 1:size(Theta1_grad, 1)
    for j = 2:size(Theta1_grad, 2)
        Theta1_grad(i,j) = Theta1_grad(i,j)+ lambda/m * Theta1(i,j);
    end
end

for i = 1:size(Theta2_grad, 1)
    for j = 2:size(Theta2_grad, 2)
        Theta2_grad(i,j) = Theta2_grad(i,j)+ lambda/m * Theta2(i,j);
    end
end
% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];

end
