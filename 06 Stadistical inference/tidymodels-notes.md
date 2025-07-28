# Tidymodels notes


## Steps for modeling

1.  **Collect Data.**

``` r
library(tidymodels)
data(cells)
cells_data <- cells %>% select(-case)
```

2.  **Split the training and testing data.**

``` r
set.seed(502)
cells_split <- initial_split(cells_data, prop = 0.80, strata = Sale_Price)
cells_train <- training(cells_split)
cells_test  <-  testing(cells_split)
```

3.  **Creating folds.**

``` r
set.seed(1304)
cell_folds <- vfold_cv(cells)
```

### Comparing within-model

To create must of the code for this part we can use:

``` r
# devtools::install_github("tidymodels/usemodels")
library(usemodels)

use_xgboost(Sale_Price ~ Neighborhood + Gr_Liv_Area + Year_Built +
                         Bldg_Type + Latitude + Longitude, 
            data = ames_train,
            # Add comments explaining some of the code:
            verbose = TRUE)
```

4.  **Define the model to train with params to tune.**

Take in consideration

- We don’t need to tune **counterexample** like:

  - **Prior distribution** required for Bayesian analysis,as our prior
    beliefs should not be subject to optimization.

  - The **number of trees** in a random forest or bagging model (large
    enough to ensure **numerical stability** in the results)

    - **Random forests**: Start with 10 times the number of features.
      It’s value is typically in the thousands.
    - **Bagging**: Use around 50 to 100 as the error is stabilizing with
      just over 100.

- Some models can use a single fit to evaluate many submodels for the
  next params and engines:

| Model Type           | Argument  | Engines                 |
|----------------------|-----------|-------------------------|
| nearest_neighbor     | neighbors | kknn                    |
| cubist_rules         | neighbors | Cubist                  |
| pls                  | num_comp  | mixOmics                |
| discrim_flexible     | num_terms | earth                   |
| mars                 | num_terms | earth                   |
| linear_reg           | penalty   | glmnet                  |
| logistic_reg         | penalty   | glmnet                  |
| multinom_reg         | penalty   | glmnet                  |
| poisson_reg          | penalty   | glmnet                  |
| proportional_hazards | penalty   | glmnet                  |
| rule_fit             | penalty   | xrf                     |
| boost_tree           | trees     | xgboost, C5.0, lightgbm |
| C5_rules             | trees     | C5.0                    |

``` r
mlp_spec <- 
  mlp(hidden_units = tune(), penalty = tune(), epochs = tune()) %>% 
  set_engine("nnet", trace = 0) %>% 
  set_mode("classification")
```

5.  **Define the recipe with params to tune.**

Use `add_role()`, `remove_role()` or `update_role()` to keep that column
in the data aren’t predictors or outcomes like id or street address.

``` r
mlp_rec <-
  recipe(class ~ ., data = cells_train) %>%
  step_YeoJohnson(all_numeric_predictors()) %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_pca(all_numeric_predictors(), num_comp = tune()) %>% 
  step_normalize(all_numeric_predictors())
```

6.  **Create a workflow.**

``` r
mlp_wflow <- 
  workflow() %>% 
  add_model(mlp_spec) %>% 
  add_recipe(mlp_rec)
```

7.  **Create the parameter object to adjust a few of the default
    ranges.**

- Enumerate the tuning parameters for an object.

- Update the tune range **in place**.

  - zero PCA components is a shortcut to skip the feature extraction

``` r
mlp_param <- 
  mlp_wflow %>% 
  extract_parameter_set_dials() %>% 
  update(
    epochs = epochs(c(50, 200)),
    num_comp = num_comp(c(0, 40))
  )
```

8.  **Use `finalize()` if the parameter range cannot be assumed**

``` r
rf_spec <- 
  rand_forest(mtry = tune()) %>% 
  set_engine("ranger", regularization.factor = tune("regularization")) %>%
  set_mode("regression")
  
pca_rec <- 
  recipe(Sale_Price ~ ., data = ames_train) %>% 
  # Select the square-footage predictors and extract their PCA components:
  step_normalize(contains("SF")) %>% 
  # Select the number of components needed to capture 95% of
  # the variance in the predictors. 
  step_pca(contains("SF"), threshold = .95)
  
updated_param <- 
  workflow() %>% 
  add_model(rf_spec) %>% 
  add_recipe(pca_rec) %>% 
  extract_parameter_set_dials() %>% 
  finalize(ames_train)
  
updated_param
#> Collection of 2 parameters for tuning
#> 
#>      identifier                  type    object
#>            mtry                  mtry nparam[+]
#>  regularization regularization.factor nparam[+]
```

