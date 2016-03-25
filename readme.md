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

It was not a sufficient burn in, because when the burn-in was made to be 0 in Tracer, the trace was not yet stable and there was still some burn in for both run 1 and run 2.

Compare the parameter estimates and trees from the two different runs. Did the runs converge (ie, are the trees and parameters drawn from the same posterior distribution)?

The Marginal Probability Distribution for the two trees were similar in spread but had slightly different peaks, the peak of the tree for run 2 being slightly less negative than that of the tree for run 1. The trees were not the same either—-the same sister relationships were recovered from both runs for the taxa at the tips, but the position of certain clades relative to each other seem to have differed between the trees. For example, the clades of *Lemur catta* and *Lepilemur hubbardorum*, *Alouatta palliata* and *Saimiri sciureus*, *Galago senegalensis* and *Nycticebus coucang*, and *Chlorocebus aethiops* and *Pan paniscus* were determined on both trees with the same taxa and the same relationships. However, the relationship between these four general clades differed between the two trees. The position of the taxon *Tarsius syrichta* also differed. The runs seem to have converged, as the posterior distribution of the two runs were only slightly different with regards to the peak. Though there exists a fine line between runs having converged and not converged, the clear indication of a run not having converged is of two marginal probability distributions that have peaks very separate from each other, with little overlap between the distributions. Though there’s a slight difference between peaks here, the distributions are more or less overlapping and of similar shape, and this indicates that the runs likely converged.


## GTR analysis

Now run the gtr analyses with:

	rb GTR_Gamma.Rev

Inspect the parameter traces. Note that the gtr run has many more model parameters than the jc model above.

Was 1000 samples (corresponding to 10000 generations) a sufficient burn in? 

Just as with the Jukes Cantor run, when the burn-in in Tracer is set to 0, the trace for both runs still has a little bit of burn in before stabilizing. 1000 samples was therefore not a sufficient burn in in this case either.

Compare the parameter estimates and trees from the two different runs. Did the runs converge (ie, are the trees and parameters drawn from the same posterior distribution)?

The marginal probability distribution for both trees are very similar to each other in distribution, with the distribution for run 2 very slightly larger in range, and the peak at about the same posterior probability for both runs, although it is noticeably higher for run 2. The trees were more different in topology from each other than the trees for the Jukes Cantor runs were. The sister relationships among the taxa at the tips are the same for both trees except for the relationship between *Callicebus donacophilus*, *Samiri sciureus*, and *Cebus albifrons*, which differs between the two trees in which two taxa are sister to each other. As with the Jukes Cantor trees, the relationships between general clades seem to be the same (except for the relationship mentioned in the previous sentence), but the relationship between the clades differ between the two trees. For example, the clade of *Cheirogaleus major* and *Daubentonia madagascariensis* and the clade of *Chlorocebus aethiops* and *Pan paniscus* are the same in the two trees in the taxa and their relationships, but their position with relation to each other differ between the two trees. Another large difference between the two trees is the difference in placement of the clade of *Loris tardigradus* and *Nycticebus coucang* the clade of *Galago senegalensis* and *Otolemur crassicaudatus*, and the taxon *Perodicticus potto*. The first clade is sister to the second clade and taxon in the tree obtained from run 1, but this is not the case in the tree obtained from run 2. This is another observation indicating the two trees to be more different from each other than the two trees obtained from the JC runs. Given the very similar distribution and shape of the marginal probability distribution for both trees, the runs seem to have converged.

## Running on empty

In the above analyses, the priors were set in the script and the data informed the posteriors. You can also "run the analysis on empty", ie not have the data inform the psoterior and only sample based on the prior, by setting the `underPrior=true` flag. To conduct such an analysis, run:

    rb GTR_GammaEmpty.Rev

In Tracer, open the `.log` files from this run and the GTR run above. Compare the parameter estimates. How do the data (in the previous analysis) change the posteriors relative to running without data (in this analysis)?

The posteriors are much much much smaller/more negative in the analyses where the data informed the posteriors. In the empty analyses, the posteriors are in the range of 0 to -60, whereas in the previous analyses, the posteriors are much more negative, in the range of -13120 to -13190. 

Because there is a flat prior on the trees, there is a very large number of bipartitions in the posterior. We therefore don't bother creating a `.tree` file.


## Explore the impact of the priors

Copy any one of the three analysis files from above, add it to the git repo, and modify one or more of the priors. For example, in the GRT analyses you could change `alpha_prior <- 0.05`  to `alpha_prior <- 0.10`. Be sure to rename the output files so they don't write over your previous analyses.

How did the change in the prior impact the results (ie, the posterior)? 

The change in the prior did not have a noticeable effect on the posterior. Previously, the posterior range was between -13120 and -13190, whereas now the range is from -13120 to -13200. Comparing all of the posteriors together, with the four marginal probability distribution curves overlaid over each other, the distributions are very similar in their range of posteriors, with no significant aberration into larger or smaller posteriors. A similar conclusion is reached by comparing them in the estimates tab, with the intervals for the four posterior distributions not being appreciably different from each other. 

