[![inventid logo](https://cdn.inventid.nl/assets/logo-horizontally-ba8ae38ab1f53863fa4e99b977eaa1c7.png)](http://opensource.inventid.nl)

# Buckaroo
| Branch | Build status | Code coverage |
|---|---|---|
| Master |[![Build Status](https://travis-ci.org/inventid/buckaroo.svg?branch=master)](https://travis-ci.org/inventid/buckaroo)|[![Coverage Status](http://img.shields.io/coveralls/inventid/buckaroo/master.svg)](https://coveralls.io/r/inventid/buckaroo?branch=master)|
| Develop |[![Build Status](https://travis-ci.org/inventid/buckaroo.svg?branch=develop)](https://travis-ci.org/inventid/buckaroo)|[![Coverage Status](http://img.shields.io/coveralls/inventid/buckaroo/develop.svg)](https://coveralls.io/r/inventid/buckaroo?branch=develop)|

## What is it?

Buckaroo is a simple Ruby 2.1 compliant gateway to contact the Buckaroo Payment Service Provider.
Since there was no decent one available, we decided to develop our own.
And now you can use it too!

## How to use it?

Using it is quite simple, you can simply clone the code and then require it (_we plan to release a gem later_).

## How to suggest improvements?

We are still actively developing Buckaroo for our internal use, but we would already love to hear your feedback. In case you have some great ideas, you may just [open an issue](https://github.com/inventid/buckaroo/issues/new). Be sure to check beforehand whether the same issue does not already exist.

## How can I contribute?

We feel contributions from the community are extremely worthwhile. If you use Buckaroo in production and make some modification, please share it back to the community. You can simply [fork the repository](https://github.com/inventid/buckaroo/fork), commit your changes to your code and create a pull request back to this repository.

If there are any issues related to your changes, be sure to reference to those. Additionally we use the `develop` branch, so create a pull request to that branch and not to `master`.

Additionally we always use [vagrant](http://www.vagrantup.com) for our development. To do the same, you can do the following:

1. Make sure to have [vagrant](http://www.vagrantup.com) installed.
1. Clone the repository
1. Open a terminal / shell script and nagivate to the place where you cloned the repository
1. Simply enter `vagrant up`
1. Provisioning takes around 5 minutes on my PC. If you want it to be faster you can use the `userConfig.json` file in the root and override the specific settings for memory and CPU.
1. The Vagrant machine provisions and you can easily work with us. Enter `vagrant ssh` to get shell access to the machine. In case you are done with it, simply enter `vagrant destroy`. You won't lose any changes to your git repository when this happens.

## Collaborators

We would like to thank the developers which contributed to Buckaroo, both big and small.

- [rogierslag](https://github.com/rogierslag) (Lead developer of Buckaroo @ [inventid](https://www.inventid.nl))
- [joostverdoorn](https://github.com/joostverdoorn) (Developer of Buckaroo @ [inventid](https://www.inventid.nl))
