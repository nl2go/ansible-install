#!/bin/sh

REQUIRED_PYTHON_VERSION='3.7'
REQUIRED_ANSIBLE_VERSION='2.8.*'

parse_semantic_version() {
	major="${1%%.*}"
	minor="${1#$major.}"
	minor="${minor%%.*}"
	patch="${1#$major.$minor.}"
	patch="${patch%%[-.]*}"
}

is_command_exists() {
	command -v "$@" > /dev/null 2>&1
}

set_distribution() {
	lsb_dist=""
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
}

install_python_on_ubuntu(){
  apt_repo="deb [arch=$(dpkg --print-architecture)] http://ppa.launchpad.net/deadsnakes/ppa/ubuntu $dist_version main"
  $shell_command "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776"
  $shell_command "echo \"$apt_repo\" > /etc/apt/sources.list.d/python.list"
  $shell_command "apt-get update -qq >/dev/null"
  $shell_command "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq python${REQUIRED_PYTHON_VERSION} python3-pip >/dev/null"
  $shell_command "update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${REQUIRED_PYTHON_VERSION} 2"
}

upgrade_pip(){
  pip3 install --upgrade pip
}

install_ansible(){
  pip3 install ansible=="$REQUIRED_ANSIBLE_VERSION"
}

install_git_on_debian(){
  $shell_command "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq git > /dev/null"
}

set_distribution_version(){
	lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

	case "$lsb_dist" in

		ubuntu)
			if is_command_exists lsb_release; then
				dist_version="$(lsb_release --codename | cut -f2)"
			fi
			if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
				dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
			fi
		;;

		debian|raspbian)
			dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
			case "$dist_version" in
				10)
					dist_version="buster"
				;;
				9)
					dist_version="stretch"
				;;
				8)
					dist_version="jessie"
				;;
			esac
		;;

		centos)
			if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
				dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
			fi
		;;

		rhel|ol|sles)
			ee_notice "$lsb_dist"
			exit 1
			;;

		*)
			if is_command_exists lsb_release; then
				dist_version="$(lsb_release --release | cut -f2)"
  			fi
			if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
				dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
			fi
		;;

	esac
}

is_install(){
  if is_command_exists python; then
		python_version="$(python --version | cut -d ' ' -f2)"
		required_major=3
		required_minor=7

		parse_semantic_version "$python_version"

		if [ "$major" -lt "$required_major" ]; then
			return 1
		fi

		if [ "$major" -le "$required_major" ] && [ "$minor" -lt "$required_minor" ]; then
			return 1
		fi

		return 0
	else
	  return 1
	fi
}

set_shell_command(){
  user="$(id -un 2>/dev/null || true)"

	shell_command='sh -c'
	if [ "$user" != 'root' ]; then
		if command_exists sudo; then
			shell_command='sudo -E sh -c'
		elif command_exists su; then
			shell_command='su -c'
		else
			cat >&2 <<-'EOF'
			Error: this installer needs the ability to run commands as root.
			We are unable to find either "sudo" or "su" available to make this happen.
			EOF
			exit 1
		fi
	fi
}

do_install() {
	if is_install; then
    set_shell_command
    set_distribution
    set_distribution_version

    case "$lsb_dist" in
      ubuntu)
          install_python_on_ubuntu
          install_git_on_debian
          ;;
      *)
        echo
        echo "ERROR: Unsupported distribution '$lsb_dist'"
        echo
        exit 1
        ;;
    esac

    upgrade_pip
    install_ansible

	fi
}

do_install
