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

**Inspect the parameter traces. Was 1000 samples (corresponding to 10000 generations) a sufficient burn in?**

1000 samples does seem to have been a sufficient burn-in - the traces remain horizontal over their length, indicating relatively stable posterior probabilities. The burn-in was able to allow each analysis to find a peak in tree space before any phylogenies were actually recorded.

However, if I set the Burn-In count to 0 in Tracer, the parameter trace shows a very rapid upward trend, reaching a plateau within 500 generations. I don't know if this represents something 'real' or if it an artifact of the way Tracer generates figures. If real, it indicates that the burn in of 1000 samples was nearly (but not quite) enough of a burn in.

**Compare the parameter estimates and trees from the two different runs. Did the runs converge (ie, are the trees and parameters drawn from the same posterior distribution)?**

The parameter estimates for the two runs are nearly identical, as are their marginal probability distributions; these results indicate that the parameters are drawn from the same posterior distribution. The trees generated by the two runs are not identical, but are quite similar. Both recover three large node-based clades - one definable as (*Alouatta palliata* + *Pan paniscus*), one definable as (*Nycticebus coucang + Galago senegalensis*), and one definable as (*Lemur catta* + *Lepilemur hubbardorum*). The three large clades have identical toplogy in both trees. Because the trees are unrooted, it is difficult to accurately describe the differences in their topology, but one major difference is in the position of *Tarsius syrichta*, which is placed closer to the (*Lemur catta* + *Lepilemur hubbardorum*) clade in Tree 1 and as the outgroup of the other two large clades in Tree 2. Overall, the parameter estimates, marginal probability distributions, and trees themselves strongly indicate the runs converged.

## GTR analysis

Now run the gtr analyses with:

	rb GTR_Gamma.Rev

Inspect the parameter traces. Note that the gtr run has many more model parameters than the jc model above.

**Was 1000 samples (corresponding to 10000 generations) a sufficient burn in?**
1000 samples seems to have been a sufficient burn-in, as in the JukesCantor run - the parameter traces (while being more scattered, due to the greater number of parameters in the GTR model) remain horizontal along their length when burn-in is set to 1000. As in the above example, plateau was reached within 500 samples. 

**Compare the parameter estimates and trees from the two different runs. Did the runs converge (ie, are the trees and parameters drawn from the same posterior distribution)?**
As before, the parameter estimates and marginal probability distributions for the two runs are nearly identical. As in the prior example, the trees generated by each run are also very similar. Both recover an (*Alouatta palliata* + *Pan paniscus*) clade with *Tarsius syrichta* as its sister, and a (*Cheirogaleus major + Lemur catta*) clade. The aforementioned clades have identical topology in the two trees. The trees do differ; in Tree 1, *Loris tardigradus* and *Nycticebus coucang* are recovered as a clade, but in Tree 2 they are positioned apart, and the (*Cheirogaleus major + Lemur catta*) clade is recovered as sister to the (*Alouatta palliata* + *Pan paniscus*) clade in Tree 2 but not in Tree 1. Overall, the similarities between the parameter estimates, marginal probability distributions, and trees generated by each run strongly suggests that the runs converged.

## Running on empty

In the above analyses, the priors were set in the script and the data informed the posteriors. You can also "run the analysis on empty", ie not have the data inform the psoterior and only sample based on the prior, by setting the `underPrior=true` flag. To conduct such an analysis, run:

    rb GTR_GammaEmpty.Rev

In Tracer, open the `.log` files from this run and the GTR run above. Compare the parameter estimates. **How do the data (in the previous analysis) change the posteriors relative to running without data (in this analysis)?**

The parameter estimates and marginal probability distributions in this example are not as close as those in the prior two analyses. Having the data as well as the priors inform the posteriors seems to help funnel each run toward the best tree - without the constraint of the data, the analyses are more free to wind up in different areas of tree space.

Because there is a flat prior on the trees, there is a very large number of bipartitions in the posterior. We therefore don't bother creating a `.tree` file.


## Explore the impact of the priors

Copy any one of the three analysis files from above, add it to the git repo, and modify one or more of the priors. For example, in the GRT analyses you could change `alpha_prior <- 0.05`  to `alpha_prior <- 0.10`. Be sure to rename the output files so they don't write over your previous analyses.

**How did the change in the prior impact the results (ie, the posterior)?**
In this case, the change in the prior seems to have had a minimal consistant impact on the results. The 1st run with prior = 0.10 has a posterior of 240, and the second has a posterior 
of 338 (the two runs with prior = 0.05 have posteriors of 293 and 281). Parameter estimates are nearly identical under the different priors, as are marginal probability distributions and parameter traces. Overall, there is nothing striking about the results I gathered that suggests that the change from prior = 0.05 to prior = 0.10 had a significant impact on my results. The only possible significant difference is that posteriors were more extreme with a higher prior, but I don't know if the observed difference can truly be considered 'significant' in a proper sense.
