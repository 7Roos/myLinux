#!/bin/bash

# Automated installer for Ubuntu, Fedora and Arch Linux distributions. 
# There are many packages and configurations, and it is bad to keep remembering to install and configure one by one. 
# So a viable alternative was to create (with the help of AI) this program.
#
# Matheus Roos, 28/06/2024
# Last updated, 27/11/2024

##########################################
####### Definition of packages ###########
##########################################
build_packs=("nano" "curl" "git" "pip" "pipx")
#nano: text editor
#curl: packages manager
#git: code versioning
#python3-pip: pip - python package manager
#pipx:

midia_packs=("inkscape" "gimp" "rsvg-convert" "obs-studio" "spotify" "brave")
#inkscape: vector drawing
#gimp: images editor
#rsvg-convert: convertor svg -> eps
#obs: obs studio
#spotify: spotify
#brave: browser

scientific_packs=("gfortran" "texlive" "gnuplot" "texstudio" "fortls" "conda" "lapack" "code")
#gfortran: compile fortran
#texlive: compile LaTex
#gnuplot: graph editor
#texstudio: LaTex editor 
#fortls: linter for fortran
#conda: python packages and virtual enviroment
#lapack: linear algebra lib
#code: vs code - code editor

manim_packs=("manim" "manim-slides")
#cairo, pango, ffmpeg: dep from manim
#manim: python library mathematical animation
#manim-slides: (dep manim) to generate slides

terminal_packs=("zsh" "fonts-powerline" "Zsh-syntax-highlighting" "Zsh-autosuggestions" "FZF" "Plugin K")
#zsh: alternative terminal to shell
#fonts-powerline": special fonts
#Zsh-syntax-highlighting: analyzer syntax
#Zsh-autosuggestions: auto-sugest
#FZF e Plugin K: plugins

function welcome {
  # Welcome function
  echo "************************************************"
  echo "** Welcome to the Custom Installation Wizard! **"
  echo "************************************************"
}

function choose_distro {
  #### Linux distribution choice - package manager #######

  #The installation commands can change between distributions, i.e., #between package managers, which are three, matching to the Debian, # RHEL and Arch derivations.
  echo ""
  echo "Select the manager packs:"
  echo "1) apt"
  echo "2) dnf"
  echo "3) pacman"
  echo ""
  #-n 1 ensures that the user only enters one character and then automatically 'gives a enter'
  read -n 1 distro

  # Response validation
  while [[ ! $distro =~ ^[123]$ ]]; do
    echo "** Invalid option! Type 1 for apt, 2 for dnf or 3 for pacman: **"
    read -n 1 distro
  done

  # Response storage
  if [[ $distro == 1 ]]; then
    distro="debian"
    prefix="apt"
  elif [[ $distro == 2 ]]; then
    distro="rhel"
    prefix="dnf"
  elif [[ $distro == 3 ]]; then
    distro="arch"
    prefix="pacman"
  fi
  echo ". Manager packages: $prefix"

  # Clears the log file before starting
  >install.log

  # Log file record
  echo "Manager packages: $prefix" >>install.log
  echo "" >>install.log
}

function update_system {
  ######### Packages update: ########
  if [[ $prefix == "apt" ]]; then
    sudo $prefix update
    sudo apt -y upgrade && sudo apt -y autoremove
  elif [[ $prefix == "rhel" ]]; then
    sudo $prefix -y update
  elif [[ $prefix == "pacman" ]]; then
    sudo $prefix -Syu --noconfirm
    # There is no automatic package remover, you should analyze case by case.
  fi

  ##################################
  #### Installing packages ######
  ##################################

  echo ""
  echo "**********************"
  echo "Update completed!"
  echo "**********************"
}

color_print() {
  # $1: Text to be printed
  # $2: Color (optional)
  # $3: Style (optional)

  ### Dictionarie:
  ## Colors (Codes ANSI):
  #30: Black
  #31: Red
  #32: Green
  #33: Yellow
  #34: Blue
  #35: Magenta
  #36: Cyan
  #37: white
  ## Styles:
  #1: Bold
  #4: Undescore
  #7: Inverted

  color=${2:-32}m # Green color by default
  style=${3:-0}   # Normal style by default
  echo -e "\e[$style;$color$1\e[0m"
}

print_packages() {
  # Iterates through the list printing the name of each package

  echo ""
  echo "These packages will be installed"

  for pack in "${@}"; do
    color_print "$pack"
  done
  echo ""

  # Pause execution for 2 seconds
  sleep 2
}

function check_installation {
  # It's not working perfectly, it needs adjustments!
  # It is not capturing installation errors and programs already 
  # installed with different name, e.g., texlive and pdflatex
  # $1: Program name
  local program="$1"

  if [ $? -ne 0 ]; then
    color_print "Error installing $program" 31
    echo "Error installing $program" >>install.log
  else
    echo "$program installed" >>install.log
  fi
}

