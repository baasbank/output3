#! /bin/bash

# Startup script for creating an image for rpg

# Install docker
install_docker_ce() {
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce
}

add_github_to_known_hosts() { 
  if [ ! "$(ssh-keygen -F github.com)" ]; then
    ssh-keyscan github.com >> $HOME/.ssh/known_hosts
  fi
}

# The main function
main() {
  install_docker_ce
  add_github_to_known_hosts
}

main
