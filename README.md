# fragmentor-ansible

[![Build Status](https://travis-ci.com/InformaticsMatters/fragmentor-ansible.svg?branch=master)](https://travis-ci.com/InformaticsMatters/fragmentor-ansible)
![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/informaticsmatters/fragmentor-ansible)

Ansible playbooks for the Kubernetes-based execution of [fragmentor]
**Playbooks**.

Before you attempt to execute any fragmentation plays...

1.  You will need a Kubernetes namespace that contains a pre-deployed postgres
    server. You can use the Ansible playbook and role in our [postgresql-ansible]
    GitHub repository to do this.
2.  The database needs to be using a shareable (EFS/NFS) volume
    (`ReadWriteMany`) for use with **pgcopy** command data - and you'll need
    the name of the PVC. This is expected to be mounted into the database at
    `/pgcopy`.
3.  The database Kubernetes service is expected to be called `postgres`
4.  Your cluster must contain nodes with the label
    `informaticsmatters.com/purpose=fragmentor`. The fragmentor control
    container and the launched workflow pods will only run on nodes
    that contain this label.
5.  You will need Kubernetes credentials.
6.  You will need AWS credentials (for bucket access).

Start from a virtual environment: -

    $ python -m venv ~/.venv/fragmentor-ansible
    $ source ~/.venv/fragmentor-ansible/bin/activate
    $ pip install --upgrade pip
    $ pip install -r requirements.txt
    
## Running a fragmentation play
The fragmentor executes the fragmentation process in a number of **Plays**,
all implemented in the [fragmentor] repository using its own Ansible
playbooks: -

-   `standardise`
-   `fragement`
-   `inchi`
-   `extract`
-   `combine`

All of these playbooks are available in a _control_ container that can be
executed in Kubernetes. What this repository does is launch the _control_
container (in a pre-existing Kubernetes **Namespace**) as a **Job** mapping
a set of Ansible playbook parameters into the container for a given play
and then sets an environment variable to select the play that is to be run.

So, to run a play you must set a suitable set of parameters that this
playbook expects in the local file `parameters.yaml`. Once you've set the
parameters for your play, run it.

>   Here we assume the file `./parameters.yaml` is set correctly and then
    set key environment variables before running the `stadardise` play.

    $ export K8S_AUTH_HOST=https://example.com
    $ export K8S_AUTH_API_KEY=?????
    $ export K8S_AUTH_VERIFY_SSL=no

    $ export AWS_ACCESS_KEY_ID=?????
    $ export AWS_SECRET_ACCESS_KEY=?????

    $ PLAY=standardise
    $ ansible-playbook site-fragmentor.yaml -e "fc_play=${PLAY}"

As the fragmentor plays can take a considerable time to run the
playbook you run here does not wait for the result - you need to
inspect the control Pod yourself to check on the play's progress.

---

[fragmentor]: https://github.com/InformaticsMatters/fragmentor
[postgresql-ansible]: https://github.com/InformaticsMatters/postgresql-ansible 
