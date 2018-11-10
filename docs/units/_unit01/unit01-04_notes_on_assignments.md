---
title: "Assignments and Working Environment"
---

## A note on team learning log assignments with GitHub

Within this course, you will work in teams and hence you will submit your team's solutions for the course assignments to your team's GitHub-hosted learning log, i.e. your team's personal classroom repository. Don't get confused about "your team's personal repository". Once you have a GitHub account, you can create as many (team) repositories as you like at your account and invite any team members you want but for assignments within our courses, always use your respective team classroom repository. 

The classroom repository will be created automatically by following a link to the respective classroom assignment which will be provided by the instructors. Your team's classroom repository will be hosted as part of GeoMOER, our learning log space at GitHub for Marburg Open Educational Ressources.

If not stated otherwise, the deadline for an assignment is the date and time of the next course session. The submissions generally encompass R or R markdown with compiled html files or presentations in PDF format.

To start with, get yourself a GitHub account if you have not one already and create your team's learning log using the link provided by the course lecturers. Be aware that once the team learning log repository is created, you will stick to this and your team until the end of the course.
{: .notice--info}

Aside from submitting assignments, you should use your team repository for everything related to this course which is a potential subject to version control, team collaboration and issue tracking.
{: .notice--success}



## A note on team assignments in education
Please remember that also this course uses team assignments, it is very important that each team member knows what and how to do it. Hence, our very strong suggestion is the following: First, try to solve each task at hand individually. Second, meet as a team and share your individual solutions. Help each other, leaf no one behind, discuss problems, pros and cons and build the final team-based solution which will be the one which is submitted and/or forms the basis for the next task in your problem solving workflow. In doing so you will get the maximum from this course because learning and training your skills is most effective in problem-based and peer-to-peer scenarios.

Another important aspect is reliably and punctually. Each team mate depends on all others. Keep your team work smooth by assigning at least these two roles to your team members:
  
  * Team manager: this person is responsible for the overall team work, project management, discussion management, disciplinary measures (e.g. paying the pizza service bill).
  * Time manager: this person is responsible for managing group appointments (something like a jour fixe would be a perfect option) and keeping the time line of the project and deadlines in mind in order to inform the team manager if something is delayed.
  * Record manager: this person is responsible for keeping notes and the coordination of creating reports or presentations.
  * Cross-check manager: this person is responsible for cross-checking the final products, scripts, solutions prior to submission.

Over time you should switch roles between your team mates.

Please do not take any shortcuts here, just do it right and take as much from this course as you can.
{: .notice--success}


## Mandatory working environment
We value freedom of choice as an important good but giving our long-term experience freedom of choice comes to an end when we talk about the mandatory working environment for this course. The reason for this is simple: you work with team-based assignments and a piece of code written on the laptop of person A should run basically without any changes on the computer of person B. The situation gets more nasty if you should test some code of a peer which is not part of your team or if the instructors would like to run your script on their own system. Hence, let's save everybody's time and focus on the things which are really important. Once the course is finished, feel free to use any working environment structure you like.

### Coping with different absolute paths across different computers
The biggest problem when it comes to cross-computer project path environments is not the project environment itself, i.e. the subfolders of your project *relative* to your project folder but the *absolute* path to your project folder. Imagine you agreed on a project folder called mpg-envinsys-plygrnd. On the laptop of person A, the absolute path to the root folder might be C:\Users\UserA\University\mpg-envinsys-plygrnd while on the external hard disk of person B it might be X:\university_courses\mpg-envinsys-plygrnd. If you want to write to your data subfolder you have to change the absolute directory path depending on which computer the script is running. Not good.

One solution to this problem is to agree on a common structure *relative* to your individual R home directory using symbolic links (Linux flavor systems) or junctions (Windows flavor systems).
{: .notice--success}

Example: Agree with your team mates on a top-level folder name which hosts all of your student projects. For example, this folder is called edu. Within edu, the project folder of this course is called mpg-envinsys-plygrnd. Create the edu anywhere you want, e.g. at D:\stuff\important\edu and create a symbolic link to this folder within your R home directory i.e. the directory where `path.expand("~")` points to.

To create this link on Windows flavor systems, start a command prompt window (e.g. press [Windows], type "CMD", press [Return]) and change the directory of the command prompt window to your R home directory which is C:\Users\your-user-name\Documents by default. Then use the mklink \J command to create the symbolic link. In summary and given the paths above:

```yaml
cd C:\Users\your-user-name\Documents
mklink /J edu D:\stuff\important\edu
```

On Linux flavor systems, the R home directory is your home directory by default, i.e. /home/your-user-name/. If you create your edu folder on /media/memory/interesting/edu, the symbolic link can be created using your bash environment:
```yaml
cd /home/<your-user-name>/
ln -s /media/memory/interesting/edu edu
```
Now one can access the edu folder on both the windows and the Linux example via the home directory, i.e. ~/edu/. All problems solved.


While this will work on all of your private computers, it will not work on the ones in the University's computer lab. To handle that as smooth as possible, you can use the functionality of the envimaR package which allows to set defaults for all computers but one special type which is handled differently. See [the example on setting up a working environment]({{ site.baseurl }}{% link _unit01/unit01-05_environment_setup.md %}).
{: .notice--info}

### Mandatory working environment
Given the explanations above, your initial working environment relative to your edu folder should look like the following. It will grow over time based on additional information supplied within the individual assignments. 
```yaml
~edu/mpg-envinsys-plygrnd/
  |-- data
    |-- aerial
    |-- lidar
    |-- grass
    |-- tmp
  |-- log
  |-- run
  |-- your-github-team-learning-log-repository
```
The folder your-github-team-learning-log-repository is the one you have checked out from your GitHub-hosted team learning log.

This is no guideline, this is a rule. Read it, learn it, live it and have a nice ride.  
{: .notice--danger}

Have a look at [the example on setting up a working environment]({{ site.baseurl }}{% link _unit01/unit01-05_environment_setup.md %}).
{: .notice--info}

