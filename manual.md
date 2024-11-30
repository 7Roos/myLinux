# Manual

## Part 1: Definition
### ---------------------------------------------
### Sections
The default session definitions are:
- build_packs: build (git, curl, pip,...)
- midia_packs: midia (inkscape, obs, gimp,...)
- scientific_packs: scientific (program languages, editor text, graph editors, etc)
- manim_packs (optional): manim and manim-slides libraries
- terminal_packs (optional): terminal zsh

### Package custom
You can modify the programs that will be installed by replacing the value in parentheses.

### Functions
- **welcome**: print welcome message
- **choose_distro**: choose manager packs: apt, dnf, or pacman. 
  * Accept a number(1,2, or 3).
  * Response storage in prefix variable
  * Write in file 'install.log'
- **update_system**: catch 'prefix' and update the system
- **color_print**: define color, style and print the text
- **print_packages**: print list of packages. Use color_print and sleep (pause) function.
- **check_installation**: check installation of the packages and print (might need improvement to capture installation errors and handle programs with different names).

## Part 2: Update
Call functions:
- welcome
- choose_distro
- update_system
- print_packages

## Part 3: Install
- Do loop above sections build_packs, midia_packs,.... 
- Check already installed packages (if ! command -v $program &>/dev/null).
- Ramifications conditions 'prefix' and special installation, e.g., python.
- Print list packs installed
- Write in log file

## Part 4: Setting
-Configuration of the git and extension of the VS code.