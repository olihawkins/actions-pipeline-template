# actions-pipeline-template

A template for deploying a `targets` pipeline with GitHub Actions.

## How to use this template

1. From the template [github page](https://github.com/olihawkins/actions-pipeline-template) click the green 'Use this template' button at the top. Create a new repo with your project name and then clone it onto your local machine.

2. Change the name of the `actions-pipeline-template.Rproj` file to match your new repository name.

3. Restore the environment with `renv::restore()`.

4. Define the functions your pipeline will use in script files in the `R` directory, then define the pipeline itself in `_targets.R`. See below for guidance on using `targets`. This template repo provides an example implementation which downloads and processes some data from a dummy JSON API.

5. Update `.github/workflows/run-pipeline.yml` to specify when to run the pipeline. By default it will run on push, but you can uncomment the lines specifying a `schedule` to run it as a cron job.

6. The workflow is designed to build a package cache, so while first time you run the pipeline will be slow, subsequent runs will be much quicker. The example pipeline takes around 11 minutes on the first run and around 1-2 minutes on subsequent runs.

## How the pipeline works

GitHub Actions runs the pipeline inside a virtual server. Any files that your R pipeline creates in the `dist` folder will be committed back to the repository when the pipeline finishes its run.

The `dist` folder **must** exist in the GitHub repo, and that by default git won't push an empty folder to GitHub. This is why `dist` contains a redundant `.gitignore` file: it ensures that the folder is pushed to GitHub from your local repo.

## Updating the pipeline

If you need to update the pipeline after it has run on Github, remember to **pull the latest version from Github to your local machine before updating the code**. This is because the Github repo will contain different data in the `dist` folder than your local repo. This is an unavoidable feature of this kind of circular workflow, where data collected by Github Actions is committed back into the online repo.

## How to schedule the pipeline

You can schedule the pipeline using the settings in [run-pipeline.yml](.github/workflows/run-pipeline.yml). Uncomment the two lines that begin `schedule` and use crontab syntax to specify how often it should run. If you are not familiar with crontab syntax, see this [guide](https://jasonet.co/posts/scheduled-actions/).

## Using `targets`

For guidance on configuring a targets pipeline please see the [online manual](https://books.ropensci.org/targets/). A complete function reference can be found in the [official documentation](https://docs.ropensci.org/targets/).

Commonly used functions include:

- `tar_manifest` - Check the pipeline
- `tar_visnetwork` - Visualise the pipeline
- `tar_meta` - Show the metadata for a target
- `tar_invalidate` - Delete the metadata for a target
- `tar_make` - Build the pipeline
- `tar_read` - Read the output of a target

## GitHub Actions used in the workflow for this project

- [actions/cache@v3](https://github.com/actions/cache)
- [r-lib/actions/setup-r@v2](https://github.com/r-lib/actions/tree/v2-branch/setup-r)
- [r-lib/actions/setup-renv@v2](https://github.com/r-lib/actions/tree/v2-branch/setup-renv)
- [stefanzweifel/git-auto-commit-action@v4](https://github.com/stefanzweifel/git-auto-commit-action)