suscess_install() {
  echo ""
  color_print "**********************" 33
  echo $1
  color_print "**********************" 33
  echo ""
  echo "Let's continue!"
}

welcome

######################
## Part 1: Definition
######################
choose_distro

######################
## Part 2: Update
######################
update_system

print_packages "${build_packs[@]}"
echo "build_packs:" >>install.log
echo "" >>install.log

######################
## Parte 3: Installing
######################
# Essentials
for program in "${build_packs[@]}"; do
  # Check if the program is already installed
  if ! command -v $program &>/dev/null; then
    if [[ $prefix == "apt" ]]; then
      if [[ $program == "pip" ]]; then
        sudo $prefix install -y python3-pip
      else
        sudo $prefix install -y $program
      fi
    elif [[ $prefix == "dnf" ]]; then
      if [[ $program == "git" ]]; then
        sudo yum install git-all
      elif [[ $program == "pip" ]]; then
        sudo $prefix install -y python3-pip
      else
        sudo $prefix install -y $program
      fi
    elif [[ $prefix == "pacman" ]]; then
      if [[ $program == "pipx" ]]; then
        python3 -m pip install --user pipx
        python3 -m pipx ensurepath
      elif [[ $program == "pip" ]]; then
        sudo $prefix install -y python3-pip
      else
        sudo $prefix -Syu -y $program
      fi
    fi

    check_installation "$program"

    if [[ $program == "pipx" ]]; then
      pipx ensurepath
    fi
  else
    echo "$program was already installed" >>install.log
  fi
done

suscess_install "Essential packages installed"
print_packages "${midia_packs[@]}"
echo "" >>install.log
echo "midia_packs:" >>install.log
echo "" >>install.log

# Midia
for program in "${midia_packs[@]}"; do
  # Check if the program is already installed
  if ! command -v $program &>/dev/null; then
    if [[ $prefix == "apt" ]]; then
      if [[ $program == "rsvg-convert" ]]; then
        sudo $prefix install librsvg2-bin
      elif [[ $program == "brave" ]]; then
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        sudo apt update
        sudo apt install -y brave-browser
      else
        sudo $prefix install -y $program
      fi
    elif [[ $prefix == "dnf" ]]; then
      if [[ $program == "rsvg-convert" ]]; then
        sudo $prefix install librsvg2-tools
      elif [[ $program == "spotify" ]]; then
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        flatpak install flathub com.spotify.Client
        sudo ln -s /var/lib/snapd/snap /snap
        snap install spotify
      elif [[ $program == "brave" ]]; then
        sudo dnf install -y dnf-plugins-core
        sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
        sudo dnf install -y brave-browser
      else
        sudo $prefix install -y $program
      fi
    elif [[ $prefix == "pacman" ]]; then
      if [[ $program == "rsvg-convert" ]]; then
        sudo $prefix -Syu librsvg
      elif [[ $program == "spotify" ]]; then
        sudo $prefix -Syu spotify-launcher
      elif [[ $program == "brave" ]]; then
        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
        sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
        sudo zypper install brave-browser
      else
        sudo $prefix -Syu $program
      fi
    fi

    check_installation "$program"
  else
    echo "$program was already installed" >>install.log
  fi
done

suscess_install "Installed media packages"
print_packages "${scientific_packs[@]}"
echo "" >>install.log
echo "scientific_packs:" >>install.log
echo "" >>install.log

for program in "${scientific_packs[@]}"; do
  if ! command -v $program &>/dev/null; then
    if [[ $prefix == "apt" ]]; then
      if [[ $program == "texlive" ]]; then
        sudo apt install -y texlive
        sudo apt install -y texlive-full
      elif [[ $program == "fortls" ]]; then
        python3 -m pip install --upgrade pip
        pip install fortls
      elif [[ $program == "conda" ]]; then
        mkdir -p ~/miniconda3
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
        bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
        rm ~/miniconda3/miniconda.sh
      elif [[ $program == "lapack" ]]; then
        sudo apt install libblas-dev liblapack-dev
      elif [[ $program == "code" ]]; then
        sudo apt-get install wget gpg
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main"
        sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
        rm -f packages.microsoft.gpg
        sudo apt install apt-transport-https
        sudo apt update
      else
        sudo $prefix install -y $program
      fi
    elif [[ $prefix == "dnf" ]]; then
      if [[ $program == "gfortran" ]]; then
        sudo $prefix install -y gcc-gfortran
      elif [[ $program == "texlive" ]]; then
        sudo $prefix install -y texlive-scheme-basic
        sudo $prefix install -y 'tex(beamer.cls)'
        sudo $prefix install -y 'tex(hyperref.sty)'
        sudo $prefix install -y texlive-scheme-full
      elif [[ $program == "fortls" ]]; then
        python3 -m pip install --upgrade pip
        pip install fortls
      elif [[ $program == "conda" ]]; then
        mkdir -p ~/miniconda3
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
        bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
        rm ~/miniconda3/miniconda.sh
      elif [[ $program == "lapack" ]]; then
        sudo yum install lapack lapack-devel blas blas-devel
      elif [[ $program == "code" ]]; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
        dnf check-update
      else
        sudo $prefix install -y $program
      fi
    elif [[ $prefix == "pacman" ]]; then
      if [[ $program == "gfortran" ]]; then
        sudo $prefix -Syu gcc-gfortran
      elif [[ $program == "texlive" ]]; then
        sudo $prefix -Syu texlive-most
        sudo $prefix -Syu install texlive-* #full
      elif [[ $program == "fortls" ]]; then
        python3 -m pip install --upgrade pip
        pip install fortls
      elif [[ $program == "conda" ]]; then
        mkdir -p ~/miniconda3
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
        bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
        rm ~/miniconda3/miniconda.sh
      elif [[ $program == "lapack" ]]; then
        sudo $prefix -Syu blas lapack
      elif [[ $program == "code" ]]; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/zypp/repos.d/vscode.repo >/dev/null
        sudo zypper refresh
        sudo zypper install code
      else
        sudo $prefix -Syu $program
      fi
    fi
    check_installation "$program"
  else
    echo "$program was already installed" >>install.log
  fi
