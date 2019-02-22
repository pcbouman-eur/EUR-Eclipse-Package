# Powershell Script for the purpose of Eclipse Packaging

This repository contains a Powershell script that downloads a recent Eclipse release (currently 2018/12) and LTS version of OpenJDK (currently 11.0.2).
For these downloads, those folders with an Eclipse installation are created, one for exam environments and one for a regular environment.

## Usage

Download all the files in this git repository and execute the script `create-packages.ps1` using Microsoft Powershell. After this is done, the installation for exams can be found in the directory `package-exam` and
the regular package in `package-regular`. Note that the regular package should be executed once, because it
can request to download additional Eclipse plugins on the first execution. These should be installed, before
the package is actually deployed to end users.

### Exam Package

The distinct features of the exam package are:

* The default workspace folder is `@{user.home}\Desktop\eclipse-workspace` rather than `@{user.home}\eclipse-workspace`. It should be checked whether this is actually appropiate in an exam environment.
* No workspace selection dialog is trigger, to avoid that students actually put their workspace in any other location than the Desktop.
* By default, executing a program terminates any previously running programs. This avoid accidentally overloading the computer with programs that run an infinite loop.

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
* The default preferences of new workspaces are adapted by means of setup-taks in an [Oomp](https://projects.eclipse.org/projects/tools.oomph) setup script, which is stored in `configuration\org.eclipse.oomph.setup\installation.setup`.