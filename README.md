Welcomer to Kiwi
===============

Initial setup with Vagrant
-------

Download the vagrant image from:
https://docs.google.com/file/d/0B3OVplM20u2gWW1aMG0wdXdySTA/edit?usp=sharing

From your downloads folder run this command:

```
vagrant box add kiwi package.box
```

From your rails repository (where you cloned the git repository) you should
now be able to start the kiwi vagrant virtual machine.

```
vagrant up
```

Then ssh into your newly created environment and install your gems

```
# vagrant ssh
# cd /home/vagrant/projects/kiwi
# bundle install
```

You may need to run database migrations before you can start the server

```
rake db:migrate
```

If you want to fill your database with some seed data, also run

```
rake db:seed
```

When that is done, run

```
./rails_server.sh
```

You should now be able to access kiwi from your browser on your host
machine http://localhost:3000 in Chrome.

Continue development on your host machine as though you had the rails
application running on your local computer.  Vagrant will take care of syncing
your changes over.  If you need to install a new gem or run database
migrations restart the server make sure you do it from your vagrant terminal.

Unit tests and Guard
--------------------

If you are intending to run unit tests (and why not :| ) you will need to run
them from the vagrant machine.  You can do this by opening up a nother temrinal
window and ssh'ing to the vagrant machine and runing rake spec or what not from
that terminal in your project folder.  If you try and run the unit tests from
your host machine you will find that they can not connect to the database.

Shutdown and Cleanup
-------

When you are done developing make sure you shutdown the virtual machine by
running:

```
vagrant halt
```

If you are no longer in need of this particular machine, or you messed up
the virtual machine in some way, run vagrant destroy and vagrant up and
you will be back where you started.

