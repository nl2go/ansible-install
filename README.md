[![Travis (.org) branch](https://img.shields.io/travis/nl2go/ansible-pull-init/master)](https://travis-ci.org/nl2go/ansible-pull-init)
[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/nl2go/ansible-pull-init)](https://github.com/nl2go/ansible-pull-init)

# Ansible Pull Init

Setup a remote copy of Ansible on each managed node, each set to run via cron and update playbook source via a source repository (s. [ansible-pull](https://docs.ansible.com/ansible/latest/cli/ansible-pull.html)).

## Usage

    curl -fsSL https://raw.githubusercontent.com/nl2go/ansible-pull-init/master/ansible-pull-init.sh -o ansible-pull-init.sh
    sh ansible-pull-init.sh

## Maintainers

- [build-failure](https://github.com/build-failure)

## License

See the [LICENSE.md](LICENSE.md) file for details.

## Author Information

This project was created by in 2019 by [Newsletter2Go GmbH](https://www.newsletter2go.com/).
