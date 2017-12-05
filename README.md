Kaldi Speech Recognition Toolkit - Instructional version
========================================================

This repository is a simplified version of the `kaldi` toolkit, used
for instructional purposes.

Resources
---------

See the `resources` directory.

Installation
------------

**Atmosphere Users**: Your image will *already* contain the `docker` image.
You do *not* need to run the Installation steps below.

### Building from `Dockerfile`

There is a `Dockerfile` that can be used to build a `docker` image.

```
cd docker
./build_container.sh
```

### `Pull`ing from `DockerHub`

You can also `pull` the built image directly from `docker hub` instead of building with the `Dockerfile`.

```
docker pull mcapizzi/kaldi_instructional
```

Running `docker` container
--------------------------

Once the `docker` container exists, it can be run easily with `./start_container.sh`.
This will open port `8880` by default to access the `jupyter` kernel.  
If you prefer a different port it can be added with the `-p` flag.

**Atmosphere Users**: When you `ssh` into your instance make sure you use the command below.

```
ssh -L 8880:localhost:8880 [username]@[ip_address]
```

This will open port `8880` on your instance as well so that you can use `jupyter` in your browser.
**Note:** If you plan on using a different port, replace `8880` and then be sure to add the `-p` flag when running `.start_container.sh`.

```
mcapizzi@vm142-92:/home/kaldi$ sudo ./start_container.sh 
root@1c35c7b03e94:/home/kaldi/egs/INSTRUCTIONAL#
```

Running `jupyter`
-----------------

Once the `docker` container is running, you can start `jupyter` by running `./start_jupyter.sh`.
This will run `jupyter` and show you a `URL` that can be opened in your browser.

Below is an example of the output from `./start_jupyter.sh` and the `URL` you'll need.


```
root@1c35c7b03e94:/home/kaldi/egs/INSTRUCTIONAL# ./start_jupyter.sh 
[I 19:26:00.626 NotebookApp] Writing notebook server cookie secret to /root/.local/share/jupyter/runtime/notebook_cookie_secret
[I 19:26:01.003 NotebookApp] Serving notebooks from local directory: /home/kaldi/egs/INSTRUCTIONAL
[I 19:26:01.003 NotebookApp] 0 active kernels
[I 19:26:01.003 NotebookApp] The Jupyter Notebook is running at:
[I 19:26:01.003 NotebookApp] http://0.0.0.0:8880/?token=ff0590da8903c99aa29e2295d8cdb665a6e5fff2b5509214
[I 19:26:01.003 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[C 19:26:01.004 NotebookApp] 
    
    Copy/paste this URL into your browser when you connect for the first time,
    to login with a token:
        http://0.0.0.0:8880/?token=ff0590da8903c99aa29e2295d8cdb665a6e5fff2b5509214
```

Now you can copy `http://0.0.0.0:8880/?token=ff0590da8903c99aa29e2295d8cdb665a6e5fff2b5509214` and paste into your browser.