done

suscess_install "Scientific packages installed"
print_packages "${manim_packs[@]}"
echo "" >>install.log
echo "manim_packs:" >>install.log
echo "" >>install.log

for program in "${midia_packs[@]}"; do
  if ! command -v $program &>/dev/null; then
    if [[ $prefix == "apt" ]]; then
      if [[ $program == "manim" ]]; then
        sudo apt install build-essential python3-dev libcairo2-dev libpango1.0-dev ffmpeg
        pip3 install manim
      elif [[ $program == "manim-slides" ]]; then
        pipx install -U "manim-slides[pyside6-full]"
      fi
    elif [[ $prefix == "dnf" ]]; then
      if [[ $program == "manim" ]]; then
        sudo dnf install cairo-devel pango-devel
        sudo dnf install python3-devel
        sudo dnf install ffmpeg
        pip3 install manim
      elif [[ $program == "manim-slides" ]]; then
        pipx install -U "manim-slides[pyside6-full]"
      fi
    elif [[ $prefix == "pacman" ]]; then
      if [[ $program == "manim" ]]; then
        sudo pacman -S cairo pango ffmpeg
        pip3 install manim
      elif [[ $program == "manim-slides" ]]; then
        pipx install -U "manim-slides[pyside6-full]"
      fi
    fi
  else
    echo "$program was already installed" >>install.log
  fi
done

suscess_install "Manim packages installed"
print_packages "${terminal_packs[@]}"
echo "" >>install.log
echo "terminal_packs:" >>install.log
echo "" >>install.log

for program in "${terminal_packs[@]}"; do
  if ! command -v $program &>/dev/null; then
    if [[ $prefix == "apt" ]]; then
      if [[ $program == "Zsh-syntax-highlighting" ]]; then
        sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
      elif [[ $program == "Zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
      elif [[ $program == "FZF" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
      elif [[ $program == "Plugin K" ]]; then
        git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k
      else
        sudo $prefix install -y $program
      fi
    elif [[ $prefix == "dnf" ]]; then
      if [[ $program == "Zsh-syntax-highlighting" ]]; then
        sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
      elif [[ $program == "Zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
      elif [[ $program == "FZF" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
      elif [[ $program == "Plugin K" ]]; then
        git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k
      else
        sudo $prefix install -y $program
      fi
    elif [[ $prefix == "pacman" ]]; then
      if [[ $program == "fonts-powerline" ]]; then
        git clone https://github.com/powerline/fonts.git
      elif [[ $program == "Zsh-syntax-highlighting" ]]; then
        sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
      elif [[ $program == "Zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
      elif [[ $program == "FZF" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
      elif [[ $program == "Plugin K" ]]; then
        git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k
      else
        sudo $prefix install -y $program
      fi
    fi
  else
    echo "$program was already installed" >>install.log
  fi
done

######################
## Part 4: Settings
######################
echo ""
echo "**********************"
echo "Setting Git? [y/n]"
echo "**********************"
read -n 1 git
if [[ $git == "y" ]]; then
  echo "What is the username?"
  read user
  git config --global user.name "$user"
  echo "What is the email?"
  read email
  git config --global user.email $email

  # Set VSCode as default editor
  git config --global core.editor 'code --wait'

  # Configuration verification
  git config --list
fi

# Extra facilities

# Installation commands for different package managers: https://command-not-found.com/

# Maybe in the future to implement an interactive menu
# Create a dialog box with two options
#choice=$(whiptail --title "Choose an optiono" --menu "What do you want to do??" 10 30 2 \
#  "Install packages" "1" \
#  "Update the system" "2" 3>&1 1>&2 2>&3)