9.  **Define a palatalization strategy.**

- Define the number of possible independent processes that can be
  simultaneously used:

``` r
parallelly::availableCores()
```

- If the preprocessing (recipe) is **extremely fast**, its better **to
  parallelize over each unique tuning parameter combination** to
  increase the number of potential workers that can be used.

``` r
defined_control_grid  <- control_grid(parallel_over = "everything")
```

- If the preprocessing (recipe) is **slow**, its better **to parallelize
  over resamples** to preprocess the data once per fold.

``` r
defined_control_grid  <- control_grid(parallel_over = "resamples")
```

- Define the backend to leverage the parallel process.

  - **multicore**: More memory-efficient for read-heavy tasks because
    **unmodified data is shared across processes**.
    - Not with GUIs like RStudio
    - Not on Windows
    - It can be confirmed with `parallelly::supportsMulticore()`
  - **multisession**: Requires more memory since each process gets a
    full copy of the data while keeping the original data.

``` r
library(future)

plan(multicore, workers = 2)

plan(multisession, workers = 2) 
plan(future.mirai::mirai_multisession, workers = 2)
```

> [!NOTE]
>
> - To make sure that the correct packages are loaded (but not attached)
>   in the workers is to use the pkg option in `control_grid()`.
>
> - Not use variables in the global environment.
>
> ``` r
> num_pcs <- 3
>
> recipe(mpg ~ ., data = mtcars) %>% 
>   # Good since the value is injected into the object
>   step_pca(all_predictors(), num_comp = !!num_pcs)
> ```

10. **Tune the created grid.**

- Try to **evaluate the models over multiple metrics** so that different
  aspects of the model fit are taken into account.

``` r
# The effect of each parameter is better isolated with regular grids.
roc_res <- metric_set(roc_auc)
set.seed(1305)
mlp_reg_tune <-
  mlp_wflow %>%
  tune_grid(
    cell_folds,
    grid = mlp_param %>% grid_regular(levels = 3),
    metrics = roc_res,
    control = defined_control_grid
  )
```

11. **Switch back to sequential processing.**

``` r
plan(sequential)
```

12. **Explore the effect of variables.**

- It often makes sense to choose a slightly suboptimal parameter
  combination that is associated with a simpler model.

``` r
autoplot(mlp_reg_tune) + 
  scale_color_viridis_d(direction = -1) + 
  theme(legend.position = "top")
  
show_best(mlp_reg_tune) %>% select(-.estimator)
```

13. **Selecting the best case.**

``` r
logistic_param <- select_best(mlp_reg_tune, metric = "roc_auc")

# OR we can do it manually
logistic_param <- 
  tibble(
    num_comp = 0,
    epochs = 125,
    hidden_units = 1,
    penalty = 1
  )

final_mlp_wflow <- 
  mlp_wflow %>% 
  finalize_workflow(logistic_param)
```

### Comparing between-model

**Create a workflowset with the tuned models**.

``` r
lm_models <- workflow_set(preproc, list(lm = linear_reg()), cross = FALSE)

lm_models <- 
  lm_models %>% 
  workflow_map("fit_resamples", 
               # Options to `workflow_map()`: 
               seed = 1101, verbose = TRUE,
               # Options to `fit_resamples()`: 
               resamples = ames_folds, control = keep_pred)

four_models <- 
  as_workflow_set(random_forest = rf_res) %>% 
  bind_rows(lm_models)
```

**Explore the performance of several models.**

``` r
library(ggrepel)
autoplot(four_models, metric = "rsq") +
  geom_text_repel(aes(label = wflow_id), nudge_x = 1/8, nudge_y = 1/100) +
  theme(legend.position = "none")
```

### Final model

**Fitting a final model.**

``` r
final_mlp_fit <- 
  final_mlp_wflow %>% 
  fit(cells)
```

**Evaluating vs testing data**

``` r
final_mlp_fit <- 
  final_mlp_wflow %>% 
  fit(cells)
```
