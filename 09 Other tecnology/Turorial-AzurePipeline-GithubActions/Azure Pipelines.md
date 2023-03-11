# Azure Pipelines for R users

## Steps to follow

### 1. Define when to run the script

The execution options are under `on:`

- [workflow_dispatch:](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#workflow_dispatch) Start when pressing a button (optinal).
- **schedule/- cron:** Run the workflow at "Minute Hours MonthDay Month WeekDay". As it can be confusing, we can [crontab guru](https://crontab.guru/) to assist the definition/

![](github-actions-img/crontab-guru.png){width=60% height=60% fig-align="center"}

```
on: 
  workflow_dispatch:
  schedule: 
  - cron: "0 20 * * 1-5"
```

### 2. Name the workflow

```
name: hello-r-world
```

### 3. Define the enveroment

```
jobs:
  execute-r-script:
    runs-on: ubuntu-latest
```

### 4. Setting up the enveroment

Under `jobs/execute-r-script` we need to define the steps to apply. This section depend of other reports like:

- [actions/checkout](https://github.com/actions/checkout): This action checks-out your repository under $GITHUB_WORKSPACE, so your workflow can access it.
- [r-lib/actions/setup-r](https://github.com/r-lib/actions/tree/v2/setup-r): This action sets up an R environment for use in actions.
- [r-lib/actions/setup-renv](https://github.com/r-lib/actions/tree/v2/setup-renv): This action installs dependencies for the current R environment based on the renv lockfile in the repository.


```
jobs:
  execute-r-script:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: r-lib/actions/setup-r@v2
        with: 
          r-version: 4.2.0
```


### 5. Run the script

To run the script we have the next options:

- **Rscript:** Runs an R script file.
- **Rscript -e '':** Runs any R function.

```
jobs:
  execute-r-script:
    steps:
      - name: run-script
        run: Rscript my_awesome_R_script.R # OR run: Rscript -e 'source("my_awesome_R_script.R")' 
```

### 6. Save the yaml file

After completing all the steps we need to save the result in `.github/workflows/my_flow_name.yaml`.

```
on: 
  workflow_dispatch: 
  schedule: 
  - cron: "0 20 * * 1-5"
  
name: hello-r-world

jobs:
  execute-r-script:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: r-lib/actions/setup-r@v2
        with: 
          r-version: 4.2.0    
      - name: run-script
        run: Rscript my_awesome_R_script.R
```
