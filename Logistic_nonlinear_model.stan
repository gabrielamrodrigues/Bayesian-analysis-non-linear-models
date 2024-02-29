mod_logistic = 'data{
  int<lower=0> N;
  vector[N] y;
  vector[N] x;
}
parameters{
  real<lower=0> beta1;
  real beta2;
  real<lower=0> beta3;
  real<lower=0> sigma;
}
transformed parameters{
  real mu[N];
  for (i in 1:N) 
     mu[i] = beta1/(1+exp((beta2-x[i])/beta3));
}
model{
  beta1 ~ inv_gamma(5, 50);
  beta2 ~ normal(0, 1000);
  beta3 ~ inv_gamma(5, 50);
  sigma ~ inv_gamma(5, 50);  
  target += normal_lpdf(y | mu, sigma);
}
generated quantities{
  real Y_mean[N]; 
  real Y_pred[N]; 
  real log_lik[N];
  for(i in 1:N){
    // Posterior parameter distribution of the mean
    Y_mean[i] = beta1/(1+exp((beta2-x[i])/beta3));
    // Posterior predictive distribution
    Y_pred[i] = normal_rng(Y_mean[i], sigma);   
}
  for (n in 1:N){
    log_lik[n] = normal_lpdf(y[n] | Y_mean[n],
                             sigma);

  }
}'

stan(model_code = mod_logistic, data=list(N = length(y), x = x, y = y),
                       chains = 3,
                       iter = 11000,
                       warmup = 1000,
                       thin = 10,
                       refresh=0)
