# multistage-fails
Docker multistage build fails example

## How to reproduce
You can run either type the command given below or simply run the provided script.
If the cow is saying success you're not affected. To run the script:

    ./multistage-test.sh

If you run the script a second time, it works. But if the build cache gets cleaned
up (e.g. do `docker system prune -a`) then it fails again!

Affected systems (at least):
 * Docker CE with devicemapper storage backend
 * Docker CE with btrfs storage backend

Systems were is work (at least)
 * Docker CE with overlay2 storage backend

## Detailed steps to reproduce (alternative)
```
$ cd baseline
$ docker build -t jcberthon/baseline:latest .
Sending build context to Docker daemon
(...)
Successfully built

$ cd ../level1
$ docker build -t jcberthon/level1:latest .
Sending build context to Docker daemon
(...)
Successfully built

$ cd ../level2
$ docker build -t jcberthon/level2:latest .
Sending build context to Docker daemon
(...)
Successfully built

$ cd ../level3
$ docker build -t jcberthon/level3:latest .
Sending build context to Docker daemon  2.048kB
Step 1/6 : FROM jcberthon/baseline:latest as baseline
 ---> f240f5683af6
Step 2/6 : FROM jcberthon/level1:latest as level1
 ---> 24476015f33f
Step 3/6 : FROM jcberthon/level2:latest
 ---> 69a18a76fe46
Step 4/6 : COPY --from=baseline /project/test/bug.txt /project/test/bug.txt
 ---> 2999c9e26cb7
Step 5/6 : COPY --from=level1 /project/test/hello.txt /project/test/hello.txt
failed to export image: failed to create image: failed to get layer sha256:b6b164ffc3066ca1b8f5b81f7e4b4ada6cc17eea95403f6329ffe578e673bf45: layer does not exist

$ docker build -t jcberthon/level3:latest .
Sending build context to Docker daemon  2.048kB
Step 1/6 : FROM jcberthon/baseline:latest as baseline
 ---> f240f5683af6
Step 2/6 : FROM jcberthon/level1:latest as level1
 ---> 24476015f33f
Step 3/6 : FROM jcberthon/level2:latest
 ---> 69a18a76fe46
Step 4/6 : COPY --from=baseline /project/test/bug.txt /project/test/bug.txt
 ---> Using cache
 ---> 2999c9e26cb7
Step 5/6 : COPY --from=level1 /project/test/hello.txt /project/test/hello.txt
 ---> 40baef0257f1
Step 6/6 : ENTRYPOINT [ "bash", "-c", "cat /project/test/hello.txt | /usr/games/cowsay" ]
 ---> Running in 0f651ad6b054
Removing intermediate container 0f651ad6b054
 ---> 08eba62d26fd
Successfully built 08eba62d26fd
Successfully tagged jcberthon/level3:latest
$ docker run --rm jcberthon/level3:latest
 __________________________
< Multistage build success >
 --------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||


$ docker system prune -a
$ docker build -t jcberthon/level3:latest .
Sending build context to Docker daemon  2.048kB
Step 1/6 : FROM jcberthon/baseline:latest as baseline
latest: Pulling from jcberthon/baseline
f2aa67a397c4: Pull complete 
9c4c0276e22d: Pull complete 
Digest: sha256:841dd84413a7f6f1e9493bffbc981fdf3a5e7a4f74f4065d0854e04c66d6444f
Status: Downloaded newer image for jcberthon/baseline:latest
 ---> f240f5683af6
Step 2/6 : FROM jcberthon/level1:latest as level1
latest: Pulling from jcberthon/level1
f2aa67a397c4: Already exists 
9c4c0276e22d: Already exists 
aaabc4aa6ef0: Pull complete 
Digest: sha256:174e88869b0b12f3155de1a104dbb9737691e4da5028b1fdf054a9f8523ef96a
Status: Downloaded newer image for jcberthon/level1:latest
 ---> 24476015f33f
Step 3/6 : FROM jcberthon/level2:latest
latest: Pulling from jcberthon/level2
f2aa67a397c4: Already exists 
9c4c0276e22d: Already exists 
cfa21cabf2ca: Pull complete 
Digest: sha256:b5d0abd878df2e5702b491a19e8055fc762cf6dbd9130b606cb5d59034c7871b
Status: Downloaded newer image for jcberthon/level2:latest
 ---> 69a18a76fe46
Step 4/6 : COPY --from=baseline /project/test/bug.txt /project/test/bug.txt
 ---> 10a3553141e8
Step 5/6 : COPY --from=level1 /project/test/hello.txt /project/test/hello.txt
failed to export image: failed to create image: failed to get layer sha256:0d7c441bb370111938e37ceeea4b2d020abf56eec589f5de3adc9d6e20e95490: layer does not exist
```
