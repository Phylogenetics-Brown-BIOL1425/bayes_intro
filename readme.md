# Bayes Intro

This repository introduces bayesian phylogenetics with [revbayes](http://revbayes.github.io/). It is based on the excellent [lab](https://molevol.mbl.edu/index.php/RevBayes) at the [Workshop on Molecular Evolution](https://molevol.mbl.edu/index.php/Main_Page) by Tracy Heath and Michael Landis.

## Installing RevBayes

### Mac

If you don't already have one, create a `~/bin` folder:

    cd ~
    ls
    mkdir bin

Download the mac version of RevBayes from [here](http://revbayes.github.io/code.html), and then copy the `rb` file to the `bin` file you created above.

Next, create a `~/lib` folder if you don't already have one:

    cd ~
    ls
    mkdir bin

And copy the `boost_1_55_0` folder from the RevBayes download to this `~/lib` folder.

Add the following lines to `~/.bash_profile` (create this file if it doesn't already exist):

    export PATH=$PATH:~/bin
    export DYLD_LIBRARY_PATH=~/lib/boost_1_55_0/stage/lib


### Linux

You can run the analyses on oscar. Load the revbayes module with `module load revbayes`. Do not run our analyses on the login node - [create a batch script or run the analyses in interactive mode](https://web1.ccv.brown.edu/doc/running-jobs.html).

To install revbayes on your own linux machine, compile from the [source](https://github.com/revbayes/revbayes).

## Introduction

Fork and clone this repository. `cd` to the repository directory on your computer. Answer the questions in the readme right in this file. Send a pull request when the assignment is complete.

See `RB_CTMC_Tutorial_unconstrained.pdf` for a step-by step description of the analyses. These analyses have been slightly modified here to accommodate different software versions and to demonstrate additional concepts. 

Each of the analyses scripts, which end with the `.Rev` extension, have a `q()` command at the end that closes revbayes when the analysis is complete. You can comment this out with a `#` if you prefer to leave the analysis open when it is complete and explore the variables created by the analysis.

### Interpreting the output

Each of these scripts are set up to produce two independent runs for each analysis. For now we will inspect the results of each run independently (new revbayes features are on the way that will make it easier to combine results from multiple runs).

The revbayes output will be in a new `output` folder. For each run, the following three files are generated:

- `.log` monitors the parameter estimates. There is one line per sample.

- `.trees` monitors the tree topology and branch lengths. There is one line per sample.

- `.tree` is a summary of the post-burnin posterior distribution of the trees. It is a consensus tree, with the frequency of each bipartition recorded as the node label "posterior". 

Inspect the `.log` files with [Tracer](http://tree.bio.ed.ac.uk/software/tracer/). In the "Trace Files" pane click the "+" to add `.log` files. You can set the number of samples to burn-in in the "Burn-in" column. Once you have the files open, click one or more that you want to high at the same time. In "Traces:", select the parameter that you want to look at. On the right, the "Trace" pane shows the sample values through time. The "Marginal Prob Distribution" pane is a good way to compare multiple posterior distributions from different `.log` files at the same time.

Inspect  the `.tree` file with [FigTree](http://tree.bio.ed.ac.uk/software/figtree/) or another tree viewer.

As an alternative to the programs above, you can use R to view the trees and log files.

### Generations, samples, and burnin

The number of generations that the analysis runs is specified to the `.run()` function, for example:

    mymcmc.run(generations=40000)

The sampling frequency is specified when setting up the monitors that record the analyses with the argument `printgen=10`, which in this case records the topology to the `.trees` files and the parameter estimates to the `.log` files every 10 generations.

A 40000 generation analysis recorded every 10 generations will result in 4000 samples from the posterior distribution. 

Keep in mind the difference between generations and samples. If a sample is taken every 10 generations, then discarding the first 1000 trees removes the results of the first 10000 generations from the analysis. Some functions, typically before the analysis is run, consider the number of generations, eg:

    mymcmc.burnin(generations=10000,tuningInterval=1000)

Other functions, particularly after the run, consider the number of samples:

    map_tree1 = mapTree(treetrace1,"output/primates_cytb_JC_run_1.tree", burnin=1000)

Both of the above commands remove the first 1000 trees corresponding to the first 10000 generations. When you look at the `.trees` and `.log` files, each line corresponds to a sample.

In the analyses presented here, we won't burn in the runs before we start sampling. Instead, we will sample right away and discard the burnin later  by specifying a burnin to the `mapTree()` function. This allows us to see the parameter trace that was generated during the burnin. 

Once the analysis is done, the `mapTree()` function can summarize the trees from the posterior distribution. 


## Jukes Cantor analysis

Examine the relationships of the primates under the JC model. Run the `JukesCantor.Rev` script with the following command:

    rb JukesCantor.Rev

Inspect the parameter traces. Was 1000 samples (corresponding to 10000 generations) a sufficient burn in?

Yes, it seems like that was a sufficient burn in -- the traces don't jump around or anything the way we discussed in class that they might if you didn't have a long enough burn in and it found a new, better peak midway through or something. 


Compare the parameter estimates and trees from the two different runs. Did the runs converge (ie, are the trees and parameters drawn from the same posterior distribution)?

Yes, the runs seemed to converge pretty strongly, the distributions/peaks match up really well when you look at them overlapping in the marginal probability distribution tab, and the trees coming up with the same topology. 


## GTR analysis

Now run the gtr analyses with:

	rb GTR_Gamma.Rev

Inspect the parameter traces. Note that the gtr run has many more model parameters than the jc model above.

Was 1000 samples (corresponding to 10000 generations) a sufficient burn in?

No, not quite. Both runs have a dip in the very beginning of the trace that seems to suggest they could have used a bit longer burn in period. 

Compare the parameter estimates and trees from the two different runs. Did the runs converge (ie, are the trees and parameters drawn from the same posterior distribution)?

The runs seemed to converge again based on looking at the marginal probability distribution tab again. The trees also had the same topology. 

## Running on empty

In the above analyses, the priors were set in the script and the data informed the posteriors. You can also "run the analysis on empty", ie not have the data inform the psoterior and only sample based on the prior, by setting the `underPrior=true` flag. To conduct such an analysis, run:

    rb GTR_GammaEmpty.Rev

In Tracer, open the `.log` files from this run and the GTR run above. Compare the parameter estimates. How do the data (in the previous analysis) change the posteriors relative to running without data (in this analysis)?

They're incredibly different from one another. The estimates are so different you would have to zoom out on the x axis (or log it, I guess) really far to even be able to see the two sets of distributions on the same axes. 


Because there is a flat prior on the trees, there is a very large number of bipartitions in the posterior. We therefore don't bother creating a `.tree` file.


## Explore the impact of the priors

Copy any one of the three analysis files from above, add it to the git repo, and modify one or more of the priors. For example, in the GRT analyses you could change `alpha_prior <- 0.05`  to `alpha_prior <- 0.10`. Be sure to rename the output files so they don't write over your previous analyses.

How did the change in the prior impact the results (ie, the posterior)?

I did this for the GTR analysis and changed the prior the way the example suggested. It didn't seem to affect the results too much from looking at it in tracer, the distributions didn't seem too far off. But then I looked at the trees, and the topology was actually pretty different. 