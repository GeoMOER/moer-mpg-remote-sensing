---
title: "Project Management and Agile Data Science"
---

"Managing a project effectively means thinking before acting[...]." [(Portny & Austin 2002)](https://www.sciencemag.org/careers/2002/07/project-management-scientists){:target="_blank"}

## A note on project management
Creativity in research and project management are not incompatible. In fact, most if not all research requires the definition of some kind of aim or the organization of tasks in time schedules. Project requirements that define tasks might not be developed or even known at some stage of the project but project management is not a stiff corset. 

Common project management steps are:
* Define the project and its goals,
* Break down the project into tasks and define a schedule,
* Design workflows for each task and implement them,
* Adjust your tasks, solve problems and be flexible.

While many project management solutions are available, the GitHub project board feature might be all you ever need at least during your course of study.

For a more detailed look, see e.g. the paper of [(Portny & Austin 2002)](https://www.sciencemag.org/careers/2002/07/project-management-scientists){:target="_blank"} cited above on project management for scientists.



{% include figure image_path="/assets/images/project_workflow.jpg" alt="Picture illustratinc a project workflow as a comic." caption_url="[CC-BY by projectcartoon.com](http://www.projectcartoon.com/cartoon/2100083/new){:target='_blank'}" %}


## A note on using Git and other tools for supporting scientific analysis 
You already got in contact with Git version control and the issue tracker and project board features of GitHub. These tools also allow full flexibility and at the same time ensure that your workflow and analysis progress is transparent, documented and re-usable. As for software development, agile approaches in data science can help to link required software engineering to the nature of science and scientific analysis (see e.g. a blog entry at O'Reilly promoting a manifesto for Agile data science](https://www.oreilly.com/ideas/a-manifesto-for-agile-data-science){:target="_blank"}).

A real world example on how data science tools helped to do better science can be found in the publication by [Lowndes et al. (2017)](https://www.nature.com/articles/s41559-017-0160){:target="_blank"} who describes their work on the Ocean Health Index.
{: .notice--info}

## A note on manual vs. automatic workflows
Deciding if an analysis workflow is directly included into a script or into an easier reusable function is not always simple. For starters, do not focus on automation but focus on using loops for repeating tasks and implement features you already know that you will need several times for different input datasets as function.

{% include figure image_path="https://imgs.xkcd.com/comics/automation.png" alt="Picture illustratinc a project workflow as a comic." caption_url="[CC-BY by xkcd.com](https://xkcd.com/1319/){:target='_blank'}" %}