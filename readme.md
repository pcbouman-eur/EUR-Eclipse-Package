# Powershell Script for the purpose of Eclipse Packaging

This repository contains a Powershell script that downloads a recent Eclipse release (currently 2018/12) and an LTS version of OpenJDK (currently 11.0.2),
which is not subject to the licensing issues that surround Oracle Java releases beyond January 2019.
For these downloads, those folders with an Eclipse installation are created, one for exam environments and one for a regular environment. The script then
copies the configuration files preconfigured in the src dir to patch the two packages.

## Usage

Download all the files in this git repository and execute the script `create-packages.ps1` using Microsoft Powershell. After this is done, the installation for exams can be found in the directory `package-exam` and
the regular package in `package-regular`.

**Note that the regular package should be executed once before deployment to end users**. This is to make sure it can download additional Eclipse plugins on the first execution. If the `installation.setup` script defines such plugins as required, Eclipse will ask the user if it is allowed to install these plugins upon the first launch of Eclipse.

### Exam Package

The distinct features of the exam package are:

* The default workspace folder is `@{user.home}\Desktop\eclipse-workspace` rather than `@{user.home}\eclipse-workspace`. It should be checked whether this is actually appropriate in an exam environment.
* No workspace selection dialog is trigger, to avoid that students actually put their workspace in any other location than the Desktop.
* By default, executing a program terminates any previously running programs. This avoid accidentally overloading the computer with programs that run an infinite loop.

#### TODO: Does the exam package actually work?

Currently, it is not tested if `@{user.home}\Desktop\eclipse-workspace` correctly resolves to the Desktop of the user within the exam environment of Erasmus University. This is important to check before deployment of this approach.

### Regular Package

The distinct features of the regular package are:

* By default, executing a program terminates any previously running programs. This avoid accidentally overloading the computer with programs that run an infinite loop.
* A number of default settings regarding Java warnings and errors are made more strict. As a result, it should be easier to debug certain common types of mistakes during tutorial sessions.
* The package includes uses its own bundled OpenJDK version, rather than the system-wide JRE. Using a JDK can have some advantages, e.g. when using Maven.
* The Eclipse Web Tools are added as a plugin, in case future courses decide to do something that involves some web-related technologies.
* The SpotBugs plugin is added, because this may help students and teaching assistants to find common bugs in code during tutorials

## How it works

The techniques to patch the default Eclipse installation consist of:

* Adapting `eclipse.ini` for the default workspace location and the choice of the JRE/JDK
* Adapting the launch behavior of Eclipse via the file `configuration\.settings\org.eclipse.ui.ide.prefs`.
* The default preferences of new workspaces are adapted by means of setup-tasks in an [Oomph](https://projects.eclipse.org/projects/tools.oomph) setup script, which is stored in `configuration\org.eclipse.oomph.setup\installation.setup`.

### Changes to the Eclipse.ini file

For the exam package, the default workspace location is configured using the line `-Dosgi.instance.area.default=@user.home/Desktop/eclipse-workspace`.

For the regular package, the default JRE/JDK is configured to be a subdirectory of the eclipse installation (where the OpenJDK package is automatically downloaded by the Powershell script). The default JRE/JDK is changed by the following two lines in `eclipse.ini`:

```-vm
jdk-11.0.2/bin/server/jvm.dll
```

### Changes to the org.eclipse.ui.ide.prefs file

The file `configuration\.settings\org.eclipse.ui.ide.prefs` is only used in the exam package to enforce that students do not get the question which directory to use for their workspace. This way, it can be avoided that students work in the wrong directory and their work gets lost (unless they specifically change their workspace from within Eclipse). For this, the line `SHOW_WORKSPACE_SELECTION_DIALOG=false` is added here.

### Default Workspace setup using installation.setup

The Eclipse Oomph framework allows for customized setup of a default workspace. For the exam package, this is only used to enable the *Terminate and Relaunch while launching* setting in the workspace preferences under `Run/Debug > Launching`. For the regular package, additional default preferences that provide stricter warnings for certain code smells are enabled under `Java > Compiler > Errors/Warnings`, which should make it slightly easier to catch these types of mistakes during programming tutorials. Furthermore, the `installation.setup` script of the regular package contains dependencies on two Eclipse plugins: *SpotBugs*, which is a tool students can use to run static code analysis on their, which may find more potential bugs than the regular error and warnings mechanism of Eclipse. Secondly, the *Eclipse Web Tools* are included, so we could consider to combine some web development in future classes or courses, if that turns out to be desirable.

## Creating alternative installation.setup files.

While customizing `eclipse.ini` and `org.eclipse.ui.ide.prefs` are pretty straight forward, the XML format of `installation.setup` is pretty difficult to edit, as it requires the definition of various *setup tasks*. To edit or create a customized installation.setup, it is recommended to use a clean installation of Eclipse. If the welcome tab is closed, the default `installation.setup` can be edit by choosing `Navigate > Open Setup > Installation` from the menu bar. When this file is openen, the toolbar contains a button with a red dot that has `Record preferences` ![Set of buttons that include the Record preferences button](record-preferences.png "Record preferences button set"). Clicking this button allows you to change the preferences of a default workspace, and record them as XML setup tasks. Be sure to save the file after the preferences are recorded.

The default installation of plugins can be added to the installation file by clicking right mouse on the Installation file item in the tree, and then choosing `New Child > P2 Director`. By right clicking on the newly added *P2 Director* node, it is possible to add *Repositories* that contain the plugin dependencies, and *Requirements* that actually specify certain plugins should be installed upon the first launch. 

For the *SpotBugs* plugin the repository is `https://spotbugs.github.io/eclipse/` and the requirement is `com.github.spotbugs.plugin.eclipse.feature.group`. For the *Eclipse Web Tools*, the repository is `https://download.eclipse.org/releases/2018-09` and the requirement is `com.github.spotbugs.plugin.eclipse.feature.group`.

The proper setting to define a requirement can be discovered after installing a plugin into Eclipse through `Help > About Eclipse IDE` in the main menu bar, then clicking `Installation details`, then clicking on a feature and clicking the `Properties`. The under *General Information*, the proper value can be found after `Identifier:`. The repository is the *Eclipse Download Site* that is usually specified on the website of an Eclipse plugin project.
 