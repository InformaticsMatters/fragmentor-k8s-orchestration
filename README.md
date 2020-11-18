# fragmentor-ansible

[![Build Status](https://travis-ci.com/InformaticsMatters/fragmentor-ansible.svg?branch=main)](https://travis-ci.com/InformaticsMatters/fragmentor-ansible)
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
5.  You will need your Kubernetes config file.
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

    $ export KUBECONFIG=~/.kube/config

    $ export AWS_ACCESS_KEY_ID=?????
    $ export AWS_SECRET_ACCESS_KEY=?????

    $ PLAY=standardise
    $ ansible-playbook site-fragmentor.yaml -e fp_play=${PLAY}

As the fragmentor plays can take a considerable time to run the
playbook you run here does not wait for the result - you need to
inspect the control Pod yourself to check on the play's progress.

## Cheat-sheet
With a parameter like th following (xchem/dsip) you should be
able to run the standard set of plays.

```yaml
---
database_login_host: postgres
deployment: production
runpath: /work
add_backup: no
vendor: xchem_dsip
version: v1
extracts:
- lib:
    vendor: xchem_dsip
    version: v1
    regenerate_index: yes
```

-   **Reset fragmentation database**

>   You only really need to do this once,
    at the very start of fragment processing. It formats the database
    by adding key tables and seeds with key records.

```
    $ ansible-playbook site-fragmentor.yaml \
        -e fp_play=db-server-configure_create-database
```

-   **Standardise**

```
    $ ansible-playbook site-fragmentor.yaml -e fp_play=standardise
```

-   **Fragment**

```
    $ ansible-playbook site-fragmentor.yaml -e fp_play=fragment
```

-   **InChi**

```
    $ ansible-playbook site-fragmentor.yaml -e fp_play=inchi
```

-   **Extract** (a dataset to graph CSV)

```
    $ ansible-playbook site-fragmentor.yaml -e fp_play=extract
```

-   **Combine** (multiple datasets to graph CSV)

Using a slightly modified parameter file (shown below) you can then combime
datasets.

```yaml
---
database_login_host: postgres
deployment: production
runpath: /work
add_backup: no
vendor: xchem_dsip
version: v1
extracts:
- lib:
    path: extract/xchem_dsip/v1
    data_source: s3
    bucket: im-fragnet
    aws_access_key: ?????
    aws_secret_key: ?????
- lib:
    path: extract/xchem_spot/v1
    data_source: s3
    bucket: im-fragnet
    aws_access_key: ?????
    aws_secret_key: ?????
path_out: xchem_combi_alan_20201117
data_source_out: s3
```

```
    $ ansible-playbook site-fragmentor.yaml -e fp_play=combine
```

---

[fragmentor]: https://github.com/InformaticsMatters/fragmentor
[postgresql-ansible]: https://github.com/InformaticsMatters/postgresql-ansible